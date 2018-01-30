//
//  AssetCollectionCellStyle.swift
//  Pellicola
//
//  Created by Andrea Antonioni on 29/01/2018.
//

import Foundation

@objc protocol AssetCollectionCellStyle {
    
    var titleFont: UIFont { get }
    var titleColor: UIColor { get }
    
    var subtitleFont: UIFont { get }
    var subtitleColor: UIColor { get }
    
}
