//
//  AssetCollectionCellStyle.swift
//  Pellicola
//
//  Created by Andrea Antonioni on 29/01/2018.
//

import Foundation

struct AssetCollectionCellStyle {
    
    var style: PellicolaStyleProtocol
    
    var titleFont: UIFont {
        guard let fontNameBold = style.fontNameBold, let font = UIFont(name: fontNameBold, size: 17) else {
            return UIFont.boldSystemFont(ofSize: 17)
        }
        
        return font
    }
    
    var titleColor: UIColor {
        return style.blackColor
    }
    
    var subtitleFont: UIFont {
        guard let fontNameNormal = style.fontNameNormal, let font = UIFont(name: fontNameNormal, size: 15) else {
            return UIFont.systemFont(ofSize: 15)
        }
        
        return font
    }
    
    var subtitleColor: UIColor {
        return style.grayColor
    }
    
    var thumbBorderColor: UIColor {
        return style.grayColor
    }
    
    var backgroundColor: UIColor {
        return style.backgroundColor
    }
    
}
