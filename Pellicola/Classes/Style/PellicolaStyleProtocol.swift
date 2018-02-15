//
//  PellicolaStyle.swift
//  Pellicola
//
//  Created by Andrea Antonioni on 29/01/2018.
//

import Foundation

@objc public protocol PellicolaStyleProtocol {
    
    var checkmarkImage: UIImage? { get }
    var toolbarBackgroundColor: UIColor { get }
    var fontNameBold: String? { get }
    var fontNameNormal: String? { get }
    var doneString: String { get }
    var cancelString: String { get }
    var blackColor: UIColor { get }
    var grayColor: UIColor { get }
    var alertAccessDeniedTitle: String? { get }
    var alertAccessDeniedMessage: String? { get }
    
}

@objcMembers
public class DefaultPellicolaStyle: NSObject, PellicolaStyleProtocol {

    public var checkmarkImage: UIImage?

    public var toolbarBackgroundColor: UIColor = .lightGray

    public var fontNameBold: String?

    public var fontNameNormal: String?

    public var doneString: String = NSLocalizedString("navigation_bar.done", bundle: Bundle.framework, comment: "")

    public var cancelString: String = NSLocalizedString("navigation_bar.cancel", bundle: Bundle.framework, comment: "")

    public var blackColor: UIColor = .black

    public var grayColor: UIColor = .lightGray
    
    public var alertAccessDeniedTitle: String?
    
    public var alertAccessDeniedMessage: String?

}

