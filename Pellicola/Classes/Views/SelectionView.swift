//
//  LoadingView.swift
//  Pellicola
//
//  Created by Andrea Antonioni on 11/01/2018.
//

import UIKit

class SelectionView: UIView {
    
    private var whiteBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.alpha = 0.4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var checkmarkView: CheckmarkView = {
        let checkmarkView = CheckmarkView()
        checkmarkView.translatesAutoresizingMaskIntoConstraints = false
        return checkmarkView
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        
        addSubview(whiteBackgroundView)
        NSLayoutConstraint(item: whiteBackgroundView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: whiteBackgroundView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: whiteBackgroundView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: whiteBackgroundView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0).isActive = true
        
        addSubview(checkmarkView)
        NSLayoutConstraint(item: checkmarkView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: 24.0).isActive = true
        NSLayoutConstraint(item: checkmarkView, attribute: .height, relatedBy: .equal, toItem: checkmarkView, attribute: .width, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: checkmarkView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -4.0).isActive = true
        NSLayoutConstraint(item: checkmarkView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: -4.0).isActive = true
    }
    
}


