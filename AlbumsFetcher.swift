//
//  AlbumFetcher.swift
//  Pellicola
//
//  Created by Andrea Antonioni on 20/12/2017.
//

import Foundation
import Photos

final class AlbumsFetcher {
    
    private init() { }
    
    static func fetch(assetCollectionType type: PHAssetCollectionType,
                       sortedBy subtypes: [PHAssetCollectionSubtype]) -> [PHAssetCollection] {
        var albums: [PHAssetCollection] = []
        let fetchedAlbum = fetch(assetCollectionType: .smartAlbum, filteredBy: subtypes)
        subtypes.forEach {
            albums += fetchedAlbum[$0] ?? []
        }
        
        return albums
    }
    
    private static func fetch(assetCollectionType type: PHAssetCollectionType,
                              filteredBy subtypes: [PHAssetCollectionSubtype]) -> [PHAssetCollectionSubtype: [PHAssetCollection]] {
        
        var filteredSmartAlbums: [PHAssetCollection] = []
        
        PHAssetCollection
            .fetchAssetCollections(with: type, subtype: .any, options: nil)
            .enumerateObjects { (album, _, _) in
                guard subtypes.contains(album.assetCollectionSubtype) else { return }
                guard PHAsset.fetchAssets(in: album, options: nil).count > 0 else { return }
                filteredSmartAlbums.append(album)
        }
        
        return Dictionary(grouping: filteredSmartAlbums,
                          by: {
                            print($0.assetCollectionSubtype)
                            return $0.assetCollectionSubtype
                            
        })
    }
}
