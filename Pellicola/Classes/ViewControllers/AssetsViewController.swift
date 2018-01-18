//
//  ImagePickerViewController.swift
//  Pellicola
//
//  Created by Andrea Antonioni on 21/12/2017.
//

import UIKit
import Photos

private extension UICollectionView {
    func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.map { $0.indexPath }
    }
}

class AssetsViewController: UIViewController {

    @IBOutlet weak private var collectionView: UICollectionView!
    
    private let numberOfPhotosForRow: Int = 4
    private let spaceBetweenPhotosInRow: CGFloat = 1.0
    private let imageManager = PHCachingImageManager()
    private var previousPreheatRect = CGRect.zero
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateCachedAssets()
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
        
        if viewModel.maxNumberOfSelection > 1 {
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
        collectionView.allowsMultipleSelection = viewModel.maxNumberOfSelection > 1
        
        collectionView.register(UINib(nibName: AssetCell.identifier, bundle: Bundle.framework),
                                forCellWithReuseIdentifier: AssetCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
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
        
        guard viewModel.maxNumberOfSelection > 1,  viewModel.numberOfSelectedAssets > 0 else {
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
        previousPreheatRect = .zero
    }
    
    private func updateCachedAssets() {
        // Update only if the view is visible.
        guard isViewLoaded && view.window != nil else { return }
        
        // The preheat window is twice the height of the visible rect.
        let visibleRect = CGRect(origin: collectionView!.contentOffset, size: collectionView!.bounds.size)
        let preheatRect = visibleRect.insetBy(dx: 0, dy: -0.5 * visibleRect.height)
        
        // Update only if the visible area is significantly different from the last preheated area.
        let delta = abs(preheatRect.midY - previousPreheatRect.midY)
        guard delta > view.bounds.height / 3 else { return }
        
        // Compute the assets to start caching and to stop caching.
        let (addedRects, removedRects) = differencesBetweenRects(previousPreheatRect, preheatRect)
        let addedAssets = addedRects
            .flatMap { rect in collectionView.indexPathsForElements(in: rect) }
            .map { indexPath in viewModel.assets.object(at: indexPath.item) }
        let removedAssets = removedRects
            .flatMap { rect in collectionView.indexPathsForElements(in: rect) }
            .map { indexPath in viewModel.assets.object(at: indexPath.item) }
        
        // Update the assets the PHCachingImageManager is caching.
        imageManager.startCachingImages(for: addedAssets,
                                        targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
        imageManager.stopCachingImages(for: removedAssets,
                                       targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
        
        // Store the preheat rect to compare against in the future.
        previousPreheatRect = preheatRect
    }
    
    private func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
        if old.intersects(new) {
            var added = [CGRect]()
            if new.maxY > old.maxY {
                added += [CGRect(x: new.origin.x, y: old.maxY,
                                 width: new.width, height: new.maxY - old.maxY)]
            }
            if old.minY > new.minY {
                added += [CGRect(x: new.origin.x, y: new.minY,
                                 width: new.width, height: old.minY - new.minY)]
            }
            var removed = [CGRect]()
            if new.maxY < old.maxY {
                removed += [CGRect(x: new.origin.x, y: new.maxY,
                                   width: new.width, height: old.maxY - new.maxY)]
            }
            if old.minY < new.minY {
                removed += [CGRect(x: new.origin.x, y: old.minY,
                                   width: new.width, height: new.minY - old.minY)]
            }
            return (added, removed)
        } else {
            return ([new], [old])
        }
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
            assertionFailure("Error dequeuing photo cell")
            return UICollectionViewCell()
        }
        let asset = viewModel.assets.object(at: indexPath.item)
        
        // Request an image for the asset from the PHCachingImageManager.
        cell.assetIdentifier = asset.localIdentifier
        
        imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
            // The cell may have been recycled by the time this handler gets called;
            // set the cell's thumbnail image only if it's still showing the same asset.
            if cell.assetIdentifier == asset.localIdentifier {
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
                    UIView.performWithoutAnimation {
                        sSelf.collectionView.reloadItems(at: [indexPath])
                    }
                }
            }
        }
        
        viewModel.selectedAsset(selectedAsset,
                                updateUI: updateUI)
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCachedAssets()
    }
    
}
