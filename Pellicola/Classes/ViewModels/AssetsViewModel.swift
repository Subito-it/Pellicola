//
//  AssetsViewModel.swift
//  Pellicola
//
//  Created by Andrea Antonioni on 15/01/2018.
//

import Foundation
import Photos

class AssetsViewModel {
    
    private var dataStorage: DataStorage
    private var dataFetcher: DataFetcher
    
    private let assetCollection: PHAssetCollection
    private var dataStorageObservation: NSKeyValueObservation?
    private let imageManager = PHCachingImageManager()
    
    let assets: PHFetchResult<PHAsset>
    
    var onChangeSelectedAssets: ((Int) -> Void)?
    
    var assetCollectionName: String? {
        return assetCollection.localizedTitle
    }
    
    var numberOfImages: Int {
        return assets.countOfAssets(with: .image)
    }
    
    var maxNumberOfSelection: UInt {
        return dataStorage.limit
    }
    
    var numberOfSelectedAssets: Int {
        return dataStorage.images.count
    }
    
    var isDownloadingImages: Bool {
        return dataFetcher.count != 0
    }
    
    var toolbarText: String {
        
        guard maxNumberOfSelection != UInt.max else {
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
        
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        assets = PHAsset.fetchAssets(in: assetCollection, options: options)
        
        dataStorageObservation = dataStorage.observe(\DataStorage.images) { [weak self] _, _ in
            guard let sSelf = self else { return }
            sSelf.onChangeSelectedAssets?(sSelf.numberOfSelectedAssets)
        }
    }
    
    typealias CompletionHandler = (() -> Void)
    
    func selectedAsset(_ asset: PHAsset,
                       updateUI: @escaping CompletionHandler) {
        
        let numberOfSelectableAssets = Int(dataStorage.limit) - dataStorage.images.count - dataFetcher.count
        
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
