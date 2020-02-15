//
//  VDLBinaryExpressionsAPI
//  API_evalTests.swift
//  
//
//  Created by Valeriano Della Longa on 06/02/2020.
//  Copyright (c) 2020 Valeriano Della Longa
//

import XCTest
@testable import VDLBinaryExpressionsAPI

final class API_evalTests: XCTestCase {
    typealias Token = BinaryOperatorExpressionToken<MockBinaryOperator>
    struct _Sut {
        var expressionToEvaluate: [Token] = []
        var evalShouldThrowOnFailingOperation: Bool = false
    }
    
    // MARK: - Properties
    var sut: _Sut!
    var expectedResult: Result<MockBinaryOperator.Operand?, Error>!
    
    // MARK: - Test lifecycle
    override func setUp() {
        super.setUp()
        
        sut = _Sut()
        expectedResult = .success(nil)
    }
    
    override func tearDown() {
        sut = nil
        expectedResult = nil
        
        super.tearDown()
    }
    
    // MARK: - Given
    func givenOneOperandOnly() -> (expression: [Token], expectedEvalResult: Result<MockBinaryOperator.Operand?, Error>) {
        let operandValue = Int.random(in: 1...100)
        
        return ([.operand(operandValue)], .success(operandValue))
    }
    
    func givenNotValidPostfixExpressionContainingBrackets() -> (expression: [Token], expectedEvalResult: Result<MockBinaryOperator.Operand?, Error>) {
        let expression: [Token] = [.operand(Int.random(in: 1...100)), .operand(Int.random(in: 1...100)), .binaryOperator(.add), .openingBracket, .closingBracket]
        
        return (expression, .failure(BinaryExpressionError.notValid))
    }
    
    func givenNotValidPostfixExpressionMissingOperand() -> (expression: [Token], expectedEvalResult: Result<MockBinaryOperator.Operand?, Error>) {
        let expression: [Token] = [.operand(Int.random(in: 1...100)), .operand(Int.random(in: 1...100)), .binaryOperator(.add), .binaryOperator(.multiply)]
        
        return (expression, .failure(BinaryExpressionError.notValid))
    }
    
    func givenNotValidPostfixExpressionMissingOperator() -> (expression: [Token], expectedEvalResult: Result<MockBinaryOperator.Operand?, Error>) {
        let expression: [Token] = [.operand(Int.random(in: 1...100)), .operand(Int.random(in: 1...100)), .binaryOperator(.add), .operand(Int.random(in: 1...100)), .binaryOperator(.multiply), .operand(Int.random(in: 1...100))]
        
        return (expression, .failure(BinaryExpressionError.notValid))
    }
    
    func givenValidPostfixExpressionsContainingOperationsThatFails() -> [(expression: [Token], errorThrown: Error)] {
        let failureExpr: [Token] = [.operand(10), .operand(20), .binaryOperator(.failingOperation)]
        let divisionByZeroExpr: [Token] = [.operand(Int.random(in: 1...100)), .operand(0), .binaryOperator(.divide)]
        
        return [
            (failureExpr, MockBinaryOperator.Error.failedOperation),
            (divisionByZeroExpr, MockBinaryOperator.Error.divisionByZero)
        ]
    }
    
    func givenAddOperationAsPostfix() -> (expression: [Token], expectedEvalResult: Result<MockBinaryOperator.Operand?, Error>) {
        let lhs = Int.random(in: 1...100)
        let rhs = Int.random(in: 1...100)
        let expression: [Token] = [.operand(lhs), .operand(rhs), .binaryOperator(.add)]
        
        return (expression, .success((lhs + rhs)))
    }
    
    func givenMultiplyOperationAsPostfix() -> (expression: [Token], expectedEvalResult: Result<MockBinaryOperator.Operand?, Error>) {
        let lhs = Int.random(in: 1...100)
        let rhs = Int.random(in: 1...100)
        let expression: [Token] = [.operand(lhs), .operand(rhs), .binaryOperator(.multiply)]
        
        return (expression, .success((lhs * rhs)))
    }
    
    func givenNotFailingDivideOperationAsPostfix() -> (expression: [Token], expectedEvalResult: Result<MockBinaryOperator.Operand?, Error>) {
        let lhs = Int.random(in: 1...100)
        let rhs = Int.random(in: 1...100)
        let expression: [Token] = [.operand(lhs), .operand(rhs), .binaryOperator(.divide)]
        
        return (expression, .success((lhs / rhs)))
    }
    
    func givenSubtractOperationAsPostfix() -> (expression: [Token], expectedEvalResult: Result<MockBinaryOperator.Operand?, Error>) {
        let lhs = Int.random(in: 1...100)
        let rhs = Int.random(in: 1...100)
        let expression: [Token] = [.operand(lhs), .operand(rhs), .binaryOperator(.subtract)]
        
        return (expression, .success((lhs - rhs)))
    }
    
