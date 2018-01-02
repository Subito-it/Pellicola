//
//  AlbumTableViewCell.swift
//  Pellicola
//
//  Created by francesco bigagnoli on 14/11/2017.
//

import UIKit

class AssetCollectionCell: UITableViewCell {

    @IBOutlet weak private var albumTitle: UILabel!
    @IBOutlet weak private var photosCount: UILabel!
    @IBOutlet weak private var imageView1: UIImageView!
    @IBOutlet weak private var imageView2: UIImageView!
    @IBOutlet weak private var imageView3: UIImageView!
    
    enum ThumbnailPosition {
        case back, middle, front
    }
    
    var title: String? {
        set { albumTitle.text = newValue }
        get { return albumTitle.text }
    }
    
    var subtitle: String? {
        set { photosCount.text = newValue }
        get { return photosCount.text }
    }
    
    var thumbnailSize: CGSize {
        return imageView1.frame.size
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView1.applyThumbnailStyle()
        imageView2.applyThumbnailStyle()
        imageView3.applyThumbnailStyle()
    }
    
    override func prepareForReuse() {
        imageView1.image = nil
        imageView2.image = nil
        imageView3.image = nil
    }
    
    func setThubnail(_ image: UIImage?, in position: ThumbnailPosition) {
        switch position {
        case .back: imageView3.image = image
        case .middle: imageView2.image = image
        case .front: imageView1.image = image
        }
    }
    
}
