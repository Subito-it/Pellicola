//
//  ImageCollectionViewCell.swift
//  Pellicola
//
//  Created by Andrea Antonioni on 21/12/2017.
//

import UIKit

class AssetCell: UICollectionViewCell {

    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak var selectionView: SelectionView!
    @IBOutlet weak var loadingView: LoadingView!
    
    enum State {
        case normal, selected, loading
    }
    
    var state: State = .normal {
        didSet {
            updateStyle()
        }
    }
    
    var assetIdentifier: String!
    
    var thumbnailImage: UIImage? {
        set { imageView.image = newValue }
        get { return imageView.image }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.applyThumbnailStyle()
        state = .normal
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        state = .normal
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

}
