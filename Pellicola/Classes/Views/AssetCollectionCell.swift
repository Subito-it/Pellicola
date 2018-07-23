//
//  AlbumTableViewCell.swift
//  Pellicola
//
//  Created by francesco bigagnoli on 14/11/2017.
//

import UIKit

class MultiThumbnail: UIView {
    static let numOfThumbs = 4
    
    @IBOutlet weak private var thumb1: UIImageView!
    @IBOutlet weak private var thumb2: UIImageView!
    @IBOutlet weak private var thumb3: UIImageView!
    @IBOutlet weak private var thumb4: UIImageView!
    
    var imageViews: [UIImageView] {
        return [thumb1, thumb2, thumb3, thumb4]
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 2
        imageViews.forEach { imageView in
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 1.0
        }
    }
    
    func setThumbnails(_ thumbs: [UIImage]) {
        for (thumb, imageView) in zip(thumbs, imageViews) {
            imageView.image = thumb
        }
    }
}

class AssetCollectionCell: UITableViewCell {

    @IBOutlet weak private var albumTitle: UILabel!
    @IBOutlet weak private var photosCount: UILabel!
    @IBOutlet weak private var thumbnailView: UIImageView!
    @IBOutlet weak var multiThumbnailView: MultiThumbnail!
    
    var title: String? {
        set { albumTitle.text = newValue }
        get { return albumTitle.text }
    }
    
    var subtitle: String? {
        set { photosCount.text = newValue }
        get { return photosCount.text }
    }
    
    private(set) var thumbnail: UIImage? {
        set { thumbnailView.image = newValue }
        get { return thumbnailView.image }
    }
    
    var thumbnailSize: CGSize {
        return thumbnailView.frame.size
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        thumbnailView.applyThumbnailStyle()
    }
    
    override func prepareForReuse() {
        thumbnail = nil
        title = ""
        subtitle = ""
    }
    
    func configureData(with album: AlbumData) {
        title = album.title
        thumbnail = album.thumbnail
        thumbnailView.isHidden = false
        multiThumbnailView.isHidden = true
        subtitle = String(album.photoCount)
    }
    
    func setMultipleThumbnails(_ images: [UIImage]) {
        thumbnailView.isHidden = true
        multiThumbnailView.isHidden = false
        multiThumbnailView.setThumbnails(images)
    }
    
    func configureStyle(with style: AssetCollectionCellStyle) {
        albumTitle.font = style.titleFont
        albumTitle.textColor = style.titleColor
        photosCount.font = style.subtitleFont
        photosCount.textColor = style.subtitleColor
        
        ([thumbnailView, multiThumbnailView] as [UIView]).forEach { view in
            view.layer.borderWidth = (1.0 / UIScreen.main.scale) * 1.0 //This is used to achieve a 1px width
            view.layer.cornerRadius = 2
            view.layer.borderColor = style.thumbBorderColor.cgColor
        }
    }
}
