//
//  VDLBinaryExpressionsAPI
//  API_validInfixTests.swift
//  
//
//  Created by Valeriano Della Longa on 10/02/2020.
//  Copyright (c) 2020 Valeriano Della Longa
//

import XCTest
@testable import VDLBinaryExpressionsAPI

final class API_validInfixTests: XCTestCase {
    typealias Token = BinaryOperatorExpressionToken<MockBinaryOperator>
    
    // MARK: - Properties
    var sut: AnyCollection<Token>!
    
    var isValidInfixNotation: Bool { return _isValidInfixNotation(expression: sut)}
    
    var convertToInfixDidThrow: Bool!
    
    var expectedResult: [Token]!
    
    // MARK: - Test lifecycle
    override func setUp() {
        super.setUp()
        
    }
    
    override func tearDown() {
        self.sut = nil
        self.convertToInfixDidThrow = nil
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
    func whenIsValidInfixNotationReturnsTrue() {
        givenValidExpressionInInfixNotation()
    }
    
    func whenConvertToInfixThrows() {
        givenExpressionNotValidInBothNotations()
        convertSUT()
    }
    
    func _whenConvertToInfixDoesntThrow() {
        givenValidExpressionInPostfixNotation()
        convertSUT()
    }
    
    func convertSUT() {
        do {
            expectedResult = try _convertFromRPNToInfix(expression: sut)
            convertToInfixDidThrow = false
        } catch {
            expectedResult = nil
            convertToInfixDidThrow = true
        }
    }
    
    // MARK: - Tests
    func test_whenIsValidInfixNotationReturnsTrue_returnsValue() {
        // when
        whenIsValidInfixNotationReturnsTrue()
        
        // then
        XCTAssertTrue(isValidInfixNotation)
        XCTAssertNotNil(sut.validInfix())
    }
    
    func test_whenIsValidInfixNotationReturnsTrue_returnedValueIsArrayOfExpression() {
        // when
        whenIsValidInfixNotationReturnsTrue()
        
        // then
        XCTAssertEqual(sut.validInfix(), Array(sut))
    }
    
    func test_whenConvertToInfixThrows_returnsNil() {
        // when
        whenConvertToInfixThrows()
        
        // then
        XCTAssertNil(sut.validInfix())
    }
    
    func test_whenConvertToInfixDoesntThrow_returnsValue() {
        // when
        _whenConvertToInfixDoesntThrow()
        
        // then
        XCTAssertNotNil(sut.validInfix())
    }
    
    func test_whenConvertToInfixDoesntThrow_returnsValidInfix() {
        // when
        _whenConvertToInfixDoesntThrow()
        
        // then
        XCTAssertTrue(_isValidInfixNotation(expression: sut.validInfix()!))
    }
    
    var allTests = [
        ("test_whenIsValidInfixNotationReturnsTrue_returnsValue", test_whenIsValidInfixNotationReturnsTrue_returnsValue),
        ("test_whenIsValidInfixNotationReturnsTrue_returnedValueIsArrayOfExpression", test_whenIsValidInfixNotationReturnsTrue_returnedValueIsArrayOfExpression),
        ("test_whenConvertToInfixThrows_returnsNil", test_whenConvertToInfixThrows_returnsNil),
        ("test_whenConvertToInfixDoesntThrow_returnsValue", test_whenConvertToInfixDoesntThrow_returnsValue),
        ("test_whenConvertToInfixDoesntThrow_returnsValidInfix", test_whenConvertToInfixDoesntThrow_returnsValidInfix),
        
    ]
}
