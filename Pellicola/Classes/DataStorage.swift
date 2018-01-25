//
//  DataStorage.swift
//  Pellicola
//
//  Created by Andrea Antonioni on 08/01/2018.
//

import Foundation
import Photos

class OrderedImage: NSObject, Comparable {
    let image: UIImage
    let index: Int
    init(image: UIImage, index: Int) {
        self.image = image
        self.index = index
    }
    
    static func <(lhs: OrderedImage, rhs: OrderedImage) -> Bool {
        return lhs.index < rhs.index
    }
}

class DataStorage: NSObject {
    
    @objc dynamic private(set) var images: [String: OrderedImage] = [String: OrderedImage]()
    private var index = 0
    
    let limit: Int?
    
    init(limit: Int?) {
        self.limit = limit
    }
    
    func addImage(_ image: UIImage, withIdentifier identifier: String) {
        
        guard images[identifier] == nil else { return }
        
        if let limit = limit, images.count >= limit { return }
        
        images[identifier] = OrderedImage(image: image, index: index)
        index += 1
    }
    
    func removeImage(withIdentifier identifier: String) {
        
        guard images[identifier] != nil else { return }
        
        images.removeValue(forKey: identifier)
        index -= 1
        
    }
    
    func containsImage(withIdentifier identifier: String) -> Bool {
        return images[identifier] != nil
    }
    
    func getImagesOrderedBySelection() -> [UIImage] {
        return images.values
            .sorted(by: <)
            .flatMap {
            return $0.image
        }
    }
    
    func clearAll() {
        images = [String: OrderedImage]()
    }
    
}
