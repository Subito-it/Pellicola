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
    enum LeftBarButtonType {
        case back
        case dismiss
    }
    
    private enum Section: Int {
        case firstLevel = 0
        case secondLevel = 1
    }
    
    @IBOutlet private var tableView: UITableView!
    
    var didCancel: (() -> Void)?
    var didSelectImages: (([UIImage]) -> Void)?
    var didSelectAlbum: ((AlbumData) -> Void)?
    var didSelectSecondLevelEntry: (() -> Void)?
    
    private var doneBarButton: UIBarButtonItem?
    
    private var viewModel: AssetCollectionsViewModel
    private var style: PellicolaStyleProtocol
    
    private var loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    private var albums = [AlbumData]()
    
    private let leftBarButtonType: LeftBarButtonType
        
    private let cachingImageManager = PHCachingImageManager()
    
    init(viewModel: AssetCollectionsViewModel, style: PellicolaStyleProtocol, leftBarButtonType: LeftBarButtonType) {
        self.viewModel = viewModel
        self.style = style
        self.leftBarButtonType = leftBarButtonType
        cachingImageManager.allowsCachingHighQualityImages = false
        
        super.init(nibName: nil, bundle: Pellicola.frameworkBundle)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
        let updateData: ([AlbumData]) -> () = { [weak self] albums in
            self?.removeLoadingIndicator()
            self?.albums = albums
            self?.tableView.reloadData()
        }

        viewModel.onChangeAssetCollections = updateData
        viewModel.fetchData(completion: updateData)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPathForSelectedRow, animated: false)
        }
    }
    
    //MARK: - Business Logic
    
    private func shouldsShowSecondLevelEntry() -> Bool {
        return viewModel.hasSecondLevel
    }
    
    // MARK: - UI
    
    private func configureUI() {
        setupNavigationBar()
        setupTableView()
        
        if albums.isEmpty {
            showLoadingIndicator()
        }
    }
    
    private func showLoadingIndicator() {
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingIndicator)
        
        loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        loadingIndicator.startAnimating()
    }
    
    private func removeLoadingIndicator() {
        loadingIndicator.stopAnimating()
        loadingIndicator.removeFromSuperview()
    }
    
    private func setupNavigationBar() {
        if leftBarButtonType == .dismiss {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: style.cancelString,
                                                               style: .plain,
                                                               target: self,
                                                               action: #selector(cancelButtonTapped))
        }
        
        if !viewModel.isSingleSelection {
            doneBarButton = UIBarButtonItem(title: style.doneString,
                                            style: .done,
                                            target: self,
                                            action: #selector(doneButtonTapped))
            
            viewModel.onChangeSelectedAssets = { [weak self] numberOfSelectedAssets in
                self?.doneBarButton?.isEnabled = numberOfSelectedAssets > 0
            }
            
            doneBarButton?.isEnabled = viewModel.numberOfSelectedAssets > 0
            
            navigationItem.rightBarButtonItem = doneBarButton
        }
        
        title = Pellicola.localizedString("albums.title")
    }
    
    private func setupTableView() {
        let nib = UINib(nibName: AssetCollectionCell.identifier, bundle: Pellicola.frameworkBundle)
        tableView.register(nib,
                           forCellReuseIdentifier: AssetCollectionCell.identifier)
        tableView.rowHeight = 85
        tableView.separatorStyle = .none
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
            let alert = UIAlertController(title: Pellicola.localizedString("alert_deselection.title"),
                                          message: nil,
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: Pellicola.localizedString("alert_deselection.ok"),
                                         style: .default)
            alert.addAction(okAction)
            present(alert, animated: true)
            return
        }
        
        didSelectImages?(viewModel.getSelectedImages())
    }
    
    @objc func cancelButtonTapped() {
        didCancel?()
    }
    
}

// MARK: - UITableViewDataSource

extension AssetCollectionsViewController: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return shouldsShowSecondLevelEntry() ? 2 : 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let tableSection = Section(rawValue: section) else {
            assertionFailure("Undefined section")
            return 0
        }
        
        switch tableSection {
        case .firstLevel:
            return albums.count
        case .secondLevel:
            return 1
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let albumCell = tableView.dequeueReusableCell(withIdentifier: AssetCollectionCell.identifier, for: indexPath) as? AssetCollectionCell else {
            assertionFailure("Error dequeuing cell")
            return UITableViewCell()
        }
        
        guard let section = Section(rawValue: indexPath.section) else { return albumCell }
        switch section {
        case .firstLevel:
            configureAlbumCell(albumCell, atIndex: indexPath)
        case .secondLevel:
            configureSecondLevelEntryCell(albumCell)
        }
        
        return albumCell
    }
}

//MARK: Cells Configuration
extension AssetCollectionsViewController {
    private func configureAlbumCell(_ albumCell: AssetCollectionCell, atIndex indexPath: IndexPath) {
        albumCell.accessibilityIdentifier = "album_\(indexPath.row)"
        albumCell.configureStyle(with: AssetCollectionCellStyle(style: style))
        
        let album = albums[indexPath.row]
        
        if album.thumbnail == nil {
            if let thumbAsset = album.thumbnailAsset {
                let options = PHImageRequestOptions()
                options.isNetworkAccessAllowed = true
                options.deliveryMode = .fastFormat
                let scale = UIScreen.main.scale
                let thumbnailSize = CGSize(width: albumCell.thumbnailSize.width * scale, height: albumCell.thumbnailSize.height * scale)
                cachingImageManager.requestImage(for: thumbAsset,
                                                 targetSize: thumbnailSize,
                                                 contentMode: .aspectFill,
                                                 options: options,
                                                 resultHandler: { [weak self] (image, _) in
                                                    album.thumbnail = image
                                                    albumCell.configureData(with: album)
                                                    // Once we got a tumb, we reload the second section to update multimages thumbnails
                                                    if let tableView = self?.tableView,
                                                        tableView.numberOfSections > 1 {
                                                        tableView.reloadSections([Section.secondLevel.rawValue], with: .none)
                                                    }
                })
            }
        }
        
        albumCell.configureData(with: album)
    }
    
    private func configureSecondLevelEntryCell(_ albumCell: AssetCollectionCell) {
        albumCell.accessibilityIdentifier = "other_albums"
        albumCell.configureStyle(with: AssetCollectionCellStyle(style: style))
        albumCell.title = Pellicola.localizedString("albums.list.other_albums")
        updateSecondLevelCellThumbnail(albumCell)
    }
    
    private func updateSecondLevelCellThumbnail(_ albumCell: AssetCollectionCell) {
        if (albums.count >= 4) {
            albumCell.setMultipleThumbnails( albums[0...3].compactMap{ $0.thumbnail } )
        }
    }
}

// MARK: - UITableViewDelegate

extension AssetCollectionsViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let section = Section(rawValue: indexPath.section) else { return }
        
        switch section {
        case .firstLevel:
            didSelectAlbum?(albums[indexPath.row])
        case .secondLevel:
            didSelectSecondLevelEntry?()
        }
    }    
}
