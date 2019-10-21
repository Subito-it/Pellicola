//
//  PellicolaPresenter.swift
//  Pellicola
//
//  Created by francesco bigagnoli on 13/11/2017.
//

import Foundation
import Photos

public final class PellicolaPresenter: NSObject {
    private let smartAlbumsType = AlbumType(type: .smartAlbum, subtypes: [.smartAlbumUserLibrary,
                                                                          .smartAlbumFavorites,
                                                                          .smartAlbumSelfPortraits,
                                                                          .smartAlbumScreenshots])
    
    private let otherAlbumsType = AlbumType(type: .album, subtypes: [.albumRegular,
                                                                     .albumMyPhotoStream,
                                                                     .albumCloudShared,
                                                                     .albumSyncedEvent,
                                                                     .albumSyncedAlbum])
    @objc public var didStartProcessingImages: (() -> Void)?
    @objc public var didFinishProcessingImages: (([URL]) -> Void)?
    @objc public var userDidCancel: (() -> Void)?
    @objc public var imageSize: CGSize = PHImageManagerMaximumSize
    
    private lazy var navigationController: PellicolaNavigationController = {
        return PellicolaNavigationController()
    }()
    
    var imagesDataStorage: ImagesDataStorage?
    var imagesDataFetcher: ImagesDataFetcher?
    
    var maxNumberOfSelections: Int? {
        return imagesDataStorage?.limit
    }
    
    var numberOfSelectedAssets: Int? {
        return imagesDataStorage?.images.count
    }
    
    let style: PellicolaStyleProtocol
    
    private lazy var centerBarButtonToolbar: UIBarButtonItem = {
        let infoBarButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        infoBarButton.isEnabled = false
        let attributes = [ NSAttributedString.Key.foregroundColor: style.blackColor ]
        infoBarButton.setTitleTextAttributes(attributes, for: .normal)
        infoBarButton.setTitleTextAttributes(attributes, for: .disabled)
        return infoBarButton
    }()
    
    private lazy var toolBarItems: [UIBarButtonItem] = {
        return [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            centerBarButtonToolbar,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        ]
    }()
    
    @objc public init(style: PellicolaStyleProtocol) {
        self.style = style
        super.init()
    }
    
    /*
     
     Values for maxNumberOfSelections:
     
     - <=0 Unlimited
     - ==1 Single selection
     - >1  Limited selection
     */
    @objc public func present(on presentingViewController: UIViewController, maxNumberOfSelections: Int) {
        
        PHPhotoLibrary.requestAuthorization { [weak self] (status) in
            DispatchQueue.main.async {
                guard let sSelf = self else { return }
                guard case .authorized = status else {
                    let alert = sSelf.openSettingsAlert()
                    presentingViewController.present(alert, animated: true)
                    return
                }
                
                sSelf.setupPresenter(with: maxNumberOfSelections)
                guard let assetCollectionsVC = sSelf.createAssetsCollectionViewController(withType: sSelf.smartAlbumsType, secondLevelType: sSelf.otherAlbumsType, isRootLevel: true) else { return }
                sSelf.configureNavigationController(with: [assetCollectionsVC])
                presentingViewController.present(sSelf.navigationController, animated: true, completion: nil)
            }
        }
    }
        
    // MARK: - UI Configuration
    private func configureNavigationController(with viewControllers:[UIViewController]) {
        navigationController.toolbar.tintColor = style.blackColor
        navigationController.toolbar.barTintColor = style.toolbarBackgroundColor
        navigationController.statusBarStyle = style.statusBarStyle
        navigationController.modalPresentationStyle = .formSheet
        navigationController.setViewControllers(viewControllers, animated: false)
        
    }
    
    // MARK: - Helper method
    
    private func openSettingsAlert() -> UIAlertController {
        let title = style.alertAccessDeniedTitle ?? Pellicola.localizedString("alert_access_denied.title")
        let message = style.alertAccessDeniedMessage ?? Pellicola.localizedString("alert_access_denied.message")
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: Pellicola.localizedString("alert_access_denied.later"), style: .default, handler: { [weak self] _ in
            self?.userDidCancel?()
        })
        alert.addAction(okAction)
        
