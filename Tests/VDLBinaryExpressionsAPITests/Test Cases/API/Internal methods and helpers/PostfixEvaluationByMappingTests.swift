//
//  VDLBinaryExpressionsAPITests
//  PostfixEvaluationByMappingTests.swift
//
//
//  Created by Valeriano Della Longa on 16/02/2020.
//  Copyright (c) 2020 Valeriano Della Longa
//

import XCTest
@testable import VDLBinaryExpressionsAPI

final class PostfixEvaluationByMappingTests: XCTestCase {
    struct _Sut {
        var expression: AnyCollection<Token> = AnyCollection([])
        var onOperandTransform: ( (MockBinaryOperator.Operand) throws -> MockDummyOperand ) = MockDummyOperand.mapOperand(_:)
        var onOperatorTransform = MockDummyOperand.mapOperator(_:)
    }
    
    var sut: _Sut!
    
    var expectedResult: Result<MockDummyOperand, Error>!
    
    // MARK: - Test lifecycle
    override func setUp() {
        super.setUp()
        
        sut = _Sut()
        expectedResult = .failure(BinaryExpressionError.notValid)
    }
    
    // MARK: - Given
    
    // MARK: - When
    func whenOnOperandTransformThrows() {
        // when
        sut.expression = MockBinaryOperator.givenSimpleAdditionExpression().expression
        sut.onOperandTransform = MockDummyOperand.mapOperandFail(_:)
        expectedResult = .failure(MockDummyOperand.Error.mapOperandFailed)
    }
    
    func whenOperatorTokenFoundAndNotTwoOperandsInStack() {
        sut.expression = AnyCollection([.operand(10), .binaryOperator(.add)])
        expectedResult = .failure(BinaryExpressionError.notValid)
    }
    
    func whenOnOperatorTransformThrows() {
        sut.expression = MockBinaryOperator.givenSimpleAdditionExpression().expression
        sut.onOperatorTransform = MockDummyOperand.mapOperatorFail(_:)
        expectedResult = .failure(MockDummyOperand.Error.mapOperatorFailed)
    }
    
    func whenApplyingMappedOperationThrows() {
        sut.expression = MockBinaryOperator.givenSimpleAdditionExpression().expression
        sut.onOperatorTransform = MockDummyOperand.mapOperatorToFailingOperation(_:)
        expectedResult = .failure(MockDummyOperand.Error.mappedOperationFail)
    }
    
    func whenDoesntContainsOnlyOperandAndOperatorTokens_cases()
        -> [() -> Void]
    {
        var cases = [() -> Void]()
        let basicAddition = Array(MockBinaryOperator.givenSimpleAdditionExpression().expression)
        cases.append {
            self.sut.expression = AnyCollection(basicAddition + [.closingBracket])
            self.expectedResult = .failure(BinaryExpressionError.notValid)
        }
        
        cases.append {
            self.sut.expression = AnyCollection([.openingBracket] + basicAddition)
            self.expectedResult = .failure(BinaryExpressionError.notValid)
        }
        
        return cases
    }
    
    func whenMoreThanOneOperandInStackAtLast() {
        sut.expression = AnyCollection([.operand(20), .operand(10), .operand(30), .binaryOperator(.add)])
        expectedResult = .failure(BinaryExpressionError.notValid)
    }
    
    // MARK: - Then
    func thenThrows() {
        // then
        XCTAssertThrowsError(try sut.expression
            .postfixEvaluationByMapping(
                onOperandTransform: sut.onOperandTransform,
                onOperatorTransform: sut.onOperatorTransform
            )
        )
    }
    
    func thenResultIsExpected() {
        let result: Result<MockDummyOperand, Error>!
        do
        {
            let evaluation = try sut.expression.postfixEvaluationByMapping(
                onOperandTransform: sut.onOperandTransform,
                onOperatorTransform: sut.onOperatorTransform)
            result = .success(evaluation)
        } catch {
            result = .failure(error)
        }
        
        switch (result, expectedResult) {
        case (.success(let evaluated), .success(let expected)):
            XCTAssertEqual(evaluated, expected)
        case (.failure(let resultError as NSError), .failure(let expectedError as NSError)):
            XCTAssertEqual(resultError.domain, expectedError.domain)
            XCTAssertEqual(resultError.code, expectedError.code)
        default:
            XCTFail("result: \(String(describing: result)) — expectedResult: \(String(describing: expectedResult))")
        }
    }
    
    // Helpers
    func thenResultsIsExpected<T>
        (result: Result<T, Error>, expectedResult: Result<T, Error>)
        where T: Equatable
    {
        switch (result, expectedResult) {
            case (.success(let evaluated), .success(let expected)):
                XCTAssertEqual(evaluated, expected)
            case (.failure(let resultError as NSError), .failure(let expectedError as NSError)):
                XCTAssertEqual(resultError.domain, expectedError.domain)
                XCTAssertEqual(resultError.code, expectedError.code)
            default:
                XCTFail("result: \(String(describing: result)) — expectedResult: \(String(describing: expectedResult))")
        }
    }
    
    // MARK: - Tests
    func test_whenEmpty_throws() {
        // then
        thenThrows()
    }
    
    func test_whenEmpty_throwsNotValidError() {
        // then
        thenResultIsExpected()
    }
    
    func test_whenOnOperandTransformThrows_throws() {
        // given
        // when
        whenOnOperandTransformThrows()
        
        // then
        thenThrows()
    }
    
