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
    
    var selectionView: SelectionView?
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    private func commonInit() {
        contentView.addSubview(imageView)
        
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true

        updateStyle()
    }
    
    private func updateStyle() {
        
        switch state {
            
        case .normal:
            selectionView?.removeFromSuperview()
            loadingView?.removeFromSuperview()
            selectionView = nil
            loadingView = nil
        case .selected:
            loadingView?.removeFromSuperview()
            loadingView = nil
            
            selectionView = SelectionView(frame: bounds)
            addSubview(selectionView!)
            
        case .loading:
            selectionView?.removeFromSuperview()
            selectionView = nil
            
            loadingView = LoadingView(frame: bounds)
            addSubview(loadingView!)
            
        }
        
    }
    
    func setState(_ state: State) {
        guard self.state != state else { return }
        self.state = state
        self.updateStyle()
    }
    
}
