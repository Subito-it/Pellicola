//
//  DataStorage.swift
//  Pellicola
//
//  Created by Andrea Antonioni on 08/01/2018.
//

import Foundation
import Photos

class DataStorage: NSObject {
    
    @objc dynamic private(set) var assets: [PHAsset] = []
    
    let limit: UInt?
    
    var isAvailableSpace: Bool {
        guard let limit = limit else { return true}
        return assets.count < limit
    }
    
    init(limit: UInt? = nil) {
        self.limit = limit
    }
    
    func add(_ asset: PHAsset) {
        
        // TODO: - Verificare che l'oggetto non sia già presente
        
        guard let limit = limit, assets.count < limit else { return }
        assets.append(asset)
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
