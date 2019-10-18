//
//  FileHandler.swift
//  Pellicola
//
//  Created by marco.rossi on 18/10/2019.
//

import Foundation

final class FileHandler {
    let fileManager: FileManager
    
    init(fileManager: FileManager = FileManager.default) {
        self.fileManager = fileManager
    }
    
    func fileURL(forIdentifier identifier: String) -> URL? {
        return cacheFolder()?.appendingPathComponent(identifier + ".png")
    }
    
    func saveImage(_ image: UIImage, at url: URL) throws {
        do {
            if let imageData = image.pngData() {
                try createSubfoldersBeforeCreatingFile(at: url)
                try imageData.write(to: url, options: .atomic)
            }
        } catch {
            throw error
        }
    }
    
    func deleteImage(at url: URL) throws {
        do {
            try fileManager.removeItem(at: url)
        } catch {
            throw error
        }
    }
    
    func deleteAllImages() {
        guard let cacheFolder = self.cacheFolder() else { return }
        try? fileManager.removeItem(at: cacheFolder)
    }
    
    private func cacheFolder() -> URL? {
        guard let cacheDirURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else { return nil }
        return cacheDirURL.appendingPathComponent("Pellicola_Images")
    }
    
    private func createSubfoldersBeforeCreatingFile(at url: URL) throws {
        do {
            let subfolderUrl = url.deletingLastPathComponent()
            var subfolderExists = false
            var isDirectory: ObjCBool = false
            if fileManager.fileExists(atPath: subfolderUrl.path, isDirectory: &isDirectory) {
                if isDirectory.boolValue {
                    subfolderExists = true
                }
            }
            if !subfolderExists {
                try fileManager.createDirectory(at: subfolderUrl, withIntermediateDirectories: true, attributes: nil)
            }
        } catch {
            throw error
        }
    }
}
