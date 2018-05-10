//
//  DataFetcher.swift
//  Pellicola
//
//  Created by Andrea Antonioni on 15/01/2018.
//

import Foundation
import Photos

class ImagesDataFetcher {
    
    private let imageManager = PHCachingImageManager()
    
    private var requestsID: [String: PHImageRequestID] = [String: PHImageRequestID]()
    
    var count: Int {
        return requestsID.count
    }
    
    func requestImage(for asset: PHAsset, onProgress: @escaping () -> Void, onComplete: ((UIImage) -> Void)?) {
        
        guard requestsID[asset.localIdentifier] == nil else { return }
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.isNetworkAccessAllowed = true
        requestOptions.progressHandler = { (progress, error, stop, info) in
            onProgress()
        }
        
        let request = imageManager.requestImageData(for: asset, options: requestOptions, resultHandler: { [weak self] (imageData, _, _, info) in
            
            if let imageData = imageData, let image = UIImage(data: imageData) {
                self?.requestsID.removeValue(forKey: asset.localIdentifier)
                onComplete?(image)
            }
            
        })
        
        requestsID[asset.localIdentifier] = request
        
    }
    
    func clear() {
        requestsID.values.forEach(imageManager.cancelImageRequest)
        requestsID.removeAll()
    }
    
    func removeRequest(withIdentifier identifier: String) {
        guard let request = requestsID[identifier] else { return }
        imageManager.cancelImageRequest(request)
        requestsID.removeValue(forKey: identifier)
    }
    
    func containsRequest(withIdentifier identifier: String) -> Bool {
        return requestsID[identifier] != nil
    }
    
}