    func givenValidPostfixExpressionsOfNotFailingOperations() -> [(expression: [Token], expectedEvalResult: Result<MockBinaryOperator.Operand?, Error>)] {
        
        return [
            givenAddOperationAsPostfix(),
            givenMultiplyOperationAsPostfix(),
            givenSubtractOperationAsPostfix(),
            givenNotFailingDivideOperationAsPostfix()
        ]
    }
    
    // MARK: - When
    func whenOneOperandOnly() -> [() -> Void]
    {
        var closures = [() -> Void]()
        let given = givenOneOperandOnly()
        
        closures.append {
            self.sut.expressionToEvaluate = given.expression
            self.sut.evalShouldThrowOnFailingOperation = false
            self.expectedResult = given.expectedEvalResult
        }
        
        closures.append {
            self.sut.expressionToEvaluate = given.expression
            self.sut.evalShouldThrowOnFailingOperation = true
            self.expectedResult = given.expectedEvalResult
        }
        
        return closures
    }
    
    func whenExpressionNotValidContainsBrackets() -> [() -> Void]{
        var closures = [() -> Void]()
        let given = givenNotValidPostfixExpressionContainingBrackets()
        
        closures.append {
            self.sut.expressionToEvaluate = given.expression
            self.sut.evalShouldThrowOnFailingOperation = false
            self.expectedResult = given.expectedEvalResult
        }
        
        closures.append {
            self.sut.expressionToEvaluate = given.expression
            self.sut.evalShouldThrowOnFailingOperation = true
            self.expectedResult = given.expectedEvalResult
        }
        
        return closures
    }
    
    func whenExpressionNotValidMissingOperand() -> [() -> Void] {
        var closures = [() -> Void]()
        let given = givenNotValidPostfixExpressionMissingOperand()
        
        closures.append {
            self.sut.expressionToEvaluate = given.expression
            self.sut.evalShouldThrowOnFailingOperation = false
            self.expectedResult = given.expectedEvalResult
        }
        
        closures.append {
            self.sut.expressionToEvaluate = given.expression
            self.sut.evalShouldThrowOnFailingOperation = true
            self.expectedResult = given.expectedEvalResult
        }
        
        return closures
    }
    
    func whenExpressionNotValidMissingOperator() -> [() -> Void] {
        var closures = [() -> Void]()
        let given = givenNotValidPostfixExpressionMissingOperator()
        
        closures.append {
            self.sut.expressionToEvaluate = given.expression
            self.sut.evalShouldThrowOnFailingOperation = false
            self.expectedResult = given.expectedEvalResult
        }
        
        closures.append {
            self.sut.expressionToEvaluate = given.expression
            self.sut.evalShouldThrowOnFailingOperation = true
            self.expectedResult = given.expectedEvalResult
        }
        
        return closures
    }
    
    func whenValidExpressionContainigFailingOperation(shouldThrowOnFailingOp: Bool) -> [() -> Void] {
        var closures = [() -> Void]()
        let givenExpressionsAndErrors = givenValidPostfixExpressionsContainingOperationsThatFails()
        
        for given in givenExpressionsAndErrors {
            closures.append {
                self.sut.expressionToEvaluate = given.expression
                self.sut.evalShouldThrowOnFailingOperation = shouldThrowOnFailingOp
                self.expectedResult = shouldThrowOnFailingOp ? .failure(given.errorThrown) : .success(nil)
            }
        }
        
        return closures
    }
    
    func whenValidPostfixExpressionsOfNotFailingOperations() -> [() -> Void] {
        var closures = [() -> Void]()
        
        let givenExpressions = givenValidPostfixExpressionsOfNotFailingOperations()
        
        for given in givenExpressions {
            closures.append {
                self.sut.expressionToEvaluate = given.expression
                self.sut.evalShouldThrowOnFailingOperation = false
                self.expectedResult = given.expectedEvalResult
            }
            
            closures.append {
                self.sut.expressionToEvaluate = given.expression
                self.sut.evalShouldThrowOnFailingOperation = false
                self.expectedResult = given.expectedEvalResult
            }
        }
        
        return closures
    }
    
    // MARK: - Then
    func thenResultFromSUTMatchesExpectedResult() {
        let result: Result<MockBinaryOperator.Operand?, Error>!
        do {
            let value = try _eval(
                postfix: self.sut.expressionToEvaluate,
                shouldThrowOnFailingOp: self.sut.evalShouldThrowOnFailingOperation
            )
            
            result = .success(value)
        } catch {
            result = .failure(error)
        }
        
        switch (result, self.expectedResult) {
        case (.success(let value), .success(let expectedValue)):
            XCTAssertEqual(value, expectedValue)
        case (.failure(let error as NSError), .failure(let expectedError as NSError)):
            XCTAssertEqual(error.domain, expectedError.domain)
            XCTAssertEqual(error.code, expectedError.code)
        default:
            XCTFail()
        }
        
    }
    
