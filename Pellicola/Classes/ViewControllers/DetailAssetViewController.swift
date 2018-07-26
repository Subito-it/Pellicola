//
//  DetailAssetViewController.swift
//  Pellicola
//
//  Created by Andrea Antonioni on 24/01/2018.
//

import UIKit
import Photos

class DetailAssetViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    let viewModel: DetailAssetViewModel
    
    init(viewModel: DetailAssetViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: Pellicola.frameworkBundle)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.contentMode = .scaleAspectFit

        viewModel.download(size: imageView.frame.size) { [weak self] (image) in
            self?.imageView.image = image
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
