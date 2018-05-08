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
    
    private enum Section: Int {
        case firstLevel = 0
        case secondLevel = 1
    }
    
    @IBOutlet private var tableView: UITableView!
    
    var didCancel: (() -> Void)?
    var didSelectImages: (([UIImage]) -> Void)?
    var didSelectAssetCollection: ((PHAssetCollection) -> Void)?
    var didSelectSecondLevelEntry: (() -> Void)?
    
    private var doneBarButton: UIBarButtonItem?
    
    private var viewModel: AssetCollectionsViewModel
    private var style: PellicolaStyleProtocol
    
    private var loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    init(viewModel: AssetCollectionsViewModel, style: PellicolaStyleProtocol) {
        self.viewModel = viewModel
        self.style = style
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
            self?.removeLoadingIndicator()
            self?.tableView.reloadData()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPathForSelectedRow, animated: false)
        }
    }
    
    //MARK: - Business Logic
    
    private func shouldsShowSecondLevelEntry() -> Bool {
        return viewModel.secondLevelSubtypes != nil
    }
    
    // MARK: - UI
    
    private func configureUI() {
        setupNavigationBar()
        setupTableView()
        
        if viewModel.firstLevelAlbums.isEmpty {
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
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: style.cancelString,
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(cancelButtonTapped))
        
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
        
        title = NSLocalizedString("albums.title", bundle: Bundle.framework, comment: "")
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: AssetCollectionCell.identifier, bundle: Bundle(for: AssetCollectionCell.self)),
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
            let alert = UIAlertController(title: NSLocalizedString("alert_deselection.title", bundle: Bundle.framework, comment: ""),
                                          message: nil,
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: NSLocalizedString("alert_deselection.ok", bundle: Bundle.framework, comment: ""),
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
            return viewModel.firstLevelAlbums.count
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
            configureAlbumCell(albumCell, atIndex: indexPath.row)
        case .secondLevel:
            configureSecondLevelEntryCell(albumCell)
        }
        
        return albumCell
    }
    
    private func configureSecondLevelEntryCell(_ albumCell: AssetCollectionCell) {
        albumCell.accessibilityIdentifier = "other_albums"
        albumCell.configure(with: AssetCollectionCellStyle(style: style))
        albumCell.title = NSLocalizedString("albums.list.other_albums", bundle: Bundle.framework, comment: "")
    }
    
    private func configureAlbumCell(_ albumCell: AssetCollectionCell, atIndex index: Int) {
        albumCell.accessibilityIdentifier = "album_\(index)"
        albumCell.tag = index
        albumCell.configure(with: AssetCollectionCellStyle(style: style))
        
        let album = viewModel.firstLevelAlbums[index]
        albumCell.title = album.localizedTitle ?? ""
        
        let scale = UIScreen.main.scale
        let thumbnailSize = CGSize(width: albumCell.thumbnailSize.width * scale, height: albumCell.thumbnailSize.height * scale)
        
        // Album thumbnails
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let fetchedAssets = PHAsset.fetchImageAssets(in: album)
            if let lastAsset = fetchedAssets.lastObject {
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                PHImageManager.default().requestImage(for: lastAsset,
                                                      targetSize: thumbnailSize,
                                                      contentMode: .aspectFill,
                                                      options: nil,
                                                      resultHandler: { (image, _) in
                                                        DispatchQueue.main.async {
                                                            if albumCell.tag == index {
                                                                albumCell.thumbnail = image
                                                                albumCell.subtitle = String(fetchedAssets.count)
                                                            }
                                                        }
                })
            } else {
                DispatchQueue.main.async {
                    if let placeholderImage = self?.createPlaceholderImage(withSize: albumCell.thumbnailSize) {
                        albumCell.thumbnail = placeholderImage
                    }
                    
                    albumCell.subtitle = String(fetchedAssets.count)
                }
            }
        }
    }
    
}

// MARK: - UITableViewDelegate

extension AssetCollectionsViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else { return }
        
        switch section {
        case .firstLevel:
            let assetCollection = viewModel.firstLevelAlbums[indexPath.row]
            didSelectAssetCollection?(assetCollection)
        case .secondLevel:
            didSelectSecondLevelEntry?()
        }
    }    
}


