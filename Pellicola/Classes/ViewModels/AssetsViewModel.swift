//
//  AssetsViewModel.swift
//  Pellicola
//
//  Created by Andrea Antonioni on 15/01/2018.
//

import Foundation
import Photos

class AssetsViewModel: NSObject {
    
    private var imagesDataStorage: ImagesDataStorage
    private var imagesDataFetcher: ImagesDataFetcher
    
    private let imageManager = PHCachingImageManager()
    
    var assets: PHFetchResult<PHAsset>
    
    var onChangeAssets: (() -> Void)?
    var onChangeSelectedAssets: ((Int) -> Void)?
    
    var assetCollectionName: String?
    
    var numberOfImages: Int {
        return assets.count
    }
    
    var maxNumberOfSelection: Int? {
        return imagesDataStorage.limit
    }
    
    var isSingleSelection: Bool {
        guard let maxNumberOfSelection = maxNumberOfSelection else { return false }
        return maxNumberOfSelection == 1
    }
    
    var numberOfSelectedAssets: Int {
        return imagesDataStorage.images.count
    }
    
    var isDownloadingImages: Bool {
        return imagesDataFetcher.count != 0
    }
    
    init(imagesDataStorage: ImagesDataStorage,
         imagesDataFetcher: ImagesDataFetcher,
         albumData: AlbumData) {
        self.imagesDataStorage = imagesDataStorage
        self.imagesDataFetcher = imagesDataFetcher
    
        assetCollectionName = albumData.assetCollection.localizedTitle
        assets = PHAsset.fetchImageAssets(in: albumData.assetCollection)
    
        super.init()
        
        imagesDataStorage.addObserver(self, forKeyPath: #keyPath(ImagesDataStorage.images), options: [], context: nil)
        PHPhotoLibrary.shared().register(self)
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
        imagesDataStorage.removeObserver(self, forKeyPath: #keyPath(ImagesDataStorage.images))
    }
    
    func select(_ asset: PHAsset,
                     onDownload: @escaping () -> Void,
                     onUpdate: @escaping () -> Void,
                     onLimit: @escaping () -> Void) {
        let limit = maxNumberOfSelection ?? Int.max
        let numberOfSelectableAssets = limit - imagesDataStorage.images.count - imagesDataFetcher.count
        
        if imagesDataStorage.containsImage(withIdentifier: asset.localIdentifier) {
            imagesDataStorage.removeImage(withIdentifier: asset.localIdentifier)
            onUpdate()
        } else if imagesDataFetcher.containsRequest(withIdentifier: asset.localIdentifier) {
            imagesDataFetcher.removeRequest(withIdentifier: asset.localIdentifier)
            onUpdate()
        } else if numberOfSelectableAssets > 0 {
            
            imagesDataFetcher.requestImage(for: asset, onProgress: onDownload, onComplete: { [weak self] image in
                self?.imagesDataStorage.addImage(image, withIdentifier: asset.localIdentifier)
                onUpdate()
            })
            
        } else {
            onLimit()
        }
    }
    
    func getState(for asset: PHAsset) -> AssetCell.State {
        if imagesDataStorage.containsImage(withIdentifier: asset.localIdentifier) {
            return .selected
        } else if imagesDataFetcher.containsRequest(withIdentifier: asset.localIdentifier) {
            return .loading
        } else {
            return .normal
        }
    }
    
    func getSelectedImages() -> [UIImage] {
        return imagesDataStorage.getImagesOrderedBySelection()
    }
    
    func stopDownloadingImages() {
        imagesDataFetcher.clear()
    }
 
    // MARK: - KVO
    override  func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == #keyPath(ImagesDataStorage.images) else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        onChangeSelectedAssets?(numberOfSelectedAssets)
    }
}
// MARK: - PHPhotoLibraryChangeObserver


extension AssetsViewModel: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
        guard let changeDetails = changeInstance.changeDetails(for: assets) else { return }
        
        assets = changeDetails.fetchResultAfterChanges
        
        (changeDetails.removedObjects + changeDetails.changedObjects).forEach {
            imagesDataFetcher.removeRequest(withIdentifier: $0.localIdentifier)
            imagesDataStorage.removeImage(withIdentifier: $0.localIdentifier)
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.onChangeAssets?()
        }
    }
}
