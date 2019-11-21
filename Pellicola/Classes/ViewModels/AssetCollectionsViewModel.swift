//
//  AssetCollectionViewModel.swift
//  Pellicola
//
//  Created by Andrea Antonioni on 16/01/2018.
//

import Foundation
import Photos

class AssetCollectionsViewModel: NSObject {
    private var imagesDataStorage: ImagesDataStorage
    private var imagesDataFetcher: ImagesDataFetcher
        
    private let albumType: AlbumType
    private let secondLevelAlbumType: AlbumType?
    
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
    
    var minAssetSize: CGSize = CGSize.zero
    
    init(imagesDataStorage: ImagesDataStorage,
         imagesDataFetcher: ImagesDataFetcher,
         albumType: AlbumType,
         secondLevelAlbumType: AlbumType?) {

        self.imagesDataStorage = imagesDataStorage
        self.imagesDataFetcher = imagesDataFetcher
        
        self.albumType = albumType
        self.secondLevelAlbumType = secondLevelAlbumType

        fetchResult = PHFetchResult()

        super.init()
    
        imagesDataStorage.addObserver(self, forKeyPath: #keyPath(ImagesDataStorage.images), options: [], context: nil)
        PHPhotoLibrary.shared().register(self)
    }
    
    func fetchData(completion: (([AlbumData]) -> Void)?) {
        let albums = PHAssetCollection.fetch(withType: albumType)
        let albumsData = albums.map { albumData(fromAssetCollection: $0) }
        DispatchQueue.main.async {
            completion?(albumsData)
        }
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
        imagesDataStorage.removeObserver(self, forKeyPath: #keyPath(ImagesDataStorage.images))
    }
    
    func getSelectedImages(_ block: @escaping (([URL]) -> ())) {
        imagesDataStorage.getImagesOrderedBySelection { urls in
            block(urls)
        }
    }
    
    func cancel() {
        imagesDataFetcher.clear()
        imagesDataStorage.clear()
    }

    // MARK: Album Data creation
    
    private func albumData(fromAssetCollection assetCollection: PHAssetCollection) -> AlbumData {
        let albumData = AlbumData(title: assetCollection.localizedTitle ?? "", assetCollection: assetCollection, minAssetSize: minAssetSize)
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
        
        let albums = fetchResult.objects(at: IndexSet(0..<fetchResult.count))
        let albumsData = albums.map { albumData(fromAssetCollection: $0) }
        
        DispatchQueue.main.async { [weak self] in
            self?.onChangeAssetCollections?(albumsData)
        }
    }
}
