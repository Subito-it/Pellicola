//
//  AlbumData.swift
//  Pods
//
//  Created by francesco bigagnoli on 20/07/2018.
//

import Photos

class AlbumData {
    let title: String
    
    var photoCount: Int {
        return PHAsset.fetchImageAssets(in: assetCollection).count
    }
    
    var thumbnail: UIImage?
    let assetCollection: PHAssetCollection
    
    var thumbnailAsset: PHAsset? {
        return PHAsset.fetchImageAssets(in: assetCollection).lastObject
    }
    
    init(title: String, assetCollection: PHAssetCollection) {
        self.title = title
        self.assetCollection = assetCollection
    }
}
