//
//  OrderedImageTests.swift
//  Pellicola_Tests
//
//  Created by Andrea Antonioni on 18/01/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
@testable import Pellicola

class OrderedImageTests: XCTestCase {
    
    func testCompareOrderedImage() {
        let img1 = OrderedImage(image: UIImage(), index: 1)
        let img2 = OrderedImage(image: UIImage(), index: 2)
        
        XCTAssertGreaterThan(img2, img1)
    }
    
}