    // MARK: - Tests
    func test_whenEmpty_doesntThrow() {
        // given
        // when
        // then
        XCTAssertNoThrow(try _eval(postfix: [Token](), shouldThrowOnFailingOp: true))
        XCTAssertNoThrow(try _eval(postfix: [Token](), shouldThrowOnFailingOp: false))
    }
    
    func test_whenEmpty_returnsNil() {
        // given
        // when
        // then
        // guaranted by test_whenEmpty_doesntThrow()
        XCTAssertNil(try! _eval(postfix: [Token](), shouldThrowOnFailingOp: true))
        XCTAssertNil(try! _eval(postfix: [Token](), shouldThrowOnFailingOp: false))
    }
    
    func test_whenOneOperandOnly_doesntThrow() {
        // given
        let whenClosures = whenOneOperandOnly()
        
        for when in whenClosures {
            // when
            when()
            
            // then
            XCTAssertNoThrow(try _eval(postfix: sut.expressionToEvaluate, shouldThrowOnFailingOp: sut.evalShouldThrowOnFailingOperation))
        }
    }
    
    func test_whenOneOperandOnly_doesntReturnNil() {
        // given
        let whenClosures = whenOneOperandOnly()
        
        for when in whenClosures {
            // when
            when()
            
            // then
            // guaranted by test_whenOneOperandOnly_doesntThrow()
            XCTAssertNotNil(try! _eval(postfix: sut.expressionToEvaluate, shouldThrowOnFailingOp: sut.evalShouldThrowOnFailingOperation))
        }
    }
    
    func test_whenOneOperandOnly_returnsOperandsValueAsResult() {
        // given
        let whenClosures = whenOneOperandOnly()
        
        for when in whenClosures {
            // when
            when()
            
            // then
            // guaranted by test_whenOneOperandOnly_doesntReturnNil()
            let result: Result<MockBinaryOperator.Operand?, Error> = .success(try! _eval(postfix: sut.expressionToEvaluate, shouldThrowOnFailingOp: sut.evalShouldThrowOnFailingOperation))
            
            switch (result, expectedResult) {
            case (.success(let resultValue), .success(let expectedResultValue)):
                XCTAssertEqual(resultValue, expectedResultValue)
            default:
                XCTFail()
            }
            
        }
    }
    
    func test_whenExpressionNotValidContainsBrackets_throwsExpectedError() {
        // given
        let whenClosures = whenExpressionNotValidContainsBrackets()
        
        for when in whenClosures {
            // when
            when()
            
            // then
            XCTAssertThrowsError(try _eval(postfix: self.sut.expressionToEvaluate, shouldThrowOnFailingOp: self.sut.evalShouldThrowOnFailingOperation))
            thenResultFromSUTMatchesExpectedResult()
        }
    }
    
    func test_whenExpressionNotValidMissingOperand_throwsExpectedError() {
        // given
        let whenClosures = whenExpressionNotValidMissingOperand()
        
        for when in whenClosures {
            // when
            when()
            
            // then
            XCTAssertThrowsError(try _eval(postfix: self.sut.expressionToEvaluate, shouldThrowOnFailingOp: self.sut.evalShouldThrowOnFailingOperation))
            thenResultFromSUTMatchesExpectedResult()
        }
    }
    
    func test_whenExpressionNotValidMissingOperator_throwsExpectedError() {
        // given
        let whenClosures = whenExpressionNotValidMissingOperator()
        
        for when in whenClosures {
            // when
            when()
            
            // then
            XCTAssertThrowsError(try _eval(postfix: self.sut.expressionToEvaluate, shouldThrowOnFailingOp: self.sut.evalShouldThrowOnFailingOperation))
            thenResultFromSUTMatchesExpectedResult()
        }
    }
    
    func test_whenValidExpressionContainigFailingOperation_andShouldThrowOnFailingOpIsTrue_throwsExpectedError() {
        // given
        let whenClosures = whenValidExpressionContainigFailingOperation(shouldThrowOnFailingOp: true)
        
        for when in whenClosures {
            // when
            when()
            
            // then
            XCTAssertThrowsError(try _eval(postfix: self.sut.expressionToEvaluate, shouldThrowOnFailingOp: self.sut.evalShouldThrowOnFailingOperation))
            thenResultFromSUTMatchesExpectedResult()
        }
    }
    
