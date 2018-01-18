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
    private var dataStorageObservation: NSKeyValueObservation?
    
    var onChangeAssetCollections: (() -> Void)?
    var onChangeSelectedAssets: ((Int) -> Void)?
    
    var maxNumberOfSelection: UInt {
        return dataStorage.limit
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
        
        dataStorageObservation = dataStorage.observe(\DataStorage.images) { [weak self] _, _ in
            guard let sSelf = self else { return }
            sSelf.onChangeSelectedAssets?(sSelf.numberOfSelectedAssets)
        }
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
    
}

// MARK: - PHPhotoLibraryChangeObserver

extension AssetCollectionsViewModel: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
        if let changeDetails = changeInstance.changeDetails(for: fetchResult) {
            fetchResult = changeDetails.fetchResultAfterChanges
            albums = PHAssetCollection.fetch(assetCollectionType: assetCollectionType, sortedBy: smartAlbumSubtypes)
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.onChangeAssetCollections?()
        }
        
    }
}
