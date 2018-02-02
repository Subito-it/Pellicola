//
//  ImagePickerViewController.swift
//  Pellicola
//
//  Created by Andrea Antonioni on 21/12/2017.
//

import UIKit
import Photos

class AssetsViewController: UIViewController {

    @IBOutlet weak private var collectionView: UICollectionView!
    
    private let numberOfPhotosForRow: Int = 4
    private let imageManager = PHCachingImageManager()
    private var thumbnailSize: CGSize!
    private weak var centerBarButtonToolbar: UIBarButtonItem?
    private var isFirstAppearance = true
    
    private var doneBarButton: UIBarButtonItem?
    private var dataStorageObservation: NSKeyValueObservation?
    
    var didSelectImages: (([UIImage]) -> Void)?
    var didPeekOnAsset: ((PHAsset) -> UIViewController)?
    
    private var viewModel: AssetsViewModel
    private var style: PellicolaStyleProtocol
    
    init(viewModel: AssetsViewModel, style: PellicolaStyleProtocol) {
        self.viewModel = viewModel
        self.style = style
        super.init(nibName: nil, bundle: Bundle.framework)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resetCachedAssets()
        configureUI()
        
        viewModel.onChangeAssets = { [weak self] in
            self?.collectionView.reloadData()
            self?.updateToolbar()
        }
        
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: collectionView)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let spaceBetweenPhotosInRow: CGFloat = 3
        let toolbarBottomSpace: CGFloat = 44
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumInteritemSpacing = spaceBetweenPhotosInRow
        layout.minimumLineSpacing = spaceBetweenPhotosInRow
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5 + toolbarBottomSpace, right: 5)
        
        // Calculate the size of the cells
        let spaceBetweenCells = spaceBetweenPhotosInRow * CGFloat(numberOfPhotosForRow - 1)
        let totalSpaces = spaceBetweenCells + layout.sectionInset.left + layout.sectionInset.right
        let cellWidth = (view.bounds.width - totalSpaces) / CGFloat(numberOfPhotosForRow)
        let cellSize = CGSize(width: cellWidth, height: cellWidth)
        layout.itemSize = cellSize
        
        // Determine the size of the thumbnails to request from the PHCachingImageManager
        let scale = UIScreen.main.scale
        thumbnailSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
        
        if isFirstAppearance, viewModel.numberOfImages > 0 {
            isFirstAppearance = false
            let lastItemIndex = IndexPath(item: viewModel.numberOfImages - 1, section: 0)
            collectionView.scrollToItem(at: lastItemIndex, at: .top, animated: false)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UI
    
    private func configureUI() {
        setupNavigationBar()
        setupCollectionView()
        setupToolbar()
    }
    
    private func setupNavigationBar() {
        title = viewModel.assetCollectionName
        
        if !viewModel.isSingleSelection {
            doneBarButton = UIBarButtonItem(title: style.doneString,
                                            style: .done,
                                            target: self,
                                            action: #selector(doneButtonTapped))
            viewModel.onChangeSelectedAssets = { [weak self] numberOfSelectedAssets in
                self?.doneBarButton?.isEnabled = numberOfSelectedAssets > 0
            }
            
            doneBarButton?.isEnabled = viewModel.numberOfSelectedAssets > 0
            
            navigationItem.rightBarButtonItem = doneBarButton
        }
        
    }
    
    private func setupCollectionView() {
        
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = false
        collectionView.register(AssetCell.self, forCellWithReuseIdentifier: AssetCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        if #available(iOS 10.0, *) {
            collectionView.prefetchDataSource = self
        }
    }
    
    private func setupToolbar() {
        
        let infoBarButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        infoBarButton.isEnabled = false
        let attributes = [ NSAttributedStringKey.foregroundColor: style.blackColor ]
        infoBarButton.setTitleTextAttributes(attributes, for: .normal)
        infoBarButton.setTitleTextAttributes(attributes, for: .disabled)
        
        let items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            infoBarButton,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        ]
        
        setToolbarItems(items, animated: false)
        
        centerBarButtonToolbar = infoBarButton
        
        updateToolbar()
        
    }
    
    private func updateToolbar() {
        
        guard viewModel.maxNumberOfSelection != nil, !viewModel.isSingleSelection, viewModel.numberOfSelectedAssets > 0 else {
            navigationController?.setToolbarHidden(true, animated: true)
            return
        }
        
        centerBarButtonToolbar?.title = viewModel.toolbarText
        navigationController?.setToolbarHidden(false, animated: true)
        
    }
    
    // MARK: - Action
    
    @objc func doneButtonTapped() {
        guard !viewModel.isDownloadingImages else {
            viewModel.stopDownloadingImages()
            let alert = UIAlertController(title: NSLocalizedString("alert_deselection.title", bundle: Bundle.framework, comment: ""),
                                          message: nil,
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: NSLocalizedString("alert_deselection.ok", bundle: Bundle.framework, comment: ""),
                                         style: .default) { [weak self] _ in
                self?.collectionView.reloadData()
            }
            alert.addAction(okAction)
            present(alert, animated: true)
            return
        }
        
        didSelectImages?(viewModel.getSelectedImages())
        
    }
    
    // MARK: Asset Caching
    
    fileprivate func resetCachedAssets() {
        imageManager.stopCachingImagesForAllAssets()
    }

}

