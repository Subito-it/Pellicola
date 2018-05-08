//
//  AssetCollectionViewModel.swift
//  Pellicola
//
//  Created by Andrea Antonioni on 16/01/2018.
//

import Foundation
import Photos

class AlbumData {
    let title: String
    var photoCount: Int?
    var thumbnail: UIImage?
    let assetCollection: PHAssetCollection
    
    init(title: String, assetCollection: PHAssetCollection) {
        self.title = title
        self.assetCollection = assetCollection
    }
}

class AssetCollectionsViewModel: NSObject {
    private var dataStorage: DataStorage
    private var dataFetcher: DataFetcher
    
    private(set) var collectionTypes: [PHAssetCollectionType]
    private(set) var firstLevelSubtypes: [PHAssetCollectionSubtype]
    private(set) var secondLevelSubtypes: [PHAssetCollectionSubtype]?
    
    private(set) var firstLevelAlbums: [PHAssetCollection]
    private(set) var secondLevelAlbums: [PHAssetCollection]?
    
    private var fetchResult: PHFetchResult<PHAssetCollection>
    
    var onChangeAssetCollections: (([AlbumData]) -> Void)?
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
         dataFetcher: DataFetcher,
         collectionTypes: [PHAssetCollectionType],
         firstLevelSubtypes: [PHAssetCollectionSubtype],
         secondLevelSubtypes: [PHAssetCollectionSubtype]? = nil) {
        self.dataStorage = dataStorage
        self.dataFetcher = dataFetcher

        self.collectionTypes = collectionTypes
        self.firstLevelSubtypes = firstLevelSubtypes
        self.secondLevelSubtypes = secondLevelSubtypes
        fetchResult = PHAssetCollection.fetchAssetCollections(with: collectionTypes.first ?? .smartAlbum, subtype: .albumRegular, options: nil)
        firstLevelAlbums = []

        super.init()
    
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let sSelf = self else { return }
            sSelf.firstLevelAlbums = PHAssetCollection.fetch(assetCollectionTypes: collectionTypes, sortedBy: firstLevelSubtypes)
            
            let albumsData = sSelf.firstLevelAlbums.map { sSelf.albumData(fromAssetCollection: $0) }
            DispatchQueue.main.async {
                self?.onChangeAssetCollections?(albumsData) //TODO: specialize this mehtod to only reload one section (the 1st in this case) instead of the whole TV
            }
            
        }
        
        dataStorage.addObserver(self, forKeyPath: #keyPath(DataStorage.images), options: [], context: nil)
        PHPhotoLibrary.shared().register(self)
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
        dataStorage.removeObserver(self, forKeyPath: #keyPath(DataStorage.images))
    }
    
    func getSelectedImages() -> [UIImage] {
        return dataStorage.getImagesOrderedBySelection()
    }
    
    func stopDownloadingImages() {
        dataFetcher.clear()
    }

    // MARK: Album Data creation
    
    private func albumData(fromAssetCollection assetCollection: PHAssetCollection) -> AlbumData {
        let albumData = AlbumData(title: assetCollection.localizedTitle ?? "", assetCollection: assetCollection)
        //TODO: how to fetch thumb and image count?
        return albumData
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
        
        firstLevelAlbums = PHAssetCollection.fetch(assetCollectionTypes: collectionTypes, sortedBy: firstLevelSubtypes)
        let albumsData = firstLevelAlbums.map { albumData(fromAssetCollection: $0) }
        
        DispatchQueue.main.async { [weak self] in
            self?.onChangeAssetCollections?(albumsData)
        }
    }
}
