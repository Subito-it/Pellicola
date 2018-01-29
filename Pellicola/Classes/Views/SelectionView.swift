//
//  LoadingView.swift
//  Pellicola
//
//  Created by Andrea Antonioni on 11/01/2018.
//

import UIKit

class SelectionView: UIView {
    
    private var checkmarkView: CheckmarkView = {
        let checkmarkView = CheckmarkView()
        checkmarkView.layer.shouldRasterize = true
        checkmarkView.translatesAutoresizingMaskIntoConstraints = false
        return checkmarkView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = .clear
        
        addSubview(checkmarkView)
        NSLayoutConstraint(item: checkmarkView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: 24.0).isActive = true
        NSLayoutConstraint(item: checkmarkView, attribute: .height, relatedBy: .equal, toItem: checkmarkView, attribute: .width, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: checkmarkView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -4.0).isActive = true
        NSLayoutConstraint(item: checkmarkView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: -4.0).isActive = true
    }
    
}


