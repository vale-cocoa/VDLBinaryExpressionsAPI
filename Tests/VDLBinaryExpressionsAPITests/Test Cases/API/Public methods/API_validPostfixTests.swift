//
//  VDLBinaryExpressionsAPI
//  API_validPostfixTests.swift
//
//
//  Created by Valeriano Della Longa on 10/02/2020.
//  Copyright (c) 2020 Valeriano Della Longa
//

import XCTest
@testable import VDLBinaryExpressionsAPI

final class API_validPostfixTests: XCTestCase {
    typealias Token = BinaryOperatorExpressionToken<MockBinaryOperator>
    
    // MARK: - Properties
    var sut: AnyCollection<Token>!
    
    var isValidPostfixNotation: Bool { return _isValidPostfixNotation(expression: sut)}
    
    var convertToRPNDidThrow: Bool!
    
    var expectedResult: [Token]!
    
    // MARK: - Test lifecycle
    override func setUp() {
        super.setUp()
        
    }
    
    override func tearDown() {
        self.sut = nil
        self.convertToRPNDidThrow = nil
        self.expectedResult = nil
        
        super.tearDown()
    }
    
    // MARK: - Given
    func givenValidExpressionInPostfixNotation() {
        sut = AnyCollection([.operand(10), .operand(20), .binaryOperator(.add)])
    }
    
    func givenValidExpressionInInfixNotation() {
        sut = AnyCollection([.operand(10), .binaryOperator(.add), .operand(20)])
    }
    
    func givenExpressionNotValidInBothNotations() {
        sut = AnyCollection([.operand(20), .operand(30), .binaryOperator(.add), .binaryOperator(.multiply)])
    }
    
    // MARK: - When
    func whenIsValidPostfixNotationReturnsTrue() {
        givenValidExpressionInPostfixNotation()
    }
    
    func whenConvertToRPNDidThrow() {
        givenExpressionNotValidInBothNotations()
        convertSUT()
    }
    
    func _whenConvertToRPNDidntThrow() {
        givenValidExpressionInInfixNotation()
        convertSUT()
    }
    
    func convertSUT() {
        do {
            expectedResult = try _convertToRPN(infixExpression: sut)
            convertToRPNDidThrow = false
        } catch {
            expectedResult = nil
            convertToRPNDidThrow = true
        }
    }
    
    // MARK: - Tests
    func test_whenIsValidPostfixNotationReturnsTrue_returnsValue() {
        // when
        whenIsValidPostfixNotationReturnsTrue()
        
        // then
        XCTAssertTrue(isValidPostfixNotation)
        XCTAssertNotNil(sut.validPostfix())
    }
    
    func test_whenIsValidPostfixNotationReturnsTrue_returnedValueIsArrayOfExpression() {
        // when
        whenIsValidPostfixNotationReturnsTrue()
        
        // then
        XCTAssertEqual(sut.validPostfix(), Array(sut))
    }
    
    func test_whenConvertToRPNDidThrow_returnsNil() {
        // when
        whenConvertToRPNDidThrow()
        
        // then
        XCTAssertNil(sut.validPostfix())
    }
    
    func test_whenConvertToRPNDidntThrow_returnsValue() {
        // when
        _whenConvertToRPNDidntThrow()
        
        // then
        XCTAssertNotNil(sut.validPostfix())
    }
    
    func test_whenConvertToRPNDidntThrow_returnsValidPostfix() {
        // when
        _whenConvertToRPNDidntThrow()
        
        // then
        XCTAssertTrue(_isValidPostfixNotation(expression: sut.validPostfix()!))
    }
    
    var allTests = [
        ("test_whenIsValidPostfixNotationReturnsTrue_returnsValue", test_whenIsValidPostfixNotationReturnsTrue_returnsValue),
        ("test_whenIsValidPostfixNotationReturnsTrue_returnedValueIsArrayOfExpression", test_whenIsValidPostfixNotationReturnsTrue_returnedValueIsArrayOfExpression),
        ("test_whenConvertToRPNDidThrow_returnsNil", test_whenConvertToRPNDidThrow_returnsNil),
        ("test_whenConvertToRPNDidntThrow_returnsValue", test_whenConvertToRPNDidntThrow_returnsValue),
        ("test_whenConvertToRPNDidntThrow_returnsValidPostfix", test_whenConvertToRPNDidntThrow_returnsValidPostfix),
        
    ]
}