// MARK: - UICollectionViewDataSource

extension AssetsViewController: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfImages
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AssetCell.identifier, for: indexPath) as? AssetCell else {
            fatalError("Error dequeuing photo cell")
        }
        
        cell.configure(with: AssetCellStyle(style: style))
        
        let asset = viewModel.assets.object(at: indexPath.item)
        
        // Request an image for the asset from the PHCachingImageManager.
        cell.assetIdentifier = asset.localIdentifier
        
        imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, info in
            // The cell may have been recycled by the time this handler gets called;
            // set the cell's thumbnail image only if it's still showing the same asset.
            if let image = image, cell.assetIdentifier == asset.localIdentifier {
                cell.thumbnailImage = image
            }
        })
        
        cell.setState(viewModel.getState(for: asset))
        
        return cell
    }
    
}

// MARK: - UICollectionViewDelegate

extension AssetsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        func updateUI(at indexPath: IndexPath, asset: PHAsset) {
            guard let cell = collectionView.cellForItem(at: indexPath) as? AssetCell else { return }
            DispatchQueue.main.async { [weak self] in
                guard let sSelf = self else { return }
                sSelf.updateToolbar()
                cell.setState(sSelf.viewModel.getState(for: asset))
                cell.setNeedsDisplay()
            }
        }
        
        collectionView.deselectItem(at: indexPath, animated: false)
        
        let selectedAsset = viewModel.assets.object(at: indexPath.item)
        
        viewModel.select(selectedAsset, onDownload: { [weak self] in
            
            guard let sSelf = self else { return }
            if case .loading = sSelf.viewModel.getState(for: selectedAsset) { return }
            updateUI(at: indexPath, asset: selectedAsset)
            
            }, onUpdate: { [weak self] in
                
                guard let sSelf = self else { return }
                if sSelf.viewModel.maxNumberOfSelection == 1 {
                    sSelf.didSelectImages?(sSelf.viewModel.getSelectedImages())
                } else {
                    updateUI(at: indexPath, asset: selectedAsset)
                }
                
            }, onLimit: { [weak self] in
                
                let alert = UIAlertController(title: NSLocalizedString("alert_limit.title", bundle: Bundle.framework, comment: ""),
                                              message: nil,
                                              preferredStyle: .alert)
                let okAction = UIAlertAction(title: NSLocalizedString("alert_deselection.ok", bundle: Bundle.framework, comment: ""),
                                             style: .default)
                alert.addAction(okAction)
                self?.present(alert, animated: true)
                
        })
        
    }
    
}

// MARK: - UICollectionViewDataSourcePrefetching

@available(iOS 10.0, *)
extension AssetsViewController: UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        imageManager.startCachingImages(for: indexPaths.map { indexPath in viewModel.assets.object(at: indexPath.item) },
                                        targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        imageManager.stopCachingImages(for: indexPaths.map { indexPath in viewModel.assets.object(at: indexPath.item) },
                                       targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
    }
    
}

// MARK: - UIViewControllerPreviewingDelegate

extension AssetsViewController: UIViewControllerPreviewingDelegate {
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = collectionView?.indexPathForItem(at: location) else { return nil }
        guard let cell = collectionView.cellForItem(at: indexPath) else { return nil }
        previewingContext.sourceRect = cell.frame
        let asset = viewModel.assets.object(at: indexPath.item)
        let viewController = didPeekOnAsset?(asset)
        viewController?.preferredContentSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
        return viewController
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        return
    }
    
}
