//
//  UIView+Extension.swift
//  Pellicola
//
//  Created by Andrea Antonioni on 22/12/2017.
//

import Foundation

extension UIView {
    static var identifier: String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
}
