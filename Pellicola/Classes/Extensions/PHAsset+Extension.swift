//
//  PHAsset+Extension.swift
//  Pellicola
//
//  Created by francesco bigagnoli on 14/02/2018.
//

import Foundation
import Photos

extension PHAsset {
    class func fetchImageAssets(in collection: PHAssetCollection) -> PHFetchResult<PHAsset> {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        return PHAsset.fetchAssets(in: collection, options: fetchOptions)
    }
}

