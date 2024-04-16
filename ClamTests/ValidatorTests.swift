//
//  ValidatorTests.swift
//  ClamTests
//
//  Created by TechPrastish on 15/04/24.
//


import XCTest
@testable import Clam

class ValidatorTests: XCTestCase {

    var validation: Validations!
    
    override func setUp()  {
        super.setUp()
        validation = Validations()
    }
    override func tearDown() {
        validation = nil
        super.tearDown()
    }
    
    func testValidEmail() throws {
        XCTAssertNoThrow(try validation.validateEmail("sagar@gmail.com"))
    }
    func testValidPassword() throws {
        XCTAssertNoThrow(try validation.validatePassword("212"))
    }
}
