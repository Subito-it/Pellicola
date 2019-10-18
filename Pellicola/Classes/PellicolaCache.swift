//
//  PellicolaCache.swift
//  Pellicola
//
//  Created by marco.rossi on 17/10/2019.
//

import Foundation

public final class PellicolaCache: NSObject {
    private let fileHandler = FileHandler()
    
    @objc public func clear() {
        DispatchQueue.global(qos: .utility).async {
            self.fileHandler.deleteAllImages()
        }
    }
}
