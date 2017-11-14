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
    @IBOutlet var tableView: UITableView!
    
    private static let smartAlbumSubtypes: [PHAssetCollectionSubtype]  = [.smartAlbumUserLibrary,
                                                                          .smartAlbumFavorites,
                                                                          .smartAlbumSelfPortraits,
                                                                          .smartAlbumScreenshots,
                                                                          .smartAlbumPanoramas]
    private var albums: [PHAssetCollection] = []
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        fetchAlbums()
    }
    
    @objc func actionDismiss() {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: Albums Fetching
extension AlbumsViewController {
    private func fetchAlbums() {
        self.albums = smartAlbumsSorted(bySubtypes: AlbumsViewController.smartAlbumSubtypes)
    }
    
    private func smartAlbumsSorted(bySubtypes subtypes: [PHAssetCollectionSubtype]) -> [PHAssetCollection] {
        var albums: [PHAssetCollection] = []
        let albumsForSubtypes = smartAlbums(forSubTypes: subtypes)
        subtypes.forEach { subtype in
            if let albumsToAdd = albumsForSubtypes[subtype] {
                albums += albumsToAdd
            }
        }
        
        return albums
    }
    
    private func smartAlbums(forSubTypes subtypes: [PHAssetCollectionSubtype]) -> [PHAssetCollectionSubtype: [PHAssetCollection]] {
        let smartAlbumsFetch = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
        var albumsForSubtypes: [PHAssetCollectionSubtype: [PHAssetCollection]] = [:]
        
        smartAlbumsFetch.enumerateObjects { (album, idx, stop) in
            let assetsFetch = PHAsset.fetchAssets(in: album, options: nil)
            let albumSubtype = album.assetCollectionSubtype
            if subtypes.contains(albumSubtype), assetsFetch.count > 0 {
                if let albums = albumsForSubtypes[albumSubtype] {
                    albumsForSubtypes[albumSubtype] = albums + [album]
                } else {
                    albumsForSubtypes[albumSubtype] = [album]
                }
            }
        }
        
        return albumsForSubtypes
    }
}

//MARK: UI
extension AlbumsViewController {
    private func configureUI() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(actionDismiss))
        title = NSLocalizedString("albums.title", bundle:  Bundle(for: AlbumsViewController.self), comment: "")
    }
}

//MARK: UITableViewDataSource
extension AlbumsViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}

//MARK: UITableViewDelegate
extension AlbumsViewController: UITableViewDelegate {
    
}
