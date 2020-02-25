//
//  VDLBinaryExpressionsAPITests
//  InfixConversionTests.swift
//
//
//  Created by Valeriano Della Longa on 16/02/2020.
//  Copyright (c) 2020 Valeriano Della Longa
//

import XCTest
@testable import VDLBinaryExpressionsAPI

final class InfixConversionTests: XCTestCase {
    var sut: AnyCollection<DummyToken>!
    
    var expectedResult: Result<[DummyToken], Error>!
    
    // MARK: - Test lifecycle
    override func setUp() {
        super.setUp()
        
        sut = AnyCollection([])
        expectedResult = .success([])
    }
    
    override func tearDown() {
        sut = nil
        expectedResult = nil
        
        super.tearDown()
    }
    
    // MARK: - Given
    func givenValidBasicExpressions() -> [DummyTokenValidExpression]
    {
        let randomInt = MockBinaryOperator.givenRandomInt()
        return MockDummyOperator
            .givenValidSimpleExpressionsOfTwoOperands() +
            [([.operand(randomInt)], [.operand(randomInt)])]
    }
    
    // MARK: - When
    func whenConvertToPostfixNotationThrows_cases() -> [() -> Void]
    {
        let postfixConversionTests = PostfixConversionTests()
        let expressions = postfixConversionTests.givenBaseExpressionsMakingValidateInfixChunkThrow() + postfixConversionTests.givenInfixExpressionsWhereBracketingIsNotBalanced()
        
        return expressions.map { notValidExpression in
            return {
                self.sut = notValidExpression
                self.expectedResult = .failure(BinaryExpressionError.notValid)
            }
        }
    }
    
    func whenIsValidBasicPostfixExpression_cases() -> [() -> Void]
    {
        return givenValidBasicExpressions()
            .map { expression in
                return {
                    self.sut = AnyCollection(expression.postfix)
                    self.expectedResult = .success(expression.infix)
                }
        }
    }
    
    func whenIsValidBasicInfixExpression_cases() -> [() -> Void]
    {
        return givenValidBasicExpressions()
            .map { expression in
                return {
                    self.sut = AnyCollection(expression.infix)
                    self.expectedResult = .success(expression.infix)
                }
        }
    }
    
    func whenIsValidBasicInfixExpressionBracketed_cases() -> [() -> Void]
    {
        let basicInfixExpressions = givenValidBasicExpressions()
            .map { $0.infix }
        let bracketed = basicInfixExpressions
            .map { [.openingBracket] + $0 + [.closingBracket] }
        
        let zipped = zip(bracketed, basicInfixExpressions)
        
        return zipped
            .map { bracketdAndOriginal in
                return {
                    self.sut = AnyCollection(bracketdAndOriginal.0)
                    self.expectedResult = .success(bracketdAndOriginal.1)
                }
        }
    }
    
    // MARK: Then
    func thenResultIsExpcted() {
        let result: Result<[DummyToken], Error>!
        do {
            let infix = try sut.convertToInfixNotation()
            result = .success(infix)
        } catch {
            result = .failure(error)
        }
        switch (result, expectedResult)
        {
        case (.success(let infixResult), .success(let expectedInfix)):
            XCTAssertEqual(infixResult, expectedInfix)
        case (.failure(let resultError as NSError), .failure(let expectedError as NSError)):
            XCTAssertEqual(resultError.domain, expectedError.domain)
            XCTAssertEqual(resultError.code, expectedError.code)
        default: XCTFail("result: \(String(describing: result)) – expectedResult: \(String(describing: expectedResult))")
        }
        
    }
    
    // MARK: Tests
    func test_whenConvertToPostfixNotationThrows_throws()
    {
        for when in whenConvertToPostfixNotationThrows_cases()
        {
            // when
            when()
            
            // then
            XCTAssertThrowsError(try sut.convertToInfixNotation())
        }
    }
    
    func test_whenThrows_errorThrownIsTheExpectedOne()
    {
        for when in whenConvertToPostfixNotationThrows_cases()
        {
            // when
            when()
            
            // then
            thenResultIsExpcted()
        }
    }
    
    func test_whenIsValidBasicPostfixExpression_doesntThrow()
    {
        for when in whenIsValidBasicPostfixExpression_cases() {
            // when
            when()
            
            // then
            XCTAssertNoThrow(try sut.convertToInfixNotation())
        }
    }
    
    func test_whenIsValidBasicPostfixExpression_returnsExpectedValue() {
        for when in whenIsValidBasicPostfixExpression_cases()
        {
            // when
            when()
            
            // then
            thenResultIsExpcted()
        }
    }
    
    func test_whenIsValidBasicInfixExpression_doesntThrow()
    {
        for when in whenIsValidBasicInfixExpression_cases()
        {
            // when
            when()
            
            // then
            XCTAssertNoThrow(try sut.convertToInfixNotation())
        }
    }
    
    func test_whenIsValidBasicInfixExpression_returnsExpectedValue()
    {
        for when in whenIsValidBasicInfixExpression_cases()
        {
            // when
            when()
            
            // then
            thenResultIsExpcted()
        }
    }
    
    func test_whenIsValidBasicInfixExpressionBracketed_removesBrackets()
    {
        for when in whenIsValidBasicInfixExpressionBracketed_cases()
        {
            // when
            when()
            
            // then
            thenResultIsExpcted()
        }
    }
    
    func test_whenIsEmpty_returnsEmpty() {
        // then
        thenResultIsExpcted()
    }
    
    func test_bracketing() {
        // given
        let expressions = MockDummyOperator.givenForBracketTesting()
        for expression in expressions {
            // when
            sut = AnyCollection(expression.postfix)
            expectedResult = .success(expression.infix)
            
            // then
            thenResultIsExpcted()
        }
    }
    
    static var allTests = [
        ("test_whenConvertToPostfixNotationThrows_throws", test_whenConvertToPostfixNotationThrows_throws),
        ("test_whenThrows_errorThrownIsTheExpectedOne", test_whenThrows_errorThrownIsTheExpectedOne),
        ("test_whenIsValidBasicPostfixExpression_doesntThrow", test_whenIsValidBasicPostfixExpression_doesntThrow),
        ("test_whenIsValidBasicPostfixExpression_returnsExpectedValue", test_whenIsValidBasicPostfixExpression_returnsExpectedValue),
        ("test_whenIsValidBasicInfixExpression_doesntThrow", test_whenIsValidBasicInfixExpression_doesntThrow),
        ("test_whenIsValidBasicInfixExpression_returnsExpectedValue", test_whenIsValidBasicInfixExpression_returnsExpectedValue),
        ("test_whenIsValidBasicInfixExpressionBracketed_removesBrackets", test_whenIsValidBasicInfixExpressionBracketed_removesBrackets),
        ("test_whenIsEmpty_returnsEmpty", test_whenIsEmpty_returnsEmpty),
        
    ]
}
