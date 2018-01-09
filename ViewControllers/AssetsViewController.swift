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
    private var assetCollection: PHAssetCollection
    private var thumbnailSize: CGSize!
    
    private var fetchResult: PHFetchResult<PHAsset>
    private var dataStorage: DataStorage
    
    var doneBarButtonAction: (() -> Void)?
    var shouldTapOnAsset: (() -> Bool)?
    var didTapOnAsset: ((PHAsset) -> Void)?
    
    init(assetCollection: PHAssetCollection,
         dataStorage: DataStorage) {
        self.assetCollection = assetCollection
        self.fetchResult = PHAsset.fetchAssets(in: assetCollection, options: nil)
        self.dataStorage = dataStorage
        super.init(nibName: nil, bundle: Bundle.framework)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resetCachedAssets()
        setupNavigationBar()
        setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let numberOfImages = self.fetchResult.countOfAssets(with: .image)
        
        if numberOfImages > 0, isMovingToParentViewController {
            // when presenting as a .FormSheet on iPad, the frame is not correct until just after viewWillAppear:
            // dispatching to the main thread waits one run loop until the frame is update and the layout is complete
            DispatchQueue.main.async {
                let lastItemIndex = IndexPath(item: numberOfImages - 1, section: 0)
                self.collectionView.scrollToItem(at: lastItemIndex, at: .top, animated: false)
            }
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
    
    // MARK: - Setup
    
    private func setupNavigationBar() {
        title = assetCollection.localizedTitle
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                            target: self,
                                                            action: #selector(doneButtonTapped))
    }
    
    private func setupCollectionView() {
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        
        // Calculate the size of the cells
        let spaceBetweenCells = spaceBetweenPhotosInRow * CGFloat(numberOfPhotosForRow)
        let cellWidth = (UIScreen.main.bounds.width - spaceBetweenCells) / CGFloat(numberOfPhotosForRow)
        let cellSize = CGSize(width: cellWidth, height: cellWidth)
        layout.itemSize = cellSize
        
        // Determine the size of the thumbnails to request from the PHCachingImageManager
        let scale = UIScreen.main.scale
        thumbnailSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
        
        collectionView.allowsSelection = true
        
        if let maxNumberOfSelections = dataStorage.limit, maxNumberOfSelections > 1 {
            collectionView.allowsMultipleSelection = true
        } else {
            collectionView.allowsMultipleSelection = false
        }
        
        collectionView.register(UINib(nibName: AssetCell.identifier, bundle: Bundle.framework),
                                forCellWithReuseIdentifier: AssetCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    // MARK: - Navigation
    
    @objc func doneButtonTapped() {
        doneBarButtonAction?()
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
            .map { indexPath in fetchResult.object(at: indexPath.item) }
        let removedAssets = removedRects
            .flatMap { rect in collectionView.indexPathsForElements(in: rect) }
            .map { indexPath in fetchResult.object(at: indexPath.item) }
        
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
        return fetchResult.countOfAssets(with: .image)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AssetCell.identifier, for: indexPath) as? AssetCell else {
            assertionFailure("Error dequeuing photo cell")
            return UICollectionViewCell()
        }
        let asset = fetchResult.object(at: indexPath.item)
        
        // Request an image for the asset from the PHCachingImageManager.
        cell.assetIdentifier = asset.localIdentifier
        
        imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
            // The cell may have been recycled by the time this handler gets called;
            // set the cell's thumbnail image only if it's still showing the same asset.
            if cell.assetIdentifier == asset.localIdentifier {
                cell.thumbnailImage = image
            }
        })
        
        let result = dataStorage.assets.contains(where: {
            return $0.localIdentifier == cell.assetIdentifier
        })
        cell.setSelection(result)
        
        return cell
    }
    
}

// MARK: - UICollectionViewDelegate

extension AssetsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let tappedAsset = fetchResult.object(at: indexPath.item)
        
        if dataStorage.assets.contains(tappedAsset) {
            dataStorage.remove(tappedAsset)
        } else if dataStorage.isAvailableSpace {
            dataStorage.add(tappedAsset)
        }
        
        collectionView.reloadItems(at: [indexPath])
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCachedAssets()
    }
    
}
