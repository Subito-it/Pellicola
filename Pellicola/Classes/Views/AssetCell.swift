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
    
    var thumbnailImage: UIImage? {
        set { imageView.image = newValue }
        get { return imageView.image }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setSelection(false)
        imageView.applyThumbnailStyle()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        setSelection(false)
    }
    
    func setSelection(_ value: Bool) {
        overlayView.isHidden = !value
        checkmarkView.isHidden = !value
    }

}
