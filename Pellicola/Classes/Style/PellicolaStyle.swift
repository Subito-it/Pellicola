//
//  PellicolaStyle.swift
//  Pellicola
//
//  Created by Andrea Antonioni on 29/01/2018.
//

import Foundation

@objcMembers
public class PellicolaStyle: NSObject {

    public var checkmarkImage: UIImage?

    public var toolbarBackgroundColor: UIColor = .lightGray

    public var fontNameBold: String?

    public var fontNameNormal: String?

    public var doneString: String = NSLocalizedString("navigation_bar.done", bundle: Bundle.framework, comment: "")

    public var cancelString: String = NSLocalizedString("navigation_bar.cancel", bundle: Bundle.framework, comment: "")

    public var blackColor: UIColor = .black

    public var grayColor: UIColor = .lightGray

}

// MARK: - AssetCollectionCellStyle

extension PellicolaStyle: AssetCollectionCellStyle {

    var titleFont: UIFont {
        guard let fontNameBold = fontNameBold, let font = UIFont(name: fontNameBold, size: 17) else {
            return UIFont.boldSystemFont(ofSize: 17)
        }

        return font
    }

    var titleColor: UIColor {
        return blackColor
    }

    var subtitleFont: UIFont {
        guard let fontNameNormal = fontNameNormal, let font = UIFont(name: fontNameNormal, size: 15) else {
            return UIFont.systemFont(ofSize: 15)
        }

        return font
    }

    var subtitleColor: UIColor {
        return grayColor
    }

}

// MARK: - AssetCellStyle

extension PellicolaStyle: AssetCellStyle { }

