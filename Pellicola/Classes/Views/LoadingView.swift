//
//  LoadingView.swift
//  Pellicola
//
//  Created by Andrea Antonioni on 11/01/2018.
//

import UIKit

class LoadingView: UIView {
    
    private var darkBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()
    
    override var isHidden: Bool {
        didSet {
            isHidden ? stopAnimating() : startAnimating()
        }
    }
    
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
        
        addSubview(darkBackgroundView)
        NSLayoutConstraint(item: darkBackgroundView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: darkBackgroundView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: darkBackgroundView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: darkBackgroundView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0).isActive = true
        
        addSubview(spinner)
        NSLayoutConstraint(item: spinner, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -4.0).isActive = true
        NSLayoutConstraint(item: spinner, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: -4.0).isActive = true
    }
    
    func startAnimating() {
        spinner.startAnimating()
    }
    
    func stopAnimating() {
        spinner.stopAnimating()
    }
    
}

