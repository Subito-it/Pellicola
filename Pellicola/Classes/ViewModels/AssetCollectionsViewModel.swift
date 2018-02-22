//
//  AssetCollectionViewModel.swift
//  Pellicola
//
//  Created by Andrea Antonioni on 16/01/2018.
//

import Foundation
import Photos

class AssetCollectionsViewModel: NSObject {
    
    private let assetCollectionType: PHAssetCollectionType = .smartAlbum
    private let smartAlbumSubtypes: [PHAssetCollectionSubtype]  = [.smartAlbumUserLibrary,
                                                                   .smartAlbumFavorites,
                                                                   .smartAlbumSelfPortraits,
                                                                   .smartAlbumScreenshots,
                                                                   .smartAlbumPanoramas]
    
    private var dataStorage: DataStorage
    private var dataFetcher: DataFetcher
    private(set) var albums: [PHAssetCollection]
    private var fetchResult: PHFetchResult<PHAssetCollection>
    
    var onChangeAssetCollections: (() -> Void)?
    var onChangeSelectedAssets: ((Int) -> Void)?
    
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
    
    init(dataStorage: DataStorage,
         dataFetcher: DataFetcher) {
        self.dataStorage = dataStorage
        self.dataFetcher = dataFetcher
        fetchResult = PHAssetCollection.fetchAssetCollections(with: assetCollectionType, subtype: .albumRegular, options: nil)
        albums = PHAssetCollection.fetch(assetCollectionType: assetCollectionType, sortedBy: smartAlbumSubtypes)
        super.init()
        
        dataStorage.addObserver(self, forKeyPath: #keyPath(DataStorage.images), options: [], context: nil)
        PHPhotoLibrary.shared().register(self)
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    func getSelectedImages() -> [UIImage] {
        return dataStorage.getImagesOrderedBySelection()
    }
    
    func stopDownloadingImages() {
        dataFetcher.clear()
    }

    // MARK: - KVO
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == #keyPath(DataStorage.images) else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        onChangeSelectedAssets?(numberOfSelectedAssets)
    }
}

// MARK: - PHPhotoLibraryChangeObserver

extension AssetCollectionsViewModel: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
        guard let changeDetails = changeInstance.changeDetails(for: fetchResult) else { return }
        fetchResult = changeDetails.fetchResultAfterChanges
        albums = PHAssetCollection.fetch(assetCollectionType: assetCollectionType, sortedBy: smartAlbumSubtypes)
        
        DispatchQueue.main.async { [weak self] in
            self?.onChangeAssetCollections?()
        }
    }
}
