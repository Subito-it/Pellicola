//
//  AssetCell.swift
//  Pellicola
//
//  Created by Andrea Antonioni on 21/12/2017.
//

import UIKit

class AssetCell: UICollectionViewCell {
    
    var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.applyThumbnailStyle()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var checkmarkView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    var loadingView: LoadingView?
    
    enum State {
        case normal, selected, loading
    }
    
    private var state: State = .normal
    
    var assetIdentifier: String!
    
    var thumbnailImage: UIImage? {
        set { imageView.image = newValue }
        get { return imageView.image }
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
        contentView.addSubview(imageView)
        
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        
        contentView.addSubview(checkmarkView)
        
        NSLayoutConstraint(item: checkmarkView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: 24.0).isActive = true
        NSLayoutConstraint(item: checkmarkView, attribute: .height, relatedBy: .equal, toItem: checkmarkView, attribute: .width, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: checkmarkView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 3.0).isActive = true
        NSLayoutConstraint(item: checkmarkView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: -3.0).isActive = true

        updateStyle()
    }
    
    private func updateStyle() {
        
        switch state {
            
        case .normal:
            checkmarkView.isHidden = true
            
            loadingView?.removeFromSuperview()
            loadingView = nil
        case .selected:
            loadingView?.removeFromSuperview()
            loadingView = nil
            
            checkmarkView.isHidden = false
            
        case .loading:
            checkmarkView.isHidden = true
            
            loadingView = LoadingView(frame: bounds)
            addSubview(loadingView!)
            
        }
        
    }
    
    func setState(_ state: State) {
        guard self.state != state else { return }
        self.state = state
        self.updateStyle()
    }
    
    func configure(with style: AssetCellStyle) {
        checkmarkView.image = style.checkmarkImage
    }
    
}
