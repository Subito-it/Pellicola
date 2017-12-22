//
//  Bundle+Extension.swift
//  Pellicola
//
//  Created by Andrea Antonioni on 21/12/2017.
//

import Foundation

extension Bundle {
    static var framework: Bundle {
        return Bundle(for: AssetCollectionsViewController.self)
    }
}
