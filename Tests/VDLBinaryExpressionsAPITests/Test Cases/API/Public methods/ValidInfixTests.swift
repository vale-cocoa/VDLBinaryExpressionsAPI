//
//  VDLBinaryExpressionsAPITests
//  ValidInfixTests.swift
//  
//
//  Created by Valeriano Della Longa on 18/02/2020.
//  Copyright (c) 2020 Valeriano Della Longa
//

import XCTest
@testable import VDLBinaryExpressionsAPI

final class ValidInfixTests: XCTestCase {
    // MARK: - Properties
    var sut: AnyCollection<Token>!
    
    var expectedResult: [Token]?!
    
    // MARK: - Test lifecycle
    override func setUp() {
        super.setUp()
        
        sut = AnyCollection([])
        expectedResult = []
    }
    
    override func tearDown() {
        sut = nil
        expectedResult = nil
        
        super.tearDown()
    }
    
    // MARK: - Given
    
    // MARK: - When
    func whenInfixConverterDoesntThrow_cases() -> [() -> Void]
    {
        return whenValidPostfix_cases() + whenValidInfix_cases().dropFirst(2)
    }
    
    func whenValidPostfix_cases() -> [() -> Void] {
        var cases = [() -> Void]()
        
        for given in MockBinaryOperator.givenSimpleBinaryOperationExpressions()
        {
            cases.append {
                self.sut = given.expression
                self.expectedResult = try?  given.expression.convertToInfixNotation()
            }
        }
        
        return cases
    }
    
    func whenValidInfix_cases() -> [() -> Void] {
        var cases = [() -> Void]()
        for given in MockBinaryOperator.givenSimpleBinaryOperationExpressions(postfix: false) {
            cases.append {
                self.sut = given.expression
                self.expectedResult = Array(given.expression)
            }
        }
        
        return cases
    }
    
    // MARK: - Then
    func thenResultIsExpectedResult() {
        let result = sut.validInfix()
        switch (result, expectedResult) {
        case (_, .some(let expected)):
            XCTAssertEqual(result, expected)
        default:
            fatalError("Forgotten to set the expected result for this test")
        }
    }
    
    // MARK: - Tests
    func test_whenInfixConverterThrows_retursnNil() {
        // when
        sut = AnyCollection([.openingBracket, .operand(10), .operand(20), .binaryOperator(.add), .binaryOperator(.multiply), .closingBracket])
        
        // then
        XCTAssertThrowsError(try sut.convertToInfixNotation())
        XCTAssertNil(sut.validInfix())
    }
    
    func test_whenInfixConvertDoesntThrow_doesntReturnNil() {
        for when in whenInfixConverterDoesntThrow_cases() {
            // when
            when()
            
            // then
            XCTAssertNoThrow(try sut.convertToInfixNotation())
            XCTAssertNotNil(sut.validInfix())
        }
    }
    
    func test_whenInfixConverterDoesntThrow_returnsExpectedResult() {
        for when in whenInfixConverterDoesntThrow_cases() {
            // when
            when()
            
            // then
            thenResultIsExpectedResult()
        }
    }
    
    static var allTests = [
        ("test_whenInfixConverterThrows_retursnNil", test_whenInfixConverterThrows_retursnNil),
        ("test_whenInfixConvertDoesntThrow_doesntReturnNil", test_whenInfixConvertDoesntThrow_doesntReturnNil),
        ("test_whenInfixConverterDoesntThrow_returnsExpectedResult", test_whenInfixConverterDoesntThrow_returnsExpectedResult),
        
    ]
}
