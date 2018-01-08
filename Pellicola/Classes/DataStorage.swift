//
//  DataStorage.swift
//  Pellicola
//
//  Created by Andrea Antonioni on 08/01/2018.
//

import Foundation
import Photos

class DataStorage {
    
    private(set) var assets: [PHAsset] = []
    let limit: UInt?
    
    var isAvailableSpace: Bool {
        guard let limit = limit else { return true }
        return assets.count < limit
    }
    
    init(limit: UInt? = nil) {
        self.limit = limit
    }
    
    @discardableResult
    func add(_ asset: PHAsset) -> Bool {
        
        // TODO: - Verificare che l'oggetto non sia già presente
        
        guard let limit = limit, assets.count < limit else { return false }
        assets.append(asset)
        return true
    }
    
    func remove(_ asset: PHAsset) {
        
        let indefOfAssetToRemove = assets.index {
            return asset.localIdentifier == $0.localIdentifier
        }
        
        if let indefOfAssetToRemove = indefOfAssetToRemove {
            assets.remove(at: indefOfAssetToRemove)
        }
        
    }
    
    
    
}
