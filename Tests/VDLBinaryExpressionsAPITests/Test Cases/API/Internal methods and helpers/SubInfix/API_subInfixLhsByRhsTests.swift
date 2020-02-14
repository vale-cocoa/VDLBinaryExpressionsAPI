//
//  VDLBinaryExpressionsAPI
//  API_subInfixLhsByRhsTests.swift
//  
//
//  Created by Valeriano Della Longa on 14/02/2020.
//  Copyright (c) 2020 Valeriano Della Longa
//

import XCTest
@testable import VDLBinaryExpressionsAPI

final class API_subInfixLhsByRhsTests: XCTestCase {
    typealias SubInfix = _SubInfixExpression<MockBinaryOperator>
    typealias Token = BinaryOperatorExpressionToken<MockBinaryOperator>
    
    // MARK: - Properties
    var sut: (lhs: SubInfix, operation: MockBinaryOperator, rhs: SubInfix)!
    var result: [Token]!
    var expectedResult: [Token]!
    
    // MARK: - Test lifecycle
    override func setUp() {
        super.setUp()
        
    }
    
    override func tearDown() {
        sut = nil
        result = nil
        expectedResult = nil
        
        super.tearDown()
    }
    
    // MARK: - Given
    
    // MARK: - When
    
    // MARK: - Tests
    func test_whenEitherOrBothLhsAndRhsAreEmpty_throws() {
        // given
        let empty: SubInfix = ([], nil)
        let lhs: SubInfix = try! _subInfix(fromInfix: [.operand(10)])
        let rhs: SubInfix = try! _subInfix(fromInfix: [.operand(20)])
        
        // when
        // then
        XCTAssertThrowsError(try _subInfix(lhs: empty, by: .add, rhs: rhs))
        XCTAssertThrowsError(try _subInfix(lhs: lhs, by: .add, rhs: empty))
        XCTAssertThrowsError(try _subInfix(lhs: empty, by: .add, rhs: empty))
    }
    
    func test_whenEitherOrBothLhsAndRhsExpressionsAreNotValidInfix_throws() {
        // given
        let validLhs: SubInfix = ([.operand(10)], nil)
        let validRhs: SubInfix = ([.operand(20)], nil)
        let notValid: SubInfix = ([.operand(10), .operand(30), .binaryOperator(.add)], .add)
        
        // when
        // then
        XCTAssertThrowsError(try  _subInfix(lhs: validLhs, by: .add, rhs: notValid))
        XCTAssertThrowsError(try  _subInfix(lhs: notValid, by: .add, rhs: notValid))
        XCTAssertThrowsError(try  _subInfix(lhs: notValid, by: .add, rhs: validRhs))
    }
    
    var allTests = [
        ("test_whenEitherOrBothLhsAndRhsAreEmpty_throws", test_whenEitherOrBothLhsAndRhsAreEmpty_throws),
        ("test_whenEitherOrBothLhsAndRhsExpressionsAreNotValidInfix_throws", test_whenEitherOrBothLhsAndRhsExpressionsAreNotValidInfix_throws),
        
    ]
    
}
