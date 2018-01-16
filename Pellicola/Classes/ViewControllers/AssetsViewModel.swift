//
//  AssetsViewModel.swift
//  Pellicola
//
//  Created by Andrea Antonioni on 15/01/2018.
//

import Foundation
import Photos

class AssetsViewModel {
    
    var dataStorage: DataStorage
    var dataFetcher: DataFetcher
    
    private let assetCollection: PHAssetCollection
    
    var assetCollectionName: String? {
        return assetCollection.localizedTitle
    }
    
    let assets: PHFetchResult<PHAsset>
    
    var numberOfImages: Int {
        return assets.countOfAssets(with: .image)
    }
    
    var allowMultipleSelection: Bool {
        guard let limit = dataStorage.limit else { return true }
        return limit > 1
    }
    
    var numberOfSelectedAssets: Int {
        return dataStorage.images.count
    }
    
    var selectionLimit: UInt? {
        return dataStorage.limit
    }
    
    private let imageManager = PHCachingImageManager()
    
    init(dataStorage: DataStorage,
         dataFetcher: DataFetcher,
         assetCollection: PHAssetCollection) {
        self.dataStorage = dataStorage
        self.dataFetcher = dataFetcher
        self.assetCollection = assetCollection
        assets = PHAsset.fetchAssets(in: assetCollection, options: nil)
    }
    
    typealias CompletionHandler = (() -> Void)
    
    func selectedAsset(_ asset: PHAsset,
                       updateUI: @escaping CompletionHandler) {
        
        if dataStorage.containsImage(withIdentifier: asset.localIdentifier) {
            dataStorage.removeImage(withIdentifier: asset.localIdentifier)
            updateUI()
        } else if dataFetcher.containsRequest(withIdentifier: asset.localIdentifier) {
            dataFetcher.removeRequest(withIdentifier: asset.localIdentifier)
            updateUI()
        } else if dataStorage.isAvailableSpace {
            
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
    
}
