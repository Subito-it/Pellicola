//
//  PHAssetCollection+Extension.swift
//  Pellicola
//
//  Created by Andrea Antonioni on 16/01/2018.
//

import Foundation
import Photos

extension PHAssetCollection {
    
    class func fetch(assetCollectionTypes types: [PHAssetCollectionType],
                     sortedBy subtypes: [PHAssetCollectionSubtype]) -> [PHAssetCollection] {
        var albums: [PHAssetCollection] = []
        var fetchedAlbum: [PHAssetCollectionSubtype: [PHAssetCollection]] = [:]
        types.forEach {
            fetchedAlbum.merge(fetch(assetCollectionType: $0, filteredBy: subtypes), uniquingKeysWith: +)
        }
        subtypes.forEach {
            albums += fetchedAlbum[$0] ?? []
        }
        
        return albums
    }
    
    private class func fetch(assetCollectionType type: PHAssetCollectionType,
                             filteredBy subtypes: [PHAssetCollectionSubtype]) -> [PHAssetCollectionSubtype: [PHAssetCollection]] {
        
        var filteredSmartAlbums: [PHAssetCollection] = []
        
        PHAssetCollection
            .fetchAssetCollections(with: type, subtype: .any, options: nil)
            .enumerateObjects { (album, _, _) in
                guard subtypes.contains(album.assetCollectionSubtype) else { return }
                guard PHAsset.fetchImageAssets(in: album).count > 0 else { return }
                filteredSmartAlbums.append(album)
        }
        
        return Dictionary(grouping: filteredSmartAlbums,
                          by: { return $0.assetCollectionSubtype })
    }
    
}