        let settingsAction = UIAlertAction(title: Pellicola.localizedString("alert_access_denied.settings"), style: .cancel, handler: { _ in
            UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
        })
        alert.addAction(settingsAction)
        return alert
    }
    
    private func setupPresenter(with maxNumberOfSelections: Int) {
        let limit = maxNumberOfSelections <= 0 ? nil : maxNumberOfSelections
        imagesDataStorage = ImagesDataStorage(limit: limit)
        imagesDataFetcher = ImagesDataFetcher(targetSize: imageSize)
    }
    
    // MARK: - View Controller creation
    private func createAssetsCollectionViewController(withType albumType: AlbumType,
                                                      secondLevelType: AlbumType? = nil,
                                                      isRootLevel: Bool = true) -> AssetCollectionsViewController? {

        guard let imagesDataStorage = imagesDataStorage, let imagesDataFetcher = imagesDataFetcher else { return nil }
        let viewModel = AssetCollectionsViewModel(imagesDataStorage: imagesDataStorage,
                                                  imagesDataFetcher: imagesDataFetcher,
                                                  albumType: albumType,
                                                  secondLevelAlbumType: secondLevelType)
        
        let leftBarButtonType: AssetCollectionsViewController.LeftBarButtonType = isRootLevel ? .dismiss : .back
        let assetCollectionsVC = AssetCollectionsViewController(viewModel: viewModel, style: style, leftBarButtonType: leftBarButtonType)
        assetCollectionsVC.didStartProcessingImages = { [weak self] in
            self?.didStartProcessingImages?()
        }
        
        assetCollectionsVC.didFinishProcessingImages = { [weak self] urls in
            self?.navigationController.dismiss(animated: true) {
                self?.didFinishProcessingImages?(urls)
            }
        }

        assetCollectionsVC.didCancel = { [weak self] in
            self?.dismiss()
        }
        assetCollectionsVC.didSelectAlbum = { [weak self] assetCollection in
            guard let sSelf = self,
                let assetsViewController = sSelf.createAssetsViewController(with: assetCollection) else { return }
            sSelf.navigationController.pushViewController(assetsViewController, animated: true)
        }
        
        assetCollectionsVC.didSelectSecondLevelEntry = { [weak self] in
            guard let sSelf = self,
                let secondLevelType = secondLevelType,
                let secondLevelVC = sSelf.createAssetsCollectionViewController(withType: secondLevelType, secondLevelType: nil, isRootLevel: false) else { return }
            sSelf.navigationController.pushViewController(secondLevelVC, animated: true)
        }
        
        assetCollectionsVC.setToolbarItems(toolBarItems, animated: false)
        return assetCollectionsVC
    }
    
    private func createAssetsViewController(with album: AlbumData) -> AssetsViewController? {
        guard let imagesDataStorage = imagesDataStorage,
            let imagesDataFetcher = imagesDataFetcher else { return nil }
        let viewModel = AssetsViewModel(imagesDataStorage: imagesDataStorage,
                                        imagesDataFetcher: imagesDataFetcher,
                                        albumData: album)
        let assetsViewController = AssetsViewController(viewModel: viewModel, style: style)
        
        assetsViewController.didStartProcessingImages = { [weak self] in
            self?.didStartProcessingImages?()
        }
        
        assetsViewController.didFinishProcessingImages = { [weak self] urls in
            self?.navigationController.dismiss(animated: true) {
                self?.didFinishProcessingImages?(urls)
            }
        }
        
        assetsViewController.didPeekOnAsset = { [weak self] asset in
            self?.createDetailAssetViewController(with: asset)
        }
        
        assetsViewController.shouldUpdateToolbar = { [weak self] in
            self?.updateToolbar()
        }
        
        assetsViewController.setToolbarItems(toolBarItems, animated: false)
        return assetsViewController
    }
    
    private func createDetailAssetViewController(with asset: PHAsset) -> DetailAssetViewController {
        let viewModel = DetailAssetViewModel(asset: asset)
        let detailViewController = DetailAssetViewController(viewModel: viewModel)
        return detailViewController
    }
    
    private func dismiss() {
        navigationController.dismiss(animated: true) { [weak self] in
            self?.userDidCancel?()
        }
    }
}

//MARK: - Toolbar
extension PellicolaPresenter {
    private func updateToolbar() {
        guard let numberOfSelectedAssets = numberOfSelectedAssets,
            maxNumberOfSelections != 0, numberOfSelectedAssets > 0 else {
            navigationController.setToolbarHidden(true, animated: true)
            return
        }
        
        var toolbarText = String(format: Pellicola.localizedString("selected_assets"),
                                 numberOfSelectedAssets)
        if let maxNumberOfSelections = maxNumberOfSelections {
            toolbarText = String(format: Pellicola.localizedString("selected_assets_with_limit"),
                                 numberOfSelectedAssets,
                                 maxNumberOfSelections)
        }
        
        centerBarButtonToolbar.title = toolbarText
        navigationController.setToolbarHidden(false, animated: true)
    }
}

private class PellicolaNavigationController: UINavigationController {
    var statusBarStyle: UIStatusBarStyle?
    override var preferredStatusBarStyle: UIStatusBarStyle { return self.statusBarStyle ?? .default }
}
