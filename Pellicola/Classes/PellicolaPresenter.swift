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
    
    /*
     - ==0 Unlimited
     - ==1 Single selection
     - >1  Limited selection
     */
    @objc public var maxNumberOfSelections: UInt = 1
    
    private lazy var navigationController: UINavigationController = {
        return UINavigationController()
    }()
    
    private var dataStorage = DataStorage(limit: 1)
    private var dataFetcher = DataFetcher()
    
    @objc public func presentPellicola(on presentingViewController: UIViewController) {
        dataStorage = DataStorage(limit: maxNumberOfSelections != 0 ? maxNumberOfSelections : nil)
        
        let assetCollectionsVC = createAssetsCollectionViewController()
        navigationController.setViewControllers([assetCollectionsVC], animated: false)
        presentingViewController.present(navigationController, animated: true, completion: nil)
    }
    
    // MARK: - View Controller creation
    
    private func createAssetsCollectionViewController() -> AssetCollectionsViewController {
        let viewModel = AssetCollectionsViewModel(dataStorage: dataStorage,
                                                  dataFetcher: dataFetcher)
        let assetCollectionsVC = AssetCollectionsViewController(viewModel: viewModel)
        assetCollectionsVC.userDidCancel = userDidCancel
        assetCollectionsVC.didSelectImages = didSelectImages
        assetCollectionsVC.didSelectAssetCollection = { assetCollection in
            let assetsViewController = self.createAssetsViewController(assetCollection: assetCollection)
            self.navigationController.pushViewController(assetsViewController, animated: true)
        }
        return assetCollectionsVC
    }
    
    private func createAssetsViewController(assetCollection: PHAssetCollection) -> AssetsViewController {
        let viewModel = AssetsViewModel(dataStorage: dataStorage,
                                        dataFetcher: dataFetcher,
                                        assetCollection: assetCollection)
        let assetsViewController = AssetsViewController(viewModel: viewModel)
        assetsViewController.didSelectImages = didSelectImages
        return assetsViewController
        
    }
}
