//
//  VDLBinaryExpressionsAPITests
//  ValidPostfixTests.swift
//  
//
//  Created by Valeriano Della Longa on 18/02/2020.
//  Copyright (c) 2020 Valeriano Della Longa
//

import XCTest
@testable import VDLBinaryExpressionsAPI

final class ValidPostfixTests: XCTestCase
{
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
    func whenValidPostfix_cases() -> [() -> Void] {
        var cases = [() -> Void]()
        
        for given in MockBinaryOperator.givenSimpleBinaryOperationExpressions()
        {
            cases.append {
                self.sut = given.expression
                self.expectedResult = Array(given.expression)
            }
        }
        
        return cases
    }
    
    func whenValidInfix_cases() -> [() -> Void] {
        var cases = [() -> Void]()
        
        for given in MockBinaryOperator.givenSimpleBinaryOperationExpressions(postfix: false) {
            cases.append {
                self.sut = given.expression
                self.expectedResult = try? given.expression.convertToPostfixNotation()
            }
        }
        
        return cases
    }
    
    // MARK: - Then
    func thenResultIsExpectedResult() {
        let result = sut.validPostfix()
        switch (result, expectedResult) {
        case (_, .some(let expected)):
            XCTAssertEqual(result, expected)
        default:
            fatalError("Forgotten to set the expected result for this test")
        }
    }
    
    // MARK: - Tests
    func test_whenValid_doesntReturnsNil() {
        for when in (whenValidPostfix_cases() + whenValidPostfix_cases().dropFirst(2)) {
            // when
            when()
            XCTAssertNotNil(sut.validPostfix())
        }
    }
    
    func test_whenValidPostfix_returnsExpressionAsArray() {
        for when in whenValidPostfix_cases() {
            // when
            when()
            
            // then
            thenResultIsExpectedResult()
        }
    }
    
    func test_whenValidInfix_returnsPostfixConversion() {
        for when in whenValidInfix_cases() {
            // when
            when()
            
            // then
            thenResultIsExpectedResult()
        }
    }
    
    func test_whenNotValidInEitherNotations_returnsNil() {
        // when
        sut = AnyCollection([.openingBracket, .operand(10), .operand(20), .binaryOperator(.add), .binaryOperator(.multiply), .closingBracket])
        
        // then
        XCTAssertNil(sut.validPostfix())
    }
    
    static var allTests = [
        ("test_whenValid_doesntReturnsNil", test_whenValid_doesntReturnsNil),
        ("test_whenValidPostfix_returnsExpressionAsArray", test_whenValidPostfix_returnsExpressionAsArray),
    ("test_whenValidInfix_returnsPostfixConversion", test_whenValidInfix_returnsPostfixConversion),
    ("test_whenNotValidInEitherNotations_returnsNil", test_whenNotValidInEitherNotations_returnsNil),
    
    ]
}
