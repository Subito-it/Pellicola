//
//  AlbumViewController.swift
//  PellicolaDemo
//
//  Created by francesco bigagnoli on 10/11/2017.
//  Copyright © 2017 Francesco Bigagnoli. All rights reserved.
//

import UIKit
import Photos

public final class AlbumsViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        customizeUI()
        
    }
    
    @objc func actionDismiss() {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: UI
extension AlbumsViewController {
    private func customizeUI() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(actionDismiss))
        title = NSLocalizedString("albums.title", bundle:  Bundle(for: AlbumsViewController.self), comment: "")
    }
}

//MARK: UITableViewDataSource
extension AlbumsViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}

//MARK: UITableViewDelegate
extension AlbumsViewController: UITableViewDelegate {
    
}
