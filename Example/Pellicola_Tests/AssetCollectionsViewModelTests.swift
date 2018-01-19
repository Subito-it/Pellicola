//
//  AssetCollectionsViewModelTests.swift
//  Pellicola_Tests
//
//  Created by Andrea Antonioni on 19/01/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
@testable import Pellicola

class AssetCollectionsViewModelTests: XCTestCase {
    
    var dataStorage: DataStorage!
    var dataFetcher: DataFetcher!
    var viewModel: AssetCollectionsViewModel!
    
    override func setUp() {
        super.setUp()
        
        dataStorage = DataStorage(limit: 3)
        dataFetcher = DataFetcher()
        viewModel = AssetCollectionsViewModel(dataStorage: dataStorage, dataFetcher: dataFetcher)
        
    }
    
    override func tearDown() {
        dataStorage = nil
        dataFetcher = nil
        viewModel = nil
        super.tearDown()
    }
    
    func testGetSelectedImagesSorted() {
        
        var array = [(UIImage.image(with: .yellow), UUID().uuidString),
                     (UIImage.image(with: .green), UUID().uuidString),
                     (UIImage.image(with: .blue), UUID().uuidString)]
        
        array.forEach{
            dataStorage.addImage($0.0, withIdentifier: $0.1)
        }
        
        dataStorage.removeImage(withIdentifier: array[1].1)
        array.remove(at: 1)
        
        XCTAssertEqual(array.flatMap{$0.0}, viewModel.getSelectedImages())
        
    }
    
    func testOnChangeSelectedAssets() {
        
        let array = [(UIImage.image(with: .yellow), UUID().uuidString),
                     (UIImage.image(with: .green), UUID().uuidString),
                     (UIImage.image(with: .blue), UUID().uuidString)]
        
        array.forEach{
            dataStorage.addImage($0.0, withIdentifier: $0.1)
        }
        
        viewModel.onChangeSelectedAssets = { numberOfSelectedAssets in
            XCTAssertEqual(numberOfSelectedAssets, array.count + 1)
        }
        
        dataStorage.addImage(UIImage.image(with: .gray), withIdentifier: UUID().uuidString)
        
    }
    
}
