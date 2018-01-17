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
    
    private(set) var dataStorage: DataStorage
    
    private(set) var dataFetcher: DataFetcher
    
    private(set) var albums: [PHAssetCollection]
    
    private var fetchResult: PHFetchResult<PHAssetCollection>
    
    var onChange: (() -> Void)?
    
    init(dataStorage: DataStorage,
         dataFetcher: DataFetcher) {
        self.dataStorage = dataStorage
        self.dataFetcher = dataFetcher
        fetchResult = PHAssetCollection.fetchAssetCollections(with: assetCollectionType, subtype: .albumRegular, options: nil)
        albums = PHAssetCollection.fetch(assetCollectionType: assetCollectionType, sortedBy: smartAlbumSubtypes)
        super.init()
        PHPhotoLibrary.shared().register(self)
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
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
            self?.onChange?()
        }
        
    }
}
