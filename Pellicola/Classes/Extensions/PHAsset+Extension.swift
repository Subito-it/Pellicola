//
//  PHAsset+Extension.swift
//  Pellicola
//
//  Created by francesco bigagnoli on 14/02/2018.
//

import Foundation
import Photos

extension PHAsset {
    class func fetchImageAssets(in collection: PHAssetCollection, largerThan minSize: CGSize? = nil) -> PHFetchResult<PHAsset> {
        let fetchOptions = PHFetchOptions()
        let imageTypePredicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        var subPredicates = [imageTypePredicate]
        if let minSize = minSize, minSize.width > 0, minSize.height > 0 {
            let minSizePredicate = NSPredicate(format: "pixelWidth >= %f AND pixelHeight >= %f", minSize.width, minSize.height)
            subPredicates.append(minSizePredicate)
        }

        fetchOptions.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: subPredicates)
        return PHAsset.fetchAssets(in: collection, options: fetchOptions)
    }
}

