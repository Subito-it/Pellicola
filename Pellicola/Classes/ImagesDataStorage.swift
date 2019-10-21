//
//  ImagesDataStorage.swift
//  Pellicola
//
//  Created by Andrea Antonioni on 08/01/2018.
//

import Foundation
import Photos

class OrderedImage: NSObject, Comparable {
    var url: URL?
    let index: Int
    init(index: Int) {
        self.index = index
    }
    
    static func <(lhs: OrderedImage, rhs: OrderedImage) -> Bool {
        return lhs.index < rhs.index
    }
}

class ImagesDataStorage: NSObject {
    
    @objc dynamic private(set) var images = [String: OrderedImage]()
    private var index = 0
    
    let limit: Int?
    private let fileQueue = DispatchQueue(label: "com.subito.pellicola.files")
    private let fileHandler = PellicolaFileHandler()
    private var fileActions = [DispatchWorkItem]()
    
    init(limit: Int?) {
        self.limit = limit
    }
    
    func addImage(_ image: UIImage, withIdentifier identifier: String) {
        
        guard images[identifier] == nil else { return }
        
        if let limit = limit, images.count >= limit { return }
        
        let orderedImage = OrderedImage(index: index)
        images[identifier] = orderedImage
        index += 1
        
        let saveItem = DispatchWorkItem { [weak self] in
            orderedImage.url = self?.fileHandler.saveImage(image, named: UUID().uuidString)
        }
        fileActions.append(saveItem)
        
        fileQueue.async(execute: saveItem)
    }
    
    func removeImage(withIdentifier identifier: String) {
        
        guard let image = images[identifier] else { return }
        
        images.removeValue(forKey: identifier)
        index -= 1
        
        guard let url = image.url else { return }
        
        let deleteItem = DispatchWorkItem { [weak self] in
            self?.fileHandler.deleteImage(at: url)
        }
        fileActions.append(deleteItem)
        
        fileQueue.async(execute: deleteItem)
    }
    
    func containsImage(withIdentifier identifier: String) -> Bool {
        return images[identifier] != nil
    }
    
    func getImagesOrderedBySelection(block: @escaping (([URL]) -> ())) {
        fileQueue.async { [weak self] in
            guard let self = self else { return }
            let orderedImages = self.images.values.sorted(by: <)
            let urls = orderedImages.compactMap { $0.url }
            DispatchQueue.main.async {
                block(urls)
            }
            self.clear()
        }
    }
    
    func clear() {
        images.removeAll()
        fileActions.forEach { $0.cancel() }
        fileActions.removeAll()
    }
}
