//
//  API_convertToRPNTests.swift
//  
//
//  Created by Valeriano Della Longa on 07/02/2020.
//

import XCTest
@testable import VDLBinaryExpressionsAPI

final class API_convertToRPNTests: XCTestCase {
    typealias Token = BinaryOperatorExpressionToken<MockBinaryOperator>
    // MARK: - Properties
    var sut: [Token]!
    
    // MARK: - Test lifecycle
    override func setUp() {
        super.setUp()
        
    }
    
    override func tearDown() {
        self.sut = nil
        
        super.tearDown()
    }
    
    // MARK: - Given
    
    // MARK: - When
    func whenEmpty() {
        sut = []
    }
    
    // MARK: - Tests
    func test_whenEmpty_doesntThrow() {
        // when
        whenEmpty()
        
        // then
        XCTAssertNoThrow(try _convertToRPN(infixExpression: sut))
    }
    
    func test_whenEmpty_returnsEmpty() {
        // when
        whenEmpty()
        // guaranted by test_whenEmpty_doesntThrow()
        let result = try! _convertToRPN(infixExpression: sut)
        
        // then
        XCTAssertTrue(result.isEmpty)
    }
    
    func test_whenOperationOnly_throws() {
        // when
        sut = [.binaryOperator(.add)]
        
        // then
        XCTAssertThrowsError(try _convertToRPN(infixExpression: sut))
    }
    
    func test_whenClosingBracketDoesntMatchAPreviousOpenBracket_throws() {
        // when
        sut = [.operand(10), .binaryOperator(.add), .operand(20), .closingBracket]
        
        // then
        XCTAssertThrowsError(try _convertToRPN(infixExpression: sut))
    }
    
    func test_whenOpeningBracketIsNotMatchedByClosingBracket_throws() {
        // when
        sut = [.openingBracket, .operand(10), .binaryOperator(.add), .operand(20)]
        
        // then
        XCTAssertThrowsError(try _convertToRPN(infixExpression: sut))
    }
    
    func test_whenOpeningBracketOperandClosingBracket_doesntThrow() {
        // when
        sut = [.openingBracket, .operand(10), .closingBracket]
        
        // then
        XCTAssertNoThrow(try _convertToRPN(infixExpression: sut))
    }
    
    func test_whenOpeningBracketThenValidInfixThenClosingBracket_doesntThrow() {
        // when
        sut = [.openingBracket, .operand(10), .binaryOperator(.add), .operand(20), .closingBracket]
        
        // then
        XCTAssertNoThrow(try _convertToRPN(infixExpression: sut))
    }
    
    func test_whenValidInfixContainingFailingOperation_doesntThrow() {
        // when
        sut = [.operand(10), .binaryOperator(.failingOperation), .operand(20)]
        
        // then
        XCTAssertNoThrow(try _convertToRPN(infixExpression: sut))
    }
    
    func test_whenComplexValidInfix_doesntThrow() {
        // when
        sut = [.openingBracket, .operand(10), .binaryOperator(.add), .operand(20), .closingBracket, .binaryOperator(.multiply), .openingBracket, .operand(30), .binaryOperator(.add), .operand(40), .closingBracket]
        
       // then
        XCTAssertNoThrow(try _convertToRPN(infixExpression: sut))
    }
    
    func test_whenNoBrackets_placesProperlyOperatorsWithDifferentPrecedence() {
        // given
        var expectedResult: [Token] = [.operand(10), .operand(20), .operand(30), .binaryOperator(.multiply), .binaryOperator(.add)]
        
        // when
        sut = [.operand(10), .binaryOperator(.add), .operand(20), .binaryOperator(.multiply), .operand(30)]
        var result = try! _convertToRPN(infixExpression: sut)
        
        // then
        XCTAssertEqual(result, expectedResult)
        
        // given
        expectedResult = [.operand(10), .operand(20), .binaryOperator(.multiply), .operand(30), .binaryOperator(.add)]
        
        // when
        sut = [.operand(10), .binaryOperator(.multiply), .operand(20), .binaryOperator(.add), .operand(30)]
        result = try! _convertToRPN(infixExpression: sut)
        
        // then
        XCTAssertEqual(result, expectedResult)
    }
    
    func test_whenBracketed_placesProperlyOperatorsWithDifferentPrecedence() {
        // given
        var expectedResult: [Token] = [.operand(10), .operand(20), .binaryOperator(.add), .operand(30), .operand(40), .binaryOperator(.add), .binaryOperator(.multiply)]
        
        // when
        sut = [.openingBracket, .operand(10), .binaryOperator(.add), .operand(20), .closingBracket, .binaryOperator(.multiply), .openingBracket, .operand(30), . binaryOperator(.add), .operand(40), .closingBracket]
        var result = try! _convertToRPN(infixExpression: sut)
        
        // then
        XCTAssertEqual(result, expectedResult)
        
        // given
        expectedResult = [.operand(10), .operand(20), .binaryOperator(.multiply), .operand(30), .operand(40), .binaryOperator(.multiply), .binaryOperator(.add)]
        
        // when
        sut = [.openingBracket, .operand(10), .binaryOperator(.multiply), .operand(20), .closingBracket, .binaryOperator(.add), .openingBracket, .operand(30), . binaryOperator(.multiply), .operand(40), .closingBracket]
        result = try! _convertToRPN(infixExpression: sut)
        
        // then
        XCTAssertEqual(result, expectedResult)
        
        // given
        expectedResult = [.operand(10), .operand(20), .binaryOperator(.add), .operand(30), .binaryOperator(.multiply)]
        
        // when
        sut = [.openingBracket, .operand(10), .binaryOperator(.add), .operand(20), .closingBracket, .binaryOperator(.multiply), .operand(30)]
        result = try! _convertToRPN(infixExpression: sut)
        
        // then
        XCTAssertEqual(result, expectedResult)
    }
    
    static var allTests = [
        ("test_whenEmpty_doesntThrow", test_whenEmpty_doesntThrow),
        ("test_whenEmpty_returnsEmpty", test_whenEmpty_returnsEmpty),
        ("test_whenOperationOnly_throws", test_whenOperationOnly_throws),
        ("test_whenClosingBracketDoesntMatchAPreviousOpenBracket_throws", test_whenClosingBracketDoesntMatchAPreviousOpenBracket_throws),
        ("test_whenOpeningBracketOperandClosingBracket_doesntThrow", test_whenOpeningBracketOperandClosingBracket_doesntThrow),
       ("test_whenOpeningBracketThenValidInfixThenClosingBracket_doesntThrow", test_whenOpeningBracketThenValidInfixThenClosingBracket_doesntThrow),
        ("test_whenValidInfixContainingFailingOperation_doesntThrow", test_whenValidInfixContainingFailingOperation_doesntThrow),
        ("test_whenComplexValidInfix_doesntThrow", test_whenComplexValidInfix_doesntThrow),
        ("test_whenNoBrackets_placesProperlyOperatorsWithDifferentPrecedence", test_whenNoBrackets_placesProperlyOperatorsWithDifferentPrecedence),
        ("test_whenBracketed_placesProperlyOperatorsWithDifferentPrecedence", test_whenBracketed_placesProperlyOperatorsWithDifferentPrecedence),
        
    ]
}
