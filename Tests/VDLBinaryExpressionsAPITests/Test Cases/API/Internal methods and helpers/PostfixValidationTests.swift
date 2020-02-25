//
//  VDLBinaryExpressionsAPITests
//  PostfixValidationTests.swift
//
//
//  Created by Valeriano Della Longa on 18/02/2020.
//  Copyright (c) 2020 Valeriano Della Longa
//

import XCTest
@testable import VDLBinaryExpressionsAPI

final class PostfixValidationTests: XCTestCase {
    var sut: AnyCollection<Token>!
    
    var expectedResult: Bool!
    
    // MARK: - Test lifecycle
    override func setUp() {
        super.setUp()
        
        sut = AnyCollection([])
        expectedResult = true
    }
    
    override func tearDown() {
        sut = nil
        expectedResult = nil
        
        super.tearDown()
    }
    
    // MARK: - Given
    func givenExpressionsMakingPostfixEvaluationByMappingThrowNotValidError()
        -> [AnyCollection<Token>]
    {
        var cases = [AnyCollection<Token>]()
        
        let basicAddition = Array(MockBinaryOperator.givenSimpleAdditionExpression().expression)
        
        cases.append(AnyCollection([.operand(10), .binaryOperator(.add)]))
        cases.append(AnyCollection(basicAddition + [.closingBracket]))
        cases.append(AnyCollection([.openingBracket] + basicAddition))
        cases.append(AnyCollection([.operand(20), .operand(10), .operand(30), .binaryOperator(.add)]))
        
        return cases
    }
    
    func givenNotEmptyValidPostfixBaseExpressions() -> [AnyCollection<Token>]
    {
        
        return MockBinaryOperator.givenSimpleBinaryOperationExpressions(postfix: true)
            .map({ $0.expression })
    }
    
    func givenValidExpressionsContainigThrowingOperatorWhenApplied()
        -> [AnyCollection<Token>]
    {
        var expressions = [AnyCollection<Token>]()
        
        expressions
            .append(MockBinaryOperator.givenFailingSimpleDivisionExpression(postfix: true).expression)
        expressions
            .append(MockBinaryOperator.givenFailingSimpleDivisionExpression(postfix: true).expression)
        
        return expressions
    }
    
    func givenExpectedResult() {
        expectedResult = (try? sut
            .postfixEvaluationByMapping(
                onOperandTransform: MockDummyOperand.mapOperand(_:),
                onOperatorTransform: MockDummyOperand.mapOperator(_:)
        )) != nil
    }
    
    // MARK: - When
    func whenPostfixEvaluationByMappingThrowsNotValidError_cases()
        -> [() -> Void]
    {
        return givenExpressionsMakingPostfixEvaluationByMappingThrowNotValidError()
            .map { expression in
                return {
                    self.sut = expression
                    self.givenExpectedResult()
                }
        }
    }
    
    func whenPostfixEvaluationByMappingReturnsValue_cases() -> [() -> Void] {
        return givenNotEmptyValidPostfixBaseExpressions()
            .map { expression in
                return {
                    self.sut = expression
                    self.givenExpectedResult()
                }
        }
    }
    
    // MARK: - Then
    // MARK: - Tests
    func test_whenEmpty_returnsTrue() {
        XCTAssertTrue(sut.isValidPostfixNotation())
    }
    
    func test_whenPostfixEvaluationByMappingThrowsNotValidError_returnsFalse()
    {
        for when in whenPostfixEvaluationByMappingThrowsNotValidError_cases() {
            // when
            when()
            
            // then
            XCTAssertFalse(sut.isValidPostfixNotation())
        }
    }
    
    func test_whenValidExpressionContainsOperatorFailingWhenApplied_returnsTrue() {
        // given
        for given in givenValidExpressionsContainigThrowingOperatorWhenApplied()
        {
            // when
            sut =  given
            givenExpectedResult()
            
            // then
            XCTAssertTrue(sut.isValidPostfixNotation())
        }
    }
    
    func test_whenPostfixEvaluationByMappingReturnsValue_returnsTrue()
    {
        for when in whenPostfixEvaluationByMappingReturnsValue_cases()
        {
            // when
            when()
            
            // then
            XCTAssertTrue(sut.isValidPostfixNotation())
        }
    }
    
    static var allTests = [
        ("test_whenEmpty_returnsTrue", test_whenEmpty_returnsTrue),
        ("test_whenPostfixEvaluationByMappingThrowsNotValidError_returnsFalse", test_whenPostfixEvaluationByMappingThrowsNotValidError_returnsFalse),
       ("test_whenValidExpressionContainsOperatorFailingWhenApplied_returnsTrue", test_whenValidExpressionContainsOperatorFailingWhenApplied_returnsTrue),
       ("test_whenPostfixEvaluationByMappingReturnsValue_returnsTrue", test_whenPostfixEvaluationByMappingReturnsValue_returnsTrue),
        
    ]
}
