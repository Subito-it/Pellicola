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
    
    @objc public var didSelectImages: (([UIImage]) -> Void)?
    @objc public var userDidCancel: (() -> Void)?
    
    private lazy var navigationController: PellicolaNavigationController = {
        return PellicolaNavigationController()
    }()
    
    var imagesDataStorage: ImagesDataStorage?
    var imagesDataFetcher: ImagesDataFetcher?
    
    let style: PellicolaStyleProtocol
    
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
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        })
        alert.addAction(settingsAction)
        return alert
    }
    
    private func setupPresenter(with maxNumberOfSelections: Int) {
        imagesDataStorage = ImagesDataStorage(limit: maxNumberOfSelections <= 0 ? nil : maxNumberOfSelections)
        imagesDataFetcher = ImagesDataFetcher()
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
        assetCollectionsVC.didSelectImages = { [weak self] images in
            self?.dismissWithImages(images)
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
        
        return assetCollectionsVC
    }
    
    private func createAssetsViewController(with album: AlbumData) -> AssetsViewController? {
        guard let imagesDataStorage = imagesDataStorage,
            let imagesDataFetcher = imagesDataFetcher else { return nil }
        let viewModel = AssetsViewModel(imagesDataStorage: imagesDataStorage,
                                        imagesDataFetcher: imagesDataFetcher,
                                        albumData: album)
        let assetsViewController = AssetsViewController(viewModel: viewModel, style: style)
        assetsViewController.didSelectImages = { [weak self] images in
            self?.dismissWithImages(images)
        }
        
        assetsViewController.didPeekOnAsset = { [weak self] asset in
            self?.createDetailAssetViewController(with: asset)
        }
        
        return assetsViewController
    }
    
    private func createDetailAssetViewController(with asset: PHAsset) -> DetailAssetViewController {
        let viewModel = DetailAssetViewModel(asset: asset)
        let detailViewController = DetailAssetViewController(viewModel: viewModel)
        return detailViewController
    }
    
    private func dismissWithImages(_ images: [UIImage]) {
        didSelectImages?(images)
        navigationController.dismiss(animated: true)
    }
    
    private func dismiss() {
        navigationController.dismiss(animated: true) { [weak self] in
            self?.userDidCancel?()
        }
    }
}

private class PellicolaNavigationController: UINavigationController {
    var statusBarStyle: UIStatusBarStyle?
    override var preferredStatusBarStyle: UIStatusBarStyle { return self.statusBarStyle ?? .default }
}
