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
    @IBOutlet weak private var thumbnailView: UIImageView!
    
    var title: String? {
        set { albumTitle.text = newValue }
        get { return albumTitle.text }
    }
    
    var subtitle: String? {
        set { photosCount.text = newValue }
        get { return photosCount.text }
    }
    
    var thumbnail: UIImage? {
        set { thumbnailView.image = newValue }
        get { return thumbnailView.image }
    }
    
    var thumbnailSize: CGSize {
        return thumbnailView.frame.size
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        thumbnailView.applyThumbnailStyle()
        if #available(iOS 11.0, *) {
            thumbnailView.accessibilityIgnoresInvertColors = true
        }
    }
    
    override func prepareForReuse() {
        thumbnail = nil
    }
    
    func configure(with style: AssetCollectionCellStyle) {
        albumTitle.font = style.titleFont
        albumTitle.textColor = style.titleColor
        photosCount.font = style.subtitleFont
        photosCount.textColor = style.subtitleColor
    }
    
}
