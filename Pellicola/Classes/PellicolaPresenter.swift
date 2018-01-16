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
    private var dataStorageObservation: NSKeyValueObservation?
    
    @objc public func presentPellicola(on presentingViewController: UIViewController) {
        dataStorage = DataStorage(limit: maxNumberOfSelections != 0 ? maxNumberOfSelections : nil)
        
        if maxNumberOfSelections == 1 {
            dataStorageObservation = dataStorage.observe(\.images) { [weak self] dataStorage, _ in
                guard dataStorage.images.count > 0 else { return }
                self?.doneButtonTapped()
            }
        }
        
        let assetCollectionsVC = createAssetsCollectionViewController()
        navigationController.setViewControllers([assetCollectionsVC], animated: false)
        presentingViewController.present(navigationController, animated: true, completion: nil)
    }
    
    // MARK: - Action
    
    private func cancelButtonTapped() {
        navigationController.dismiss(animated: true) { [weak self] in
            self?.userDidCancel?()
        }
    }
    
    private func doneButtonTapped() {
        navigationController.dismiss(animated: true) { [weak self] in
            guard let sSelf = self else { return }
            sSelf.didSelectImages?(sSelf.dataStorage.getImagesOrderedBySelection())
        }
    }
    
    // MARK: - View Controller creation
    
    private func createAssetsCollectionViewController() -> AssetCollectionsViewController {
        let viewModel = AssetCollectionsViewModel(dataStorage: dataStorage)
        let assetCollectionsVC = AssetCollectionsViewController(viewModel: viewModel)
        assetCollectionsVC.cancelBarButtonAction = cancelButtonTapped
        assetCollectionsVC.doneBarButtonAction = doneButtonTapped
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
        assetsViewController.doneBarButtonAction = doneButtonTapped
        return assetsViewController
        
    }
}
