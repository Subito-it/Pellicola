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
    
    private var albums: [PHAssetCollection] = []
    
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
        title = NSLocalizedString("albums.title", bundle:  Bundle.framework, comment: "")
        
        tableView.register(UINib(nibName: "AlbumTableViewCell", bundle: Bundle(for: AlbumTableViewCell.self)),
                           forCellReuseIdentifier: "AlbumCell")
        tableView.rowHeight = 85
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

// MARK: - UITableViewDataSource

extension AlbumsViewController: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let albumCell = tableView.dequeueReusableCell(withIdentifier: "AlbumCell", for: indexPath) as? AlbumTableViewCell else {
            assertionFailure("Error dequeuing cell")
            return UITableViewCell()
        }
        
        let album = albums[indexPath.row]
        albumCell.title = album.localizedTitle ?? ""
        
        // Photos Count
        let fetchedAssets = PHAsset.fetchAssets(in: album, options: nil)
        let numberOfImages = fetchedAssets.countOfAssets(with: .image)
        albumCell.subtitle = String(numberOfImages)
        
        // Album thumbnail
        let keyImageFetch = PHAsset.fetchKeyAssets(in: album, options: nil)
        if let thumbAsset = keyImageFetch?.firstObject ?? (fetchedAssets.firstObject ?? nil) {
            let imageManager = PHImageManager()
            let requestOptions = PHImageRequestOptions()
            requestOptions.deliveryMode = .fastFormat
            requestOptions.isNetworkAccessAllowed = true
            
            imageManager.requestImage(for: thumbAsset, targetSize: albumCell.thumbnailSize, contentMode: .default, options: requestOptions, resultHandler: { (image, info) in
                albumCell.thumbail = image
            })
            
        } else {
            assertionFailure("You should provide an album placeholder thumbnail")
        }
        
        return albumCell
    }
    
}

// MARK: - UITableViewDelegate

extension AlbumsViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let imagePickerViewController = ImagePickerViewController(nibName: nil, bundle: Bundle.framework)
        let assetCollection = albums[indexPath.row]
        imagePickerViewController.assetCollection = assetCollection
        imagePickerViewController.fetchResult = PHAsset.fetchAssets(in: assetCollection, options: nil)
        self.navigationController?.show(imagePickerViewController, sender: nil)
    }
    
}
