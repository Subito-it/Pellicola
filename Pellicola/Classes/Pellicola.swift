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
        guard let url = frameworkBundle.url(forResource: "Pellicola", withExtension: "bundle"),
              let stringBundle = Bundle(url: url) else {
            return key
        }
        
        return stringBundle.localizedString(forKey: key, value: "", table: nil)
    }
}

