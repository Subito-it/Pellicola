//
//  UIImage+Color.swift
//  Pellicola_Tests
//
//  Created by Andrea Antonioni on 19/01/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

extension UIImage {
    
    static func image(with color: UIColor) -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: 5, height: 5))
        color.set()
        UIRectFill(CGRect(origin: .zero, size: CGSize(width: 5, height: 5)))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
