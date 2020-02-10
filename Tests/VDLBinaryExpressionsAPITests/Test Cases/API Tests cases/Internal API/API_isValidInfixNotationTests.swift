//
//  VDLBinaryExpressionsAPI
//  API_isValidInfixNotationTests.swift
//
//
//  Created by Valeriano Della Longa on 06/02/2020.
//  Copyright (c) 2020 Valeriano Della Longa
//

import XCTest
@testable import VDLBinaryExpressionsAPI

final class API_isValidInfixNotationTests: XCTestCase {
    typealias Token = BinaryOperatorExpressionToken<MockBinaryOperator>
    
    // MARK: - Properties
    var sut: [Token]!
    var _convertToRPNDidThrow: Bool!
    
    // MARK: - Test lifecycle
    override func setUp() {
        super.setUp()
        
    }
    
    override func tearDown() {
        self.sut = nil
        self._convertToRPNDidThrow = nil
        
        super.tearDown()
    }
    
    // MARK: - Given
    func givenEmptyExpression() {
        sut = []
    }
    
    func givenValidInfixExpression() {
        sut = [.openingBracket, .operand(10), .binaryOperator(.add), .operand(20), .closingBracket, .binaryOperator(.multiply), .openingBracket, .operand(30), .binaryOperator(.add), .operand(40), .closingBracket]
    }
    
    func givenNotValidInfixExpression() {
        sut = [.openingBracket, .operand(10), .binaryOperator(.add), .operand(20), .closingBracket, .operand(30)]
    }
    
    // MARK: - When
    func whenConvertToRPNDidntThrow() {
        givenValidInfixExpression()
        set_convertToRPNDidThrow()
    }
    
    func whenConvertToRPNDidThrow() {
        givenNotValidInfixExpression()
        set_convertToRPNDidThrow()
    }
    
    func set_convertToRPNDidThrow() {
        do {
            let _ = try _convertToRPN(infixExpression: sut)
            _convertToRPNDidThrow = false
        } catch {
            _convertToRPNDidThrow = true
        }
    }
    
    // MARK: - Tests
    func test_givenEmpty_returnsTrue() {
        // given
        givenEmptyExpression()
        
        // when
        // then
        XCTAssertTrue(_isValidInfixNotation(expression: sut))
    }
    
    func test_whenConvertToRPNDoesntThrow_returnsTrue() {
        //when
        whenConvertToRPNDidntThrow()
        
        // then
        XCTAssertTrue(_isValidInfixNotation(expression: sut))
    }
    
    func test_whenConvertToRPNThrows_returnsFalse() {
        // when
        whenConvertToRPNDidThrow()
        
        // then
        XCTAssertFalse(_isValidInfixNotation(expression: sut))
    }
    
    static var allTests = [
        ("test_givenEmpty_returnsTrue", test_givenEmpty_returnsTrue),
        ("test_whenConvertToRPNDoesntThrow_returnsTrue", test_whenConvertToRPNDoesntThrow_returnsTrue),
        ("test_whenConvertToRPNThrows_returnsFalse", test_whenConvertToRPNThrows_returnsFalse)
    ]
    
}
