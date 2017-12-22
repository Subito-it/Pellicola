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
    @IBOutlet weak private var albumThumb: UIImageView!
    
    var title: String? {
        set { albumTitle.text = newValue }
        get { return albumTitle.text }
    }
    
    var subtitle: String? {
        set { photosCount.text = newValue }
        get { return photosCount.text }
    }
    
    var thumbail: UIImage? {
        set { albumThumb.image = newValue }
        get { return albumThumb.image }
    }
    
    var thumbnailSize: CGSize {
        return albumThumb.frame.size
    }
    
}