    func test_whenOnOperandTransformThrows_throwsExpectedError()
    {
        // given
        // when
        whenOnOperandTransformThrows()
        
        // then
        thenResultIsExpected()
    }
    
    func test_whenOperatorTokenFoundAndNotTwoOperandsInStack_throws()
    {
        // given
        // when
        whenOperatorTokenFoundAndNotTwoOperandsInStack()
        
        // then
        thenThrows()
    }
    
    func test_whenOperatorTokenFoundAndNotTwoOperandsInStack_throwsExpectedError() {
        // given
        // when
        whenOperatorTokenFoundAndNotTwoOperandsInStack()
        
        thenResultIsExpected()
    }
    
    func test_whenOnOperatorTransformThrows_throws() {
        // when
        whenOnOperatorTransformThrows()
        
        // then
        thenThrows()
    }
    
    func test_whenOnOperatorTransformThrows_throwsExpectedError() {
        // when
        whenOnOperatorTransformThrows()
        
        // then
        thenResultIsExpected()
    }
    
    func test_whenApplyingMappedOperationThrows_throws() {
        // when
        whenApplyingMappedOperationThrows()
        
        // then
        thenThrows()
    }
    
    func test_whenApplyingMappedOperationThrows_throwsExpectedError()
    {
        // when
        whenApplyingMappedOperationThrows()
        
        // then
        thenResultIsExpected()
    }
    
    func test_whenDoesntContainsOnlyOperandAndOperatorTokens_throws()
    {
        for when in whenDoesntContainsOnlyOperandAndOperatorTokens_cases() {
            // when
            when()
            
            // then
            thenThrows()
        }
    }
    
    func test_whenDoesntContainsOnlyOperandAndOperatorTokens_throwsExpectedError()
    {
        for when in whenDoesntContainsOnlyOperandAndOperatorTokens_cases() {
            // when
            when()
            
            // then
            thenResultIsExpected()
        }
    }
    
    func test_whenMoreThanOneOperandInStackAtLast_throws() {
        // when
        whenMoreThanOneOperandInStackAtLast()
        
        // then
        thenThrows()
    }
    
    func test_whenMoreThanOneOperandInStackAtLast_throwsExpectedError() {
        // when
        whenMoreThanOneOperandInStackAtLast()
        
        // then
        thenResultIsExpected()
    }
    
    func test_whenMappingToOriginalOperandAndOperatorAndExpressionIsValidPostfix_returnedValueOrThrownErrorIsExpected()
    {
        // given
        for given in MockBinaryOperator.givenSimpleBinaryOperationExpressions(postfix: true)
            .dropFirst()
        {
            // when
            let result: Result<MockBinaryOperator.Operand, Error>!
            do {
                let evaluated = try given.expression
                    .postfixEvaluationByMapping(
                        onOperandTransform: { $0 },
                        onOperatorTransform: { $0.binaryOperation }
                )
                result = .success(evaluated)
            } catch {
                result = .failure(error)
            }
            
            // then
            thenResultsIsExpected(result: result, expectedResult: given.value)
        }
    }
    
    var allTests = [
        ("test_whenEmpty_throws", test_whenEmpty_throws),
        ("test_whenEmpty_throwsNotValidError", test_whenEmpty_throwsNotValidError),
        ("test_whenOnOperandTransformThrows_throws", test_whenOnOperandTransformThrows_throws),
        ("test_whenOnOperandTransformThrows_throwsExpectedError", test_whenOnOperandTransformThrows_throwsExpectedError),
        ("test_whenOperatorTokenFoundAndNotTwoOperandsInStack_throws", test_whenOperatorTokenFoundAndNotTwoOperandsInStack_throws),
        ("test_whenOperatorTokenFoundAndNotTwoOperandsInStack_throwsExpectedError", test_whenOperatorTokenFoundAndNotTwoOperandsInStack_throwsExpectedError),
        ("test_whenOnOperatorTransformThrows_throws", test_whenOnOperatorTransformThrows_throws),
        ("test_whenOnOperatorTransformThrows_throwsExpectedError", test_whenOnOperatorTransformThrows_throwsExpectedError),
        ("test_whenApplyingMappedOperationThrows_throws",  test_whenApplyingMappedOperationThrows_throws),
        ("test_whenApplyingMappedOperationThrows_throwsExpectedError", test_whenApplyingMappedOperationThrows_throwsExpectedError),
        ("test_whenDoesntContainsOnlyOperandAndOperatorTokens_throws", test_whenDoesntContainsOnlyOperandAndOperatorTokens_throws),
        ("test_whenDoesntContainsOnlyOperandAndOperatorTokens_throwsExpectedError", test_whenDoesntContainsOnlyOperandAndOperatorTokens_throwsExpectedError),
        ("test_whenMoreThanOneOperandInStackAtLast_throws", test_whenMoreThanOneOperandInStackAtLast_throws),
        ("test_whenMoreThanOneOperandInStackAtLast_throwsExpectedError", test_whenMoreThanOneOperandInStackAtLast_throwsExpectedError),
        ("test_whenMappingToOriginalOperandAndOperatorAndExpressionIsValidPostfix_returnedValueOrThrownErrorIsExpected", test_whenMappingToOriginalOperandAndOperatorAndExpressionIsValidPostfix_returnedValueOrThrownErrorIsExpected),
        
    ]
    
}
