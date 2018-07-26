//
//  PHAssetCollection+Extension.swift
//  Pellicola
//
//  Created by Andrea Antonioni on 16/01/2018.
//

import Foundation
import Photos

extension PHAssetCollection {
    class func fetch(withType albumType: AlbumType) -> [PHAssetCollection] {
        var allAlbums: [PHAssetCollection] = []
        
        //PHAssetCollection doesn't currently allow fetching for multiple subtypes at once, thus we should perform multiple fetches and merge results.
        //This is also the main reason for returning [PHAssetCollection] instead of PHFetchResult (which should have better performances).
        albumType.subtypes.forEach { subtype in
            let fetchResult = PHAssetCollection.fetchAssetCollections(with: albumType.type, subtype: subtype, options: nil)
            let albums = fetchResult.objects(at: IndexSet(0..<fetchResult.count))
            allAlbums += albums
        }
        
        return allAlbums
    }
}
