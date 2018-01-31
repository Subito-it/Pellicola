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
        setupPresenter(with: maxNumberOfSelections)
        
        guard let assetCollectionsVC = createAssetsCollectionViewController() else { return }
        navigationController.toolbar.tintColor = style.blackColor
        navigationController.toolbar.barTintColor = style.toolbarBackgroundColor
        navigationController.setViewControllers([assetCollectionsVC], animated: false)
        navigationController.modalPresentationStyle = .formSheet
        presentingViewController.present(navigationController, animated: true, completion: nil)
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
        assetCollectionsVC.didDismiss = clearMemory
        assetCollectionsVC.userDidCancel = userDidCancel
        assetCollectionsVC.didSelectImages = didSelectImages
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
        assetsViewController.didDismiss = clearMemory
        assetsViewController.didSelectImages = didSelectImages
        assetsViewController.didPeekOnAsset = createDetailAssetViewController
        return assetsViewController
        
    }
    
    private func createDetailAssetViewController(with asset: PHAsset) -> DetailAssetViewController {
        let viewModel = DetailAssetViewModel(asset: asset)
        let detailViewController = DetailAssetViewController(viewModel: viewModel)
        return detailViewController
        
    }
    
    private func clearMemory() {
        dataStorage = nil
        dataFetcher = nil
        navigationController.setViewControllers([], animated: false)
    }
}
