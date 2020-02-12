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

final class API_postfixByWithTests: XCTestCase {
    typealias Token = BinaryOperatorExpressionToken<MockBinaryOperator>
    
    // MARK: - Properties
    var sut: (lhs: [Token], rhs: [Token])!
    var validPostfixReturnedValueForBoth: Bool {
        (sut.lhs.validPostfix() != nil) && (sut.rhs.validPostfix() != nil)
    }
    
    var validPostfixReturnedNotEmptyValueForBoth: Bool {
        guard
            let lhsPostfix = sut.lhs.validPostfix(),
            let rhsPostfix = sut.rhs.validPostfix(),
            !lhsPostfix.isEmpty,
            !rhsPostfix.isEmpty
            else { return false }
        
        return true
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
    func givenEmptySUT() {
        sut = ([], [])
    }
    
    func givenLhsExpressionEmptyRhsValid() {
        let rhs: [Token] = [.operand(30), .operand(40), .binaryOperator(.add)]
        sut = ([], rhs)
    }
    
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
    func whenExpressionsBothEmpty() {
        givenEmptySUT()
    }
    
    func whenOneExpressionEmptyOtherValid() {
        givenLhsExpressionEmptyRhsValid()
    }
    
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
        XCTAssertThrowsError(try sut.lhs.postfix(by: .multiply, with: sut.rhs))
    }
    
    func test_whenOneExpressionEmptyOtherValid_throws() {
        // when
        whenOneExpressionEmptyOtherValid()
        
        // then
        XCTAssertTrue(validPostfixReturnedValueForBoth)
        XCTAssertFalse(validPostfixReturnedNotEmptyValueForBoth)
        XCTAssertThrowsError(try sut.lhs.postfix(by: .multiply, with: sut.rhs))
    }
    
    func test_whenBothExpressionEmpty_throws() {
        // when
        whenExpressionsBothEmpty()
        
        // then
        XCTAssertTrue(validPostfixReturnedValueForBoth)
        XCTAssertFalse(validPostfixReturnedNotEmptyValueForBoth)
        XCTAssertThrowsError(try sut.lhs.postfix(by: .multiply, with: sut.rhs))
    }
    
    func test_whenValidPostfixReturnsNotEmptyValueForBothExpressions_doesntThrow() {
        // when
        whenValidPostfixReturnsValueForBothExpressions()
        
        // then
        XCTAssertTrue(validPostfixReturnedValueForBoth)
        XCTAssertTrue(validPostfixReturnedNotEmptyValueForBoth)
        XCTAssertNoThrow(try sut.lhs.postfix(by: .multiply, with: sut.rhs))
    }
    
    func test_whenValidPostfixReturnsNotEmptyValueForBothExpressions_ReturnsConcatenatingLHSWithRHSWithOperatorAsToken() {
        // when
        whenValidPostfixReturnsValueForBothExpressions()
        let operation: MockBinaryOperator = .multiply
        let expectedResult: [Token] = sut.lhs + sut.rhs + [.binaryOperator(operation)]
        
        // then
        // guaranted by test_whenValidPostfixReturnsNotEmptyValueForBothExpressions_doesntThrow()
        XCTAssertEqual(try! sut.lhs.postfix(by: .multiply, with: sut.rhs), expectedResult)
    }
    
    func test_whenValidPostfixReturnsNotEmptyValueForBothExpressions_ReturnsValidPostfixExpression() {
        // when
        whenValidPostfixReturnsValueForBothExpressions()
        // guaranted by test_whenValidPostfixReturnsNotEmptyValueForBothExpressions_doesntThrow()
        let result = try! sut.lhs.postfix(by: .multiply, with: sut.rhs)
        
        // then
        XCTAssertTrue(_isValidPostfixNotation(expression: result))
    }
    
    var allTests = [
        ("test_whenValidPostfixReturnsNilForOneExpression_throws", test_whenValidPostfixReturnsNilForOneExpression_throws),
        ("test_whenOneExpressionEmptyOtherValid_throws", test_whenOneExpressionEmptyOtherValid_throws),
        ("test_whenBothExpressionEmpty_throws", test_whenBothExpressionEmpty_throws),
        ("test_whenValidPostfixReturnsNotEmptyValueForBothExpressions_doesntThrow", test_whenValidPostfixReturnsNotEmptyValueForBothExpressions_doesntThrow),
        ("test_whenValidPostfixReturnsNotEmptyValueForBothExpressions_ReturnsConcatenatingLHSWithRHSWithOperatorAsToken", test_whenValidPostfixReturnsNotEmptyValueForBothExpressions_ReturnsConcatenatingLHSWithRHSWithOperatorAsToken),
        ("test_whenValidPostfixReturnsNotEmptyValueForBothExpressions_ReturnsValidPostfixExpression", test_whenValidPostfixReturnsNotEmptyValueForBothExpressions_ReturnsValidPostfixExpression),
        
    ]
}
