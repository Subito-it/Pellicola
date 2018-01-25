//
//  DetailAssetViewModel.swift
//  Pellicola
//
//  Created by Andrea Antonioni on 24/01/2018.
//

import Foundation
import Photos

class DetailAssetViewModel {
    
    private let asset: PHAsset
    
    private lazy var imageManager = PHImageManager()
    
    init(asset: PHAsset) {
        self.asset = asset
    }
    
    func download(size: CGSize, onReceiveImage: @escaping (UIImage) -> Void) {
        imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: nil) { (image, info) in
            guard let image = image else { return }
            onReceiveImage(image)
        }
    }
    
}
