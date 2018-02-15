//
//  PellicolaPresenter.swift
//  Pellicola
//
//  Created by francesco bigagnoli on 13/11/2017.
//

import Foundation
import Photos

public final class PellicolaPresenter: NSObject {
    
    @objc public var didSelectImages: (([UIImage]) -> Void)?
    @objc public var userDidCancel: (() -> Void)?
    
    private lazy var navigationController: UINavigationController = {
        return UINavigationController()
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
            guard case .authorized = status else {
                let alert = UIAlertController(title: NSLocalizedString("alert_access_denied.title", bundle: Bundle.framework, comment: ""),
                                              message: NSLocalizedString("alert_access_denied.message", bundle: Bundle.framework, comment: ""),
                                              preferredStyle: .alert)
                let okAction = UIAlertAction(title: NSLocalizedString("alert_access_denied.later", bundle: Bundle.framework, comment: ""), style: .default, handler: { [weak self] _ in
                    self?.userDidCancel?()
                })
                alert.addAction(okAction)
                
                let settingsAction = UIAlertAction(title: NSLocalizedString("alert_access_denied.settings", bundle: Bundle.framework, comment: ""), style: .cancel, handler: { _ in
                   UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                })
                alert.addAction(settingsAction)
                
                presentingViewController.present(alert, animated: true)
                return
            }
            
            guard let sSelf = self else { return }
            
            sSelf.setupPresenter(with: maxNumberOfSelections)
            
            guard let assetCollectionsVC = sSelf.createAssetsCollectionViewController() else { return }
            sSelf.navigationController.toolbar.tintColor = sSelf.style.blackColor
            sSelf.navigationController.toolbar.barTintColor = sSelf.style.toolbarBackgroundColor
            sSelf.navigationController.setViewControllers([assetCollectionsVC], animated: false)
            sSelf.navigationController.modalPresentationStyle = .formSheet
            presentingViewController.present(sSelf.navigationController, animated: true, completion: nil)
        }
        
    }
    
    // MARK: - Helper method
    
    private func setupPresenter(with maxNumberOfSelections: Int) {
        dataStorage = DataStorage(limit: maxNumberOfSelections <= 0 ? nil : maxNumberOfSelections)
        dataFetcher = DataFetcher()
    }
    
    // MARK: - View Controller creation
    
    private func createAssetsCollectionViewController() -> AssetCollectionsViewController? {
        guard let dataStorage = dataStorage, let dataFetcher = dataFetcher else { return nil }
        let viewModel = AssetCollectionsViewModel(dataStorage: dataStorage,
                                                  dataFetcher: dataFetcher)
        let assetCollectionsVC = AssetCollectionsViewController(viewModel: viewModel, style: style)
        assetCollectionsVC.didSelectImages = dismissWithImages
        assetCollectionsVC.didCancel = dismiss
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
        assetsViewController.didSelectImages = dismissWithImages
        assetsViewController.didPeekOnAsset = createDetailAssetViewController
        return assetsViewController
        
    }
    
    private func createDetailAssetViewController(with asset: PHAsset) -> DetailAssetViewController {
        let viewModel = DetailAssetViewModel(asset: asset)
        let detailViewController = DetailAssetViewController(viewModel: viewModel)
        return detailViewController
        
    }
    
    private func dismissWithImages(_ images: [UIImage]) {
        didSelectImages?(images)
        navigationController.dismiss(animated: true) { [weak self] in
            self?.clearMemory()
        }
    }
    
    private func dismiss() {
        navigationController.dismiss(animated: true) { [weak self] in
            self?.userDidCancel?()
            self?.clearMemory()
        }
    }
    
    private func clearMemory() {
        dataStorage = nil
        dataFetcher = nil
        navigationController.setViewControllers([], animated: false)
    }
}
