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
    
    public func deleteAllImages() {
        guard let cacheFolder = cacheFolder else { return }
        try? fileManager.removeItem(at: cacheFolder)
    }
    
    private func fileURL(forIdentifier identifier: String) -> URL? {
        return cacheFolder?.appendingPathComponent(identifier + ".png")
    }
}
