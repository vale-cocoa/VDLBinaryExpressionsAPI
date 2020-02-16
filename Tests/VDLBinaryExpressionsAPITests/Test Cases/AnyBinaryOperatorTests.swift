//
//  VDLBinaryExpressionsAPI
//  AnyBinaryOperatorTests.swift
//  
//
//  Created by Valeriano Della Longa on 16/02/2020.
//  Copyright (c) 2020 Valeriano Della Longa
//

import XCTest
@testable import VDLBinaryExpressionsAPI

final class AnyBinaryOperatorTests: XCTestCase {
    // MARK: - Test lifecycle
    
    // MARK: - Given
    
    // MARK: - When
    
    // MARK: - Tests
    func test_whenInitFromConcreteBase_conformsToBinaryOperationProtocol() {
        // given
        let concrete = MockBinaryOperator.add
        
        // when
        let sut = AnyBinaryOperator.init(concrete)
        
        // then
        XCTAssertNotNil(sut.priority)
        XCTAssertNotNil(sut.associativity)
        XCTAssertNotNil(sut.binaryOperation)
        XCTAssert(type(of: sut).Operand.self == type(of: concrete).Operand.self)
        XCTAssert(type(of: sut.associativity).self == type(of: concrete.associativity).self)
        XCTAssert(type(of: sut.priority).self == type(of: concrete.priority).self)
        XCTAssert(type(of: sut.binaryOperation).self == type(of: concrete.binaryOperation).self)
    }
    
    static var allTests = [
        ("test_whenInitFromConcreteBase_conformsToBinaryOperationProtocol", test_whenInitFromConcreteBase_conformsToBinaryOperationProtocol),
        
    ]
    
}
