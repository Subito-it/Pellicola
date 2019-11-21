//
//  AlbumData.swift
//  Pods
//
//  Created by francesco bigagnoli on 20/07/2018.
//

import Photos

class AlbumData {
    let title: String
    let minAssetSize: CGSize
    
    var photoCount: Int {
        return PHAsset.fetchImageAssets(in: assetCollection).count
    }
    
    var thumbnail: UIImage?
    let assetCollection: PHAssetCollection
    
    var thumbnailAsset: PHAsset? {
        return PHAsset.fetchImageAssets(in: assetCollection).lastObject
    }
    
    init(title: String, assetCollection: PHAssetCollection, minAssetSize: CGSize = CGSize.zero) {
        self.title = title
        self.assetCollection = assetCollection
        self.minAssetSize = minAssetSize
    }
}
