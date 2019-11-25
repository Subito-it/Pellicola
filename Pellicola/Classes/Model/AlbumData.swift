//
//  AlbumData.swift
//  Pods
//
//  Created by francesco bigagnoli on 20/07/2018.
//

import Photos

class AlbumData {
    let title: String
    let assetCollection: PHAssetCollection
    let minAssetSize: CGSize
    
    var thumbnail: UIImage?
    
    private(set) lazy var assets: PHFetchResult<PHAsset> = {
        let result = PHAsset.fetchImageAssets(in: assetCollection, largerThan: minAssetSize)
        return result
    }()
    
    var photoCount: Int {
        return assets.count
    }
    
    var thumbnailAsset: PHAsset? {
        return assets.lastObject
    }
    
    init(title: String, assetCollection: PHAssetCollection, minAssetSize: CGSize = CGSize.zero) {
        self.title = title
        self.assetCollection = assetCollection
        self.minAssetSize = minAssetSize
    }
}
