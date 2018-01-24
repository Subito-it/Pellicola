//
//  AlbumViewController.swift
//  PellicolaDemo
//
//  Created by francesco bigagnoli on 10/11/2017.
//  Copyright © 2017 Francesco Bigagnoli. All rights reserved.
//

import UIKit
import Photos

final class AssetCollectionsViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    
    var userDidCancel: (() -> Void)?
    var didSelectImages: (([UIImage]) -> Void)?
    var didSelectAssetCollection: ((PHAssetCollection) -> Void)?
    
    private var doneBarButton: UIBarButtonItem?
    private var dataStorageObservation: NSKeyValueObservation?
    
    var viewModel: AssetCollectionsViewModel
    
    init(viewModel: AssetCollectionsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: Bundle.framework)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        viewModel.onChangeAssetCollections = { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPathForSelectedRow, animated: false)
        }
    }
    
    // MARK: - UI
    
    private func configureUI() {
        setupNavigationBar()
        setupTableView()
    }
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                           target: self,
                                                           action: #selector(cancelButtonTapped))
        
        if !viewModel.isSingleSelection {
            doneBarButton = UIBarButtonItem(barButtonSystemItem: .done,
                                            target: self,
                                            action: #selector(doneButtonTapped))
            
            viewModel.onChangeSelectedAssets = { [weak self] numberOfSelectedAssets in
                self?.doneBarButton?.isEnabled = numberOfSelectedAssets > 0
            }
            
            doneBarButton?.isEnabled = viewModel.numberOfSelectedAssets > 0
            
            navigationItem.rightBarButtonItem = doneBarButton
        }
        
        title = NSLocalizedString("albums.title", bundle: Bundle.framework, comment: "")
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: AssetCollectionCell.identifier, bundle: Bundle(for: AssetCollectionCell.self)),
                           forCellReuseIdentifier: AssetCollectionCell.identifier)
        tableView.rowHeight = 85
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func createPlaceholderImage(withSize size: CGSize) -> UIImage? {
        
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        let backgroundColor = UIColor(red: 239.0 / 255.0,
                                      green: 239.0 / 255.0,
                                      blue: 244.0 / 255.0,
                                      alpha: 1.0)
        let iconColor = UIColor(red: 179.0 / 255.0,
                                green: 179.0 / 255.0,
                                blue: 182.0 / 255.0,
                                alpha: 1.0)
        
        // Background
        context?.setFillColor(backgroundColor.cgColor)
        context?.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        // Icon (back)
        let backIconRect = CGRect(x: size.width * (16.0 / 68.0),
                                  y: size.height * (20.0 / 68.0),
                                  width: size.width * (32.0 / 68.0),
                                  height: size.height * (24.0 / 68.0))
        
        context?.setFillColor(iconColor.cgColor)
        context?.fill(backIconRect)
        
        context?.setFillColor(backgroundColor.cgColor)
        context?.fill(backIconRect.insetBy(dx: 1.0, dy: 1.0))
        
        // Icon (front)
        let frontIconRect = CGRect(x: size.width * (20.0 / 68.0),
                                   y: size.height * (24.0 / 68.0),
                                   width: size.width * (32.0 / 68.0),
                                   height: size.height * (24.0 / 68.0))
        
        context?.setFillColor(backgroundColor.cgColor)
        context?.fill(frontIconRect.insetBy(dx: -1.0, dy: -1.0))
        
        context?.setFillColor(iconColor.cgColor)
        context?.fill(frontIconRect)
        
        context?.setFillColor(backgroundColor.cgColor)
        context?.fill(frontIconRect.insetBy(dx: 1.0, dy: 1.0))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
        
    }
    
    // MARK: - Action
    
    @objc func doneButtonTapped() {
        guard !viewModel.isDownloadingImages else {
            viewModel.stopDownloadingImages()
            let alert = UIAlertController(title: NSLocalizedString("alert_deselection.title", bundle: Bundle.framework, comment: ""),
                                          message: nil,
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: NSLocalizedString("alert_deselection.ok", bundle: Bundle.framework, comment: ""),
                                         style: .default)
            alert.addAction(okAction)
            present(alert, animated: true)
            return
        }
        
        navigationController?.dismiss(animated: true) { [weak self] in
            guard let sSelf = self else { return }
            sSelf.didSelectImages?(sSelf.viewModel.getSelectedImages())
        }
    }
    
    @objc func cancelButtonTapped() {
        navigationController?.dismiss(animated: true) { [weak self] in
            self?.userDidCancel?()
        }
    }
    
}

// MARK: - UITableViewDataSource

extension AssetCollectionsViewController: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.albums.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let albumCell = tableView.dequeueReusableCell(withIdentifier: AssetCollectionCell.identifier, for: indexPath) as? AssetCollectionCell else {
            assertionFailure("Error dequeuing cell")
            return UITableViewCell()
        }
        
        albumCell.tag = indexPath.row
        
        let album = viewModel.albums[indexPath.row]
        albumCell.title = album.localizedTitle ?? ""
        
        // Photos Count
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        let fetchedAssets = PHAsset.fetchAssets(in: album, options: options)
        let numberOfImages = fetchedAssets.countOfAssets(with: .image)
        albumCell.subtitle = String(numberOfImages)
        
        let scale = UIScreen.main.scale
        let thumbnailSize = CGSize(width: albumCell.thumbnailSize.width * scale, height: albumCell.thumbnailSize.height * scale)
        
        // Album thumbnails
        let imageManager = PHImageManager.default()
        
        if fetchedAssets.count >= 3 {
            imageManager.requestImage(for: fetchedAssets[numberOfImages - 3],
                                      targetSize: thumbnailSize,
                                      contentMode: .aspectFill,
                                      options: nil,
                                      resultHandler: { (image, _) in
                                        if albumCell.tag == indexPath.row {
                                            albumCell.setThubnail(image, in: .back)
                                        }
            })
        } else {
            albumCell.setThubnail(nil, in: .back)
        }
        
        if fetchedAssets.count >= 2 {
            imageManager.requestImage(for: fetchedAssets[numberOfImages - 2],
                                      targetSize: thumbnailSize,
                                      contentMode: .aspectFill,
                                      options: nil,
                                      resultHandler: { (image, _) in
                                        if albumCell.tag == indexPath.row {
                                            albumCell.setThubnail(image, in: .middle)
                                        }
            })
        } else {
            albumCell.setThubnail(nil, in: .middle)
        }
        
        if fetchedAssets.count >= 1 {
            imageManager.requestImage(for: fetchedAssets[numberOfImages - 1],
                                      targetSize: thumbnailSize,
                                      contentMode: .aspectFill,
                                      options: nil,
                                      resultHandler: { (image, _) in
                                        if albumCell.tag == indexPath.row {
                                            albumCell.setThubnail(image, in: .front)
                                        }
            })
        }
        
        if fetchedAssets.count == 0 {
            let placeholderImage = createPlaceholderImage(withSize: albumCell.thumbnailSize)
            albumCell.setThubnail(placeholderImage, in: .back)
            albumCell.setThubnail(placeholderImage, in: .middle)
            albumCell.setThubnail(placeholderImage, in: .front)
        }
        
        return albumCell
    }
    
}

// MARK: - UITableViewDelegate

extension AssetCollectionsViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let assetCollection = viewModel.albums[indexPath.row]
        didSelectAssetCollection?(assetCollection)
    }
    
}
