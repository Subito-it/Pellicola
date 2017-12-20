//
//  AlbumViewController.swift
//  PellicolaDemo
//
//  Created by francesco bigagnoli on 10/11/2017.
//  Copyright © 2017 Francesco Bigagnoli. All rights reserved.
//

import UIKit
import Photos

public final class AlbumsViewController: UIViewController {
    
    // Private properties
    
    @IBOutlet private var tableView: UITableView!
    
    private let assetCollectionType: PHAssetCollectionType = .smartAlbum
    
    private let smartAlbumSubtypes: [PHAssetCollectionSubtype]  = [.smartAlbumUserLibrary,
                                                                   .smartAlbumFavorites,
                                                                   .smartAlbumSelfPortraits,
                                                                   .smartAlbumScreenshots,
                                                                   .smartAlbumPanoramas]
    
    private var albums: [PHAssetCollection] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    // View cycle
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchAlbums()
    }
    
    // MARK: - UI
    
    private func configureUI() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                            target: self,
                                                            action: #selector(actionDismiss))
        title = NSLocalizedString("albums.title", bundle:  Bundle(for: AlbumsViewController.self), comment: "")
        
        tableView.register(UINib(nibName: "AlbumTableViewCell", bundle: Bundle(for: AlbumTableViewCell.self)),
                           forCellReuseIdentifier: "AlbumCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 85
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    // MARK: - Albums fetching
    
    private func fetchAlbums() {
        self.albums = AlbumsFetcher.fetch(assetCollectionType: assetCollectionType,
                                          sortedBy: smartAlbumSubtypes)
    }
    
    
    
    // MARK: - Action
    
    @objc func actionDismiss() {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: UI
extension AlbumsViewController {
    
    private func configuredCell(forAlbum album: PHAssetCollection, atIndex indexPath: IndexPath) -> UITableViewCell {
        guard let albumCell = tableView.dequeueReusableCell(withIdentifier: "AlbumCell", for: indexPath) as? AlbumTableViewCell else {
            assertionFailure("Error dequeuing album cell")
            return UITableViewCell()
        }
        
        if let albumTitle = album.localizedTitle {
            albumCell.albumTitle.text = albumTitle
        } else {
            assertionFailure("You should provide an album placeholder title")
        }
        
        //Photos Count
        let assetsFetch = PHAsset.fetchAssets(in: album, options: nil)
        let numOfImages = assetsFetch.countOfAssets(with: .image)
        albumCell.photosCount.text = String(numOfImages)
        
        //Album thumbnail
        let keyImageFetch = PHAsset.fetchKeyAssets(in: album, options: nil)
        if let thumbAsset = keyImageFetch?.firstObject ?? (assetsFetch.firstObject ?? nil) {
            let imageManager = PHImageManager()
            let requestOptions = PHImageRequestOptions()
            requestOptions.deliveryMode = .fastFormat
            requestOptions.isNetworkAccessAllowed = true
            
            imageManager.requestImage(for: thumbAsset, targetSize: albumCell.albumThumb.frame.size, contentMode: .default, options: requestOptions, resultHandler: { (image, info) in
                albumCell.albumThumb.image = image
            })
            
        } else {
            assertionFailure("You should provide an album placeholder thumbnail")
        }
        
        return albumCell
    }
}

//MARK: UITableViewDataSource
extension AlbumsViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let album = albums[indexPath.row]
        return configuredCell(forAlbum: album, atIndex: indexPath)
    }
}

//MARK: UITableViewDelegate
extension AlbumsViewController: UITableViewDelegate {
    
}
