//
//  AssetsViewModel.swift
//  Pellicola
//
//  Created by Andrea Antonioni on 15/01/2018.
//

import Foundation
import Photos

class AssetsViewModel: NSObject {
    
    private var dataStorage: DataStorage
    private var dataFetcher: DataFetcher
    
    private let assetCollection: PHAssetCollection
    private var dataStorageObservation: NSKeyValueObservation?
    private let imageManager = PHCachingImageManager()
    
    var assets: PHFetchResult<PHAsset>
    
    var onChangeAssets: (() -> Void)?
    var onChangeSelectedAssets: ((Int) -> Void)?
    
    var assetCollectionName: String? {
        return assetCollection.localizedTitle
    }
    
    var numberOfImages: Int {
        return assets.countOfAssets(with: .image)
    }
    
    var maxNumberOfSelection: Int? {
        return dataStorage.limit
    }
    
    var isSingleSelection: Bool {
        guard let maxNumberOfSelection = maxNumberOfSelection else { return false }
        return maxNumberOfSelection == 1
    }
    
    var numberOfSelectedAssets: Int {
        return dataStorage.images.count
    }
    
    var isDownloadingImages: Bool {
        return dataFetcher.count != 0
    }
    
    var toolbarText: String {
        
        guard let maxNumberOfSelection = maxNumberOfSelection else {
            return ""
        }
        
        return String(format: NSLocalizedString("selected_assets", bundle:  Bundle.framework, comment: ""),
               numberOfSelectedAssets,
               maxNumberOfSelection)
    }
    
    init(dataStorage: DataStorage,
         dataFetcher: DataFetcher,
         assetCollection: PHAssetCollection) {
        self.dataStorage = dataStorage
        self.dataFetcher = dataFetcher
        self.assetCollection = assetCollection
        
        assets = PHAsset.fetchAssets(in: assetCollection, options: nil)
        
        super.init()
        
        dataStorageObservation = dataStorage.observe(\DataStorage.images) { [weak self] _, _ in
            guard let sSelf = self else { return }
            sSelf.onChangeSelectedAssets?(sSelf.numberOfSelectedAssets)
        }
        PHPhotoLibrary.shared().register(self)
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    func selectedAsset(_ asset: PHAsset,
                       updateUI: @escaping (() -> Void)) {
        
        let limit = maxNumberOfSelection ?? Int.max
        let numberOfSelectableAssets = limit - dataStorage.images.count - dataFetcher.count
        
        if dataStorage.containsImage(withIdentifier: asset.localIdentifier) {
            dataStorage.removeImage(withIdentifier: asset.localIdentifier)
            updateUI()
        } else if dataFetcher.containsRequest(withIdentifier: asset.localIdentifier) {
            dataFetcher.removeRequest(withIdentifier: asset.localIdentifier)
            updateUI()
        } else if numberOfSelectableAssets > 0 {
            
            dataFetcher.requestImage(for: asset, onProgress: updateUI, onComplete: { [weak self] image in
                self?.dataStorage.addImage(image, withIdentifier: asset.localIdentifier)
                updateUI()
            })

        }
        
    }
    
    func getState(for asset: PHAsset) -> AssetCell.State {
        if dataStorage.containsImage(withIdentifier: asset.localIdentifier) {
            return .selected
        } else if dataFetcher.containsRequest(withIdentifier: asset.localIdentifier) {
            return .loading
        } else {
            return .normal
        }
    }
    
    func getSelectedImages() -> [UIImage] {
        return dataStorage.getImagesOrderedBySelection()
    }
    
    func stopDownloadingImages() {
        dataFetcher.clear()
    }
    
}

// MARK: - PHPhotoLibraryChangeObserver

extension AssetsViewModel: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
        guard let changeDetails = changeInstance.changeDetails(for: assets) else { return }
        
        assets = changeDetails.fetchResultAfterChanges
        
        (changeDetails.removedObjects + changeDetails.changedObjects).forEach {
            dataFetcher.removeRequest(withIdentifier: $0.localIdentifier)
            dataStorage.removeImage(withIdentifier: $0.localIdentifier)
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.onChangeAssets?()
        }
        
    }
}
