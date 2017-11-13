//
//  PellicolaPresenter.swift
//  Pellicola
//
//  Created by francesco bigagnoli on 13/11/2017.
//

import Foundation

public final class PellicolaPresenter: NSObject {
    
    private weak var presenterViewController: UIViewController?
    
    @objc public func presentPellicola(on presenterViewController: UIViewController) {
        let albumsVC = AlbumsViewController(nibName: nil, bundle: Bundle(for: AlbumsViewController.self))
        let navigationController = UINavigationController(rootViewController: albumsVC)
        presenterViewController.present(navigationController, animated: true, completion: nil)
        self.presenterViewController = presenterViewController
    }
}
