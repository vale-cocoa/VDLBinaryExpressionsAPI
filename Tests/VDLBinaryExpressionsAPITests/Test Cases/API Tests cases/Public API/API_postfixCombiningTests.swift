//
//  VDLBinaryExpressionsAPI
//  API_postfixCombiningTests.swift
//  
//
//  Created by Valeriano Della Longa on 10/02/2020.
//  Copyright (c) 2020 Valeriano Della Longa
//

import XCTest
@testable import VDLBinaryExpressionsAPI

final class API_postfixCombiningTests: XCTestCase {
    typealias Token = BinaryOperatorExpressionToken<MockBinaryOperator>
    
    // MARK: - Properties
    var sut: (lhs: [Token], rhs: [Token])!
    var validPostfixReturnedValueForBoth: Bool {
        (sut.lhs.validPostfix() != nil) && (sut.rhs.validPostfix() != nil)
        }
    
    // MARK: - Test lifecycle
    override func setUp() {
        super.setUp()
        
    }
    
    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }
    
    // MARK: - Given
    func givenValidSUT() {
        let lhs: [Token] = [.operand(10), .operand(20), .binaryOperator(.add)]
        let rhs: [Token] = [.operand(30), .operand(40), .binaryOperator(.add)]
        sut = (lhs, rhs)
    }
    
    func givenNotValidSUT() {
        let lhs: [Token] = [.operand(10), .operand(20), .binaryOperator(.add), .operand(50)]
        let rhs: [Token] = [.operand(30), .operand(40), .binaryOperator(.add)]
        sut = (lhs, rhs)
    }
    
    // MARK: - When
    func whenValidPostfixReturnsNilForOneExpression() {
        givenNotValidSUT()
    }
    
    func whenValidPostfixReturnsValueForBothExpressions() {
        givenValidSUT()
    }
    
    // MARK: - Tests
    func test_whenValidPostfixReturnsNilForOneExpression_throws() {
        // when
        whenValidPostfixReturnsNilForOneExpression()
        
        XCTAssertFalse(validPostfixReturnedValueForBoth)
        XCTAssertThrowsError(try sut.lhs.postfixCombining(using: .multiply, with: sut.rhs))
    }
    
    func test_whenValidPostfixReturnsValueForBothExpressions_doesntThrow() {
        // when
        whenValidPostfixReturnsValueForBothExpressions()
        
        // then
        XCTAssertTrue(validPostfixReturnedValueForBoth)
        XCTAssertNoThrow(try sut.lhs.postfixCombining(using: .multiply, with: sut.rhs))
    }
    
    func test_whenValidPostfixReturnsValueForBothExpressions_ReturnsConcatenatingLHSWithRHSWithOperatorAsToken() {
        // when
        whenValidPostfixReturnsValueForBothExpressions()
        let operation: MockBinaryOperator = .multiply
        let expectedResult: [Token] = sut.lhs + sut.rhs + [.binaryOperator(operation)]
        
        // then
        XCTAssertEqual(try! sut.lhs.postfixCombining(using: .multiply, with: sut.rhs), expectedResult)
    }
    
    func test_whenValidPostfixReturnsValueForBothExpressions_ReturnsValidPostfixExpression() {
        // when
        whenValidPostfixReturnsValueForBothExpressions()
        let result = try! sut.lhs.postfixCombining(using: .multiply, with: sut.rhs)
        
        // then
        XCTAssertTrue(_isValidPostfixNotation(expression: result))
    }
    
    var allTests = [
        ("test_whenValidPostfixReturnsNilForOneExpression_throws", test_whenValidPostfixReturnsNilForOneExpression_throws),
        ("test_whenValidPostfixReturnsValueForBothExpressions_doesntThrow", test_whenValidPostfixReturnsValueForBothExpressions_doesntThrow),
        ("test_whenValidPostfixReturnsValueForBothExpressions_ReturnsConcatenatingLHSWithRHSWithOperatorAsToken", test_whenValidPostfixReturnsValueForBothExpressions_ReturnsConcatenatingLHSWithRHSWithOperatorAsToken),
        ("test_whenValidPostfixReturnsValueForBothExpressions_ReturnsValidPostfixExpression", test_whenValidPostfixReturnsValueForBothExpressions_ReturnsValidPostfixExpression),
        
    ]
}
