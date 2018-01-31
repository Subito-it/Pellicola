//
//  AssetCellStyle.swift
//  Pellicola
//
//  Created by Andrea Antonioni on 29/01/2018.
//

import UIKit

struct AssetCellStyle {
    
    var style: PellicolaStyleProtocol
    
    var checkmarkImage: UIImage? {
        return style.checkmarkImage
    }
    
}