    func test_whenValidExpressionContainigFailingOperation_andShouldThrowOnFailingOpIsFalse_doesntThrow() {
        // given
        let whenClosures = whenValidExpressionContainigFailingOperation(shouldThrowOnFailingOp: false)
        
        for when in whenClosures {
            // when
            when()
            
            // then
            XCTAssertNoThrow(try _eval(postfix: self.sut.expressionToEvaluate, shouldThrowOnFailingOp: self.sut.evalShouldThrowOnFailingOperation))
        }
    }
    
    func test_whenValidExpressionContainigFailingOperation_andShouldThrowOnFailingOpIsFalse_returnsNil()
    {
        // given
        let whenClosures = whenValidExpressionContainigFailingOperation(shouldThrowOnFailingOp: false)
        
        for when in whenClosures {
            // when
            when()
            
            // then
            XCTAssertNil(try! _eval(postfix: self.sut.expressionToEvaluate, shouldThrowOnFailingOp: self.sut.evalShouldThrowOnFailingOperation))
            thenResultFromSUTMatchesExpectedResult()
        }
    }
    
    func test_whenValidPostfixExpressionsOfNotFailingOperations_doesntThrow() {
        // given
        let whenClosures = whenValidPostfixExpressionsOfNotFailingOperations()
        
        for when in whenClosures {
            // when
            when()
            
            // then
            XCTAssertNoThrow(try _eval(postfix: self.sut.expressionToEvaluate, shouldThrowOnFailingOp: self.sut.evalShouldThrowOnFailingOperation))
        }
    }
    
    func test_whenValidPostfixExpressionsOfNotFailingOperations_returnsNotNilValue() {
        // given
        let whenClosures = whenValidPostfixExpressionsOfNotFailingOperations()
        
        for when in whenClosures {
            // when
            when()
            
            // then
            XCTAssertNotNil(try! _eval(postfix: self.sut.expressionToEvaluate, shouldThrowOnFailingOp: self.sut.evalShouldThrowOnFailingOperation))
        }
    }
    
    func test_whenValidPostfixExpressionsOfNotFailingOperations_returnsExpectedValue() {
        // given
        let whenClosures = whenValidPostfixExpressionsOfNotFailingOperations()
        
        for when in whenClosures {
            // when
            when()
            
            // then
            thenResultFromSUTMatchesExpectedResult()
        }
    }
    
    static var allTests = [
        ("test_whenEmpty_doesntThrow", test_whenEmpty_doesntThrow),
        ("test_whenEmpty_returnsNil" ,test_whenEmpty_returnsNil),
        ("test_whenOneOperandOnly_doesntThrow", test_whenOneOperandOnly_doesntThrow),
        ("test_whenOneOperandOnly_doesntReturnNil", test_whenOneOperandOnly_doesntReturnNil),
        ("test_whenOneOperandOnly_returnsOperandsValueAsResult", test_whenOneOperandOnly_returnsOperandsValueAsResult),
        ("test_whenExpressionNotValidContainsBrackets_throwsExpectedError", test_whenExpressionNotValidContainsBrackets_throwsExpectedError),
        ("test_whenExpressionNotValidMissingOperand_throwsExpectedError", test_whenExpressionNotValidMissingOperand_throwsExpectedError),
        ("test_whenExpressionNotValidMissingOperator_throwsExpectedError", test_whenExpressionNotValidMissingOperator_throwsExpectedError),
        ("test_whenValidExpressionContainigFailingOperation_andShouldThrowOnFailingOpIsTrue_throwsExpectedError", test_whenValidExpressionContainigFailingOperation_andShouldThrowOnFailingOpIsTrue_throwsExpectedError),
        ("test_whenValidExpressionContainigFailingOperation_andShouldThrowOnFailingOpIsFalse_doesntThrow", test_whenValidExpressionContainigFailingOperation_andShouldThrowOnFailingOpIsFalse_doesntThrow),
        ("test_whenValidExpressionContainigFailingOperation_andShouldThrowOnFailingOpIsFalse_returnsNil", test_whenValidExpressionContainigFailingOperation_andShouldThrowOnFailingOpIsFalse_returnsNil),
        ("test_whenValidPostfixExpressionsOfNotFailingOperations_doesntThrow", test_whenValidPostfixExpressionsOfNotFailingOperations_doesntThrow),
        ("test_whenValidPostfixExpressionsOfNotFailingOperations_returnsNotNilValue", test_whenValidPostfixExpressionsOfNotFailingOperations_returnsNotNilValue),
        ("test_whenValidPostfixExpressionsOfNotFailingOperations_returnsExpectedValue", test_whenValidPostfixExpressionsOfNotFailingOperations_returnsExpectedValue),
        
    ]
}
