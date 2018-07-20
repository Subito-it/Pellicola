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
    
    var photoCount: Int {
        return PHAsset.fetchImageAssets(in: assetCollection).count
    }
    
    var thumbnail: UIImage?
    let assetCollection: PHAssetCollection
    
    var thumbnailAsset: PHAsset? {
        return PHAsset.fetchImageAssets(in: assetCollection).firstObject
    }
    
    init(title: String, assetCollection: PHAssetCollection) {
        self.title = title
        self.assetCollection = assetCollection
    }
}

class AssetCollectionsViewModel: NSObject {
    private var imagesDataStorage: ImagesDataStorage
    private var imagesDataFetcher: ImagesDataFetcher
        
    private let albumType: AlbumType
    private let secondLevelAlbumType: AlbumType?
    
    private(set) var firstLevelAlbums: [PHAssetCollection]
    private(set) var secondLevelAlbums: [PHAssetCollection]?
    
    private var fetchResult: PHFetchResult<PHAssetCollection>
    
    var hasSecondLevel: Bool {
        return secondLevelAlbumType != nil
    }
    
    var onChangeAssetCollections: (([AlbumData]) -> Void)?
    var onChangeSelectedAssets: ((Int) -> Void)?
    
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
         albumType: AlbumType,
         secondLevelAlbumType: AlbumType?) {

        self.imagesDataStorage = imagesDataStorage
        self.imagesDataFetcher = imagesDataFetcher
        
        self.albumType = albumType
        self.secondLevelAlbumType = secondLevelAlbumType

        fetchResult = PHFetchResult()
        firstLevelAlbums = []

        super.init()
    
        firstLevelAlbums = PHAssetCollection.fetch(withType: albumType)
        let albumsData = firstLevelAlbums.map { albumData(fromAssetCollection: $0) }
        DispatchQueue.main.async { [weak self] in
            self?.onChangeAssetCollections?(albumsData)
        }

        imagesDataStorage.addObserver(self, forKeyPath: #keyPath(ImagesDataStorage.images), options: [], context: nil)
        PHPhotoLibrary.shared().register(self)
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
        imagesDataStorage.removeObserver(self, forKeyPath: #keyPath(ImagesDataStorage.images))
    }
    
    func getSelectedImages() -> [UIImage] {
        return imagesDataStorage.getImagesOrderedBySelection()
    }
    
    func stopDownloadingImages() {
        imagesDataFetcher.clear()
    }

    // MARK: Album Data creation
    
    private func albumData(fromAssetCollection assetCollection: PHAssetCollection) -> AlbumData {
        let albumData = AlbumData(title: assetCollection.localizedTitle ?? "", assetCollection: assetCollection)
        return albumData
    }
    
    // MARK: - KVO
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == #keyPath(ImagesDataStorage.images) else {
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
