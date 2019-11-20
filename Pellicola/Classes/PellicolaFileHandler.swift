//
//  PellicolaFileHandler.swift
//  Pellicola
//
//  Created by marco.rossi on 18/10/2019.
//

import Foundation

@objcMembers
public final class PellicolaFileHandler: NSObject {
    private let fileManager: FileManager
    
    public static func defaultHandler() -> PellicolaFileHandler {
        return PellicolaFileHandler()
    }
    
    public init(fileManager: FileManager = FileManager.default) {
        self.fileManager = fileManager
    }
    
    private var cacheFolder: URL? {
        guard let cacheDirURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            assertionFailure("Failed on retrieving caches directory")
            return nil
        }
        return cacheDirURL.appendingPathComponent("Pellicola_Images")
    }
    
    public func saveImage(_ image: UIImage, named: String) -> URL? {
        guard let url = fileURL(forIdentifier: named), let imageData = image.pngData() else { return nil }
        do {
            let subfolderUrl = url.deletingLastPathComponent()
            try fileManager.createDirectory(at: subfolderUrl, withIntermediateDirectories: true, attributes: nil)
            try imageData.write(to: url, options: .atomic)
            return url
        } catch {
            return nil
        }
    }
    
    public func deleteImage(at url: URL) {
        try? fileManager.removeItem(at: url)
    }
    
    @objc(deleteImagesOlderThan:)
    public func deleteImages(olderThan expirationDate: Date = Date()) {
        guard let cacheFolder = cacheFolder,
            let fileUrls = try? fileManager.contentsOfDirectory(at: cacheFolder, includingPropertiesForKeys: nil, options: [])
            else { return }
        
        let expiredImages = fileUrls.filter { file in
            guard let attributes = try? fileManager.attributesOfItem(atPath: file.path) as NSDictionary,
                let creationDate = attributes.fileModificationDate() else {
                    return false
            }
            
            return expirationDate > creationDate
        }
        
        expiredImages.forEach { try? fileManager.removeItem(at: $0) }
    }
    
    private func fileURL(forIdentifier identifier: String) -> URL? {
        return cacheFolder?.appendingPathComponent(identifier + ".png")
    }
}
