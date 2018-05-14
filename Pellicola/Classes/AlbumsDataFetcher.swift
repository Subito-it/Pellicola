//
//  AlbumsDataFetcher.swift
//  Pellicola
//
//  Created by francesco bigagnoli on 10/05/2018.
//

import Foundation
import Photos

class AlbumsDataFetcher {    
    private let cachingImageManager = PHCachingImageManager()
    
    init() {
        cachingImageManager.allowsCachingHighQualityImages = false
    }
    
    func fetchThumbnail(forAlbum album: AlbumData, size: CGSize, completion: @escaping (UIImage?) -> Void) -> DispatchWorkItem {
        let dispatchWorkItem = DispatchWorkItem { [weak self] in
            let fetchedAssets = PHAsset.fetchImageAssets(in: album.assetCollection)
            album.photoCount = fetchedAssets.count
            
            guard let lastAsset = fetchedAssets.lastObject else {
                completion (nil)
                return
            }
            
            let options = PHImageRequestOptions()
            options.isNetworkAccessAllowed = true
            options.deliveryMode = .fastFormat
            
            self?.cachingImageManager.requestImage(for: lastAsset,
                                                   targetSize: size,
                                                   contentMode: .aspectFill,
                                                   options: options,
                                                   resultHandler: { (image, _) in
                                                    completion(image)
            })
        }
        
        DispatchQueue.global(qos: .userInitiated).async(execute: dispatchWorkItem)
        return dispatchWorkItem
    }
}
