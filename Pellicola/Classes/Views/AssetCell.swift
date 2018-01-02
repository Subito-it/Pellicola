//
//  ImageCollectionViewCell.swift
//  Pellicola
//
//  Created by Andrea Antonioni on 21/12/2017.
//

import UIKit

class AssetCell: UICollectionViewCell {

    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var overlayView: UIView!
    @IBOutlet weak var checkmarkView: CheckmarkView!
    
    var assetIdentifier: String!
    
    override var isSelected: Bool {
        didSet {
            overlayView.isHidden = !isSelected
            checkmarkView.isHidden = !isSelected
        }
    }
    
    var thumbnailImage: UIImage? {
        set { imageView.image = newValue }
        get { return imageView.image }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.isSelected = false
        imageView.applyThumbnailStyle()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        self.isSelected = false
    }

}
