//
//  PellicolaTests.swift
//  Pellicola_Tests
//
//  Created by Andrea Antonioni on 19/01/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
@testable import Pellicola

class PellicolaTests: XCTestCase {
    
    func testInitWithNegativeNumberOfSelections() {
        let pellicolaPresenter = PellicolaPresenter(maxNumberOfSelections: -1)
        XCTAssertNil(pellicolaPresenter.dataStorage.limit)
    }
    
    func testInitWithZeroNumberOfSelections() {
        let pellicolaPresenter = PellicolaPresenter(maxNumberOfSelections: 0)
        XCTAssertNil(pellicolaPresenter.dataStorage.limit)
    }
    
    func testInitWithLimitedLimit() {
        let pellicolaPresenter = PellicolaPresenter(maxNumberOfSelections: 3)
        XCTAssertEqual(pellicolaPresenter.dataStorage.limit, 3)
    }
    
}

