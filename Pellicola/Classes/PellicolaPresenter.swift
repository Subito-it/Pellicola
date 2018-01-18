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
    let maxNumberOfSelections: UInt
    
    private lazy var navigationController: UINavigationController = {
        return UINavigationController()
    }()
    
    let dataStorage: DataStorage
    let dataFetcher: DataFetcher
    
    @objc public init(maxNumberOfSelections: UInt) {
        self.maxNumberOfSelections = maxNumberOfSelections
        dataStorage = DataStorage(limit: maxNumberOfSelections == 0 ? UInt.max : maxNumberOfSelections)
        dataFetcher = DataFetcher()
        super.init()
    }
    
    @objc public func present(on presentingViewController: UIViewController) {
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
        assetCollectionsVC.didSelectAssetCollection = { [weak self] assetCollection in
            guard let sSelf = self else { return }
            let assetsViewController = sSelf.createAssetsViewController(with: assetCollection)
            sSelf.navigationController.pushViewController(assetsViewController, animated: true)
        }
        return assetCollectionsVC
    }
    
    private func createAssetsViewController(with assetCollection: PHAssetCollection) -> AssetsViewController {
        let viewModel = AssetsViewModel(dataStorage: dataStorage,
                                        dataFetcher: dataFetcher,
                                        assetCollection: assetCollection)
        let assetsViewController = AssetsViewController(viewModel: viewModel)
        assetsViewController.didSelectImages = didSelectImages
        return assetsViewController
        
    }
}
