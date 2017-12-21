//
//  ImageCollectionViewCell.swift
//  Pellicola
//
//  Created by Andrea Antonioni on 21/12/2017.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak private var imageView: UIImageView!
    
    var assetIdentifier: String!
    
    var thumbnailImage: UIImage? {
        set { imageView.image = newValue }
        get { return imageView.image }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }

}
