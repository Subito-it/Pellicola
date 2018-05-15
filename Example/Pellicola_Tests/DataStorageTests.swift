//
//  DataStorageTests.swift
//  Pellicola_Tests
//
//  Created by Andrea Antonioni on 18/01/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
@testable import Pellicola

class DataStorageTests: XCTestCase {
    
    var dataStorage: ImagesDataStorage!
    
    let limit = 5
    
    override func setUp() {
        super.setUp()
        
        dataStorage = ImagesDataStorage(limit: limit)
    }
    
    override func tearDown() {
        dataStorage = nil
        super.tearDown()
    }
    
    func testAddOneImage() {
        dataStorage.addImage(UIImage(), withIdentifier: UUID().uuidString)
        
        XCTAssertEqual(dataStorage.images.count, 1)
    }
    
    func testAddAlreadyStoredImage() {
        let imageIdentifier = UUID().uuidString
        
        dataStorage.addImage(UIImage(), withIdentifier: imageIdentifier)
        dataStorage.addImage(UIImage(), withIdentifier: imageIdentifier)
        
        XCTAssertEqual(dataStorage.images.count, 1)
    }
    
    func testAddImageWhenLimitReached() {
        
        for _ in 0..<limit+1 {
            dataStorage.addImage(UIImage(), withIdentifier: UUID().uuidString)
        }
        
        XCTAssertEqual(dataStorage.images.count, Int(dataStorage.limit!))
    }
    
    func testContainsImage() {
        let imageIdentifier = UUID().uuidString
        dataStorage.addImage(UIImage(), withIdentifier: imageIdentifier)
        
        XCTAssert(dataStorage.containsImage(withIdentifier: imageIdentifier),
                  "DataStorage doesn't containt the image")
    }
    
    func testRemoveOneImage() {
        
        let imageIdentifier = UUID().uuidString
        dataStorage.addImage(UIImage(), withIdentifier: imageIdentifier)
        dataStorage.removeImage(withIdentifier: imageIdentifier)
        
        XCTAssertEqual(dataStorage.images.count, 0)
    }
    
    func testRemoveUnstoredImage() {
        dataStorage.addImage(UIImage(), withIdentifier: UUID().uuidString)
        dataStorage.removeImage(withIdentifier: UUID().uuidString)
        
        XCTAssertEqual(dataStorage.images.count, 1)
    }
    
    func testOrderedImagesStore() {
        let array = [UIImage.image(with: .yellow),
                     UIImage.image(with: .green)]
        
        array.forEach{
            dataStorage.addImage($0, withIdentifier: UUID().uuidString)
        }
        
        XCTAssertEqual(array, dataStorage.getImagesOrderedBySelection())
    }
    
    func testOrderedImagesStoreAfterRemotion() {
        var array = [(UIImage.image(with: .yellow), UUID().uuidString),
                     (UIImage.image(with: .green), UUID().uuidString),
                     (UIImage.image(with: .blue), UUID().uuidString)]
        
        array.forEach{
            dataStorage.addImage($0.0, withIdentifier: $0.1)
        }
        
        dataStorage.removeImage(withIdentifier: array[1].1)
        array.remove(at: 1)
        
        XCTAssertEqual(array.compactMap{$0.0}, dataStorage.getImagesOrderedBySelection())
    }
    
}
