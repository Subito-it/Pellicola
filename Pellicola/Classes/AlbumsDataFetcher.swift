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
    private let bgSerialQueue = DispatchQueue(label: "albums_thumb_serial")
    
    init() {
        cachingImageManager.allowsCachingHighQualityImages = false
    }
    
    func fetchThumbnail(forAlbum album: AlbumData, size: CGSize, completion: @escaping (UIImage?) -> Void) -> DispatchWorkItem {
        let dispatchWorkItem = DispatchWorkItem { [weak self] in
            let fetchedAssets = PHAsset.fetchImageAssets(in: album.assetCollection)
            album.photoCount = fetchedAssets.count
            
            guard let lastAsset = fetchedAssets.lastObject else {
                DispatchQueue.main.async {
                    completion (nil)
                }
                
                return
            }
            
            let options = PHImageRequestOptions()
            options.isNetworkAccessAllowed = true
            options.deliveryMode = .fastFormat
            //From Apple's doc
            /* By default, this method executes asynchronously. If you call it from a background thread you may change the isSynchronous property of the options parameter to true to block the calling thread until either the requested image is ready or an error occurs, at which time Photos calls your result handler */
            options.isSynchronous = true
            
            self?.cachingImageManager.requestImage(for: lastAsset,
                                                   targetSize: size,
                                                   contentMode: .aspectFill,
                                                   options: options,
                                                   resultHandler: { (image, _) in
                                                    DispatchQueue.main.async {
                                                        completion(image)
                                                    }
            })
        }
        
        bgSerialQueue.async(execute: dispatchWorkItem)
        return dispatchWorkItem
    }
}
