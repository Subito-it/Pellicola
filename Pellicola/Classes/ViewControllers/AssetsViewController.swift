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
    private let spaceBetweenPhotosInRow: CGFloat = 1.0
    private let imageManager = PHCachingImageManager()
    private var thumbnailSize: CGSize!
    private weak var centerBarButtonToolbar: UIBarButtonItem?
    private var isFirstAppearance = true
    
    private var doneBarButton: UIBarButtonItem?
    private var dataStorageObservation: NSKeyValueObservation?
    
    var didSelectImages: (([UIImage]) -> Void)?
    
    private var viewModel: AssetsViewModel
    
    init(viewModel: AssetsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: Bundle.framework)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resetCachedAssets()
        configureUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
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
            doneBarButton = UIBarButtonItem(barButtonSystemItem: .done,
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
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        layout.sectionInset.bottom = 44
        
        // Calculate the size of the cells
        let spaceBetweenCells = spaceBetweenPhotosInRow * CGFloat(numberOfPhotosForRow)
        let cellWidth = (UIScreen.main.bounds.width - spaceBetweenCells) / CGFloat(numberOfPhotosForRow)
        let cellSize = CGSize(width: cellWidth, height: cellWidth)
        layout.itemSize = cellSize
        
        // Determine the size of the thumbnails to request from the PHCachingImageManager
        let scale = UIScreen.main.scale
        thumbnailSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
        
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = !viewModel.isSingleSelection
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
        let attributes = [ NSAttributedStringKey.foregroundColor: UIColor.black ]
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
        
        guard !viewModel.isSingleSelection,  viewModel.numberOfSelectedAssets > 0 else {
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
        
        navigationController?.dismiss(animated: true) { [weak self] in
            guard let sSelf = self else { return }
            sSelf.didSelectImages?(sSelf.viewModel.getSelectedImages())
        }
    }
    
    // MARK: Asset Caching
    
    fileprivate func resetCachedAssets() {
        imageManager.stopCachingImagesForAllAssets()
    }
    
    // MARK: - Action
    
    @objc func actionDismiss() {
        dismiss(animated: true, completion: nil)
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
        
        let asset = viewModel.assets.object(at: indexPath.item)
        
        // Request an image for the asset from the PHCachingImageManager.
        cell.assetIdentifier = asset.localIdentifier
        
        imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { [weak cell] image, info in
            
            DispatchQueue.main.async { [weak cell] in
                // The cell may have been recycled by the time this handler gets called;
                // set the cell's thumbnail image only if it's still showing the same asset.
                if cell?.assetIdentifier == asset.localIdentifier {
                    cell?.thumbnailImage = image
                }
            }
        })
        
        cell.setState(viewModel.getState(for: asset))
        
        return cell
    }
    
}

// MARK: - UICollectionViewDelegate

extension AssetsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let selectedAsset = viewModel.assets.object(at: indexPath.item)
        var oldAssetState = viewModel.getState(for: selectedAsset)
        
        let updateUI = {
            DispatchQueue.main.async { [weak self] in
                guard let sSelf = self, let newAssetState = self?.viewModel.getState(for: selectedAsset), newAssetState != oldAssetState else { return }
                oldAssetState = newAssetState
                if sSelf.viewModel.maxNumberOfSelection == 1, newAssetState == .selected {
                    sSelf.navigationController?.dismiss(animated: true) { [weak self] in
                        guard let sSelf = self else { return }
                        sSelf.didSelectImages?(sSelf.viewModel.getSelectedImages())
                    }
                } else {
                    sSelf.updateToolbar()
                    collectionView.performBatchUpdates({
                        collectionView.reloadItems(at: [indexPath])
                    }, completion: nil)
                }
            }
        }
        
        viewModel.selectedAsset(selectedAsset, updateUI: updateUI)
        
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
