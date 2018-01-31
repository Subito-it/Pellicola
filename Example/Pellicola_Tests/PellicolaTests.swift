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
    
    var pellicolaPresenter: PellicolaPresenter!
    
    override func setUp() {
        super.setUp()
        pellicolaPresenter = PellicolaPresenter(style: DefaultPellicolaStyle())
    }
    
    override func tearDown() {
        pellicolaPresenter = nil
        super.tearDown()
    }
    
    func testInitWithNegativeNumberOfSelections() {
        pellicolaPresenter.present(on: UIViewController(), maxNumberOfSelections: -1)
        XCTAssertNil(pellicolaPresenter.dataStorage!.limit)
    }
    
    func testInitWithZeroNumberOfSelections() {
        pellicolaPresenter.present(on: UIViewController(), maxNumberOfSelections: 0)
        XCTAssertNil(pellicolaPresenter.dataStorage!.limit)
    }
    
    func testInitWithLimitedLimit() {
        pellicolaPresenter.present(on: UIViewController(), maxNumberOfSelections: 3)
        XCTAssertEqual(pellicolaPresenter.dataStorage!.limit, 3)
    }
    
}

