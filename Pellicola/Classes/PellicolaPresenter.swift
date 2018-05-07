//
//  PellicolaPresenter.swift
//  Pellicola
//
//  Created by francesco bigagnoli on 13/11/2017.
//

import Foundation
import Photos

public final class PellicolaPresenter: NSObject {
    private let assetCollectionTypes: [PHAssetCollectionType] = [.smartAlbum, .album]
    private let smartAlbumSubtypes: [PHAssetCollectionSubtype]  = [.smartAlbumUserLibrary,
                                                                   .smartAlbumFavorites,
                                                                   .smartAlbumSelfPortraits,
                                                                   .smartAlbumScreenshots]
    private let otherAlbumSubtypes: [PHAssetCollectionSubtype] = [.albumRegular,
                                                                  .albumMyPhotoStream,
                                                                  .albumCloudShared,
                                                                  .albumSyncedEvent,
                                                                  .albumSyncedAlbum]
    
    @objc public var didSelectImages: (([UIImage]) -> Void)?
    @objc public var userDidCancel: (() -> Void)?
    
    private lazy var navigationController: PellicolaNavigationController = {
        return PellicolaNavigationController()
    }()
    
    var dataStorage: DataStorage?
    var dataFetcher: DataFetcher?
    
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
                guard let assetCollectionsVC = sSelf.createAssetsCollectionViewController() else { return }
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
        let title = style.alertAccessDeniedTitle ?? NSLocalizedString("alert_access_denied.title", bundle: Bundle.framework, comment: "")
        let message = style.alertAccessDeniedMessage ?? NSLocalizedString("alert_access_denied.message", bundle: Bundle.framework, comment: "")
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: NSLocalizedString("alert_access_denied.later", bundle: Bundle.framework, comment: ""), style: .default, handler: { [weak self] _ in
            self?.userDidCancel?()
        })
        alert.addAction(okAction)
        
        let settingsAction = UIAlertAction(title: NSLocalizedString("alert_access_denied.settings", bundle: Bundle.framework, comment: ""), style: .cancel, handler: { _ in
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        })
        alert.addAction(settingsAction)
        return alert
    }
    
    private func setupPresenter(with maxNumberOfSelections: Int) {
        dataStorage = DataStorage(limit: maxNumberOfSelections <= 0 ? nil : maxNumberOfSelections)
        dataFetcher = DataFetcher()
    }
    
    // MARK: - View Controller creation
    
    private func createAssetsCollectionViewController() -> AssetCollectionsViewController? {
        guard let dataStorage = dataStorage, let dataFetcher = dataFetcher else { return nil }
        let viewModel = AssetCollectionsViewModel(dataStorage: dataStorage,
                                                  dataFetcher: dataFetcher,
                                                  collectionTypes: assetCollectionTypes,
                                                  firstLevelSubtypes: smartAlbumSubtypes,
                                                  secondLevelSubtypes: otherAlbumSubtypes)
        let assetCollectionsVC = AssetCollectionsViewController(viewModel: viewModel, style: style)
        assetCollectionsVC.didSelectImages = { [weak self] images in
            self?.dismissWithImages(images)
        }
        assetCollectionsVC.didCancel = { [weak self] in
            self?.dismiss()
        }
        assetCollectionsVC.didSelectAssetCollection = { [weak self] assetCollection in
            guard let sSelf = self,
                let assetsViewController = sSelf.createAssetsViewController(with: assetCollection) else { return }
            sSelf.navigationController.pushViewController(assetsViewController, animated: true)
        }
        return assetCollectionsVC
    }
    
    private func createAssetsViewController(with assetCollection: PHAssetCollection) -> AssetsViewController? {
        guard let dataStorage = dataStorage, let dataFetcher = dataFetcher else { return nil }
        let viewModel = AssetsViewModel(dataStorage: dataStorage,
                                        dataFetcher: dataFetcher,
                                        assetCollection: assetCollection)
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
