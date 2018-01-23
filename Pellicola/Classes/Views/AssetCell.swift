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
    
    var loadingView: LoadingView = {
        let loadingView = LoadingView()
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        return loadingView
    }()

    var selectionView: SelectionView = {
        let selectionView = SelectionView()
        selectionView.translatesAutoresizingMaskIntoConstraints = false
        return selectionView
    }()
    
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
        contentView.addSubview(loadingView)
        contentView.addSubview(selectionView)
        
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true

        loadingView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        loadingView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        loadingView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        loadingView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true

        selectionView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        selectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        selectionView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        selectionView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        
        updateStyle()
    }
    
    private func updateStyle() {
        switch state {
            
        case .normal:
            selectionView.isHidden = true
            loadingView.isHidden = true
        case .selected:
            selectionView.isHidden = false
            loadingView.isHidden = true
        case .loading:
            selectionView.isHidden = true
            loadingView.isHidden = false
            
        }
    }
    
    func setState(_ state: State) {
        guard self.state != state else { return }
        self.state = state
        self.updateStyle()
    }
    
}
