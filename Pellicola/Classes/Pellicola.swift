//
//  Pellicola.swift
//  Pellicola
//
//  Created by francesco bigagnoli on 10/05/2018.
//

import Foundation

class Pellicola {
    
}

extension Pellicola {
    static var frameworkBundle: Bundle {
        return Bundle(for: Pellicola.self)
    }
    
    static func localizedString(_ key: String) -> String {
        return NSLocalizedString(key, tableName: "PellicolaLocalizable", bundle: frameworkBundle, value: "", comment: "")
    }
}

