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
    
    private var state: State = .normal
    
    var assetIdentifier: String!
    
    var thumbnailImage: UIImage? {
        set { imageView.image = newValue }
        get { return imageView.image }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.applyThumbnailStyle()
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
