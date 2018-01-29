//
//  UIImageView+Extension.swift
//  Pellicola
//
//  Created by Andrea Antonioni on 02/01/2018.
//

import Foundation

extension UIImageView {
    
    func applyThumbnailStyle() {
        self.contentMode = .scaleAspectFill
        self.clipsToBounds = true
        self.layer.cornerRadius = 2
    }
    
}
