//
//  PellicolaCache.swift
//  Pellicola
//
//  Created by marco.rossi on 17/10/2019.
//

import Foundation

@objcMembers
public final class PellicolaCache: NSObject {
    private let fileHandler = PellicolaFileHandler()
    public var expirationDate = Date()
    
    public func clear() {
        DispatchQueue.global(qos: .utility).async {
            self.fileHandler.deleteImages(olderThan: self.expirationDate)
        }
    }
}
