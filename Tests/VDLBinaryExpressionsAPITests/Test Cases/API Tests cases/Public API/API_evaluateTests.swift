//
//  VDLBinaryExpressionsAPI
//  API_evaluateTests.swift
//  
//
//  Created by Valeriano Della Longa on 09/02/2020.
//  Copyright (c) 2020 Valeriano Della Longa
//

import XCTest
@testable import VDLBinaryExpressionsAPI

final class API_evaluateTests: XCTestCase {
    typealias Token = BinaryOperatorExpressionToken<MockBinaryOperator>
    
    // MARK: - Properties
    var sut: [Token]!
    var validPostfixReturnedExpression: Bool!
    var _evalDidThrow: Bool!
    var _failingError: Error? = nil
    var expectedResult: Token.Operand!
    
    // MARK: - Test lifecycle
    override func setUp() {
        super.setUp()
        
    }
    
    override func tearDown() {
        self.sut = nil
        self.validPostfixReturnedExpression = nil
        self._evalDidThrow = nil
        self._failingError = nil
        self.expectedResult = nil
    }
    
    // MARK: - Given
    func givenEmpty() {
        sut = []
    }
    
    func givenValidExpression() {
        sut = [.operand(10), .operand(20), .binaryOperator(.add)]
    }
    
    func givenNotValidExpression() {
        sut = [.operand(10), .operand(20)]
    }
    
    func givenValidExpressionContainingFailingOperator() {
        sut = [.operand(10), .operand(20), .binaryOperator(.failingOperation)]
    }
    
    // MARK: - When
    func whenValidPostfixReturnsNil() {
        givenNotValidExpression()
        validPostfixReturnedExpression = sut.validPostfix() != nil
    }
    
    func whenValidPostfixReturnsValue() {
        givenValidExpression()
        validPostfixReturnedExpression = sut.validPostfix() != nil
    }
    
    func whenEvalShouldThrowOnFailingOperationDidThrow() {
        givenValidExpressionContainingFailingOperator()
        validPostfixReturnedExpression = sut.validPostfix() != nil
        setExpectedResult_evalDidThrow_failingError {
            try MockBinaryOperator.failingOperation.binaryOperation(20, 30)
        }
    }
    
    
    
    func whenEvalShouldThrowOnFailingOperationReturnsValue() {
        givenValidExpression()
        validPostfixReturnedExpression = sut.validPostfix() != nil
        setExpectedResult_evalDidThrow_failingError()
    }
    
    func setExpectedResult_evalDidThrow_failingError(on op: (() throws -> Token.Operand)? = nil) {
        do {
            expectedResult = try op?() ?? _eval(postfix: sut, shouldThrowOnFailingOp: true)
            _evalDidThrow = false
        } catch {
            _evalDidThrow = true
            _failingError = error
        }
    }
    
    func whenEvalShouldThrowOnFailingOperationReturnsNil() {
        givenEmpty()
        validPostfixReturnedExpression = true
        _evalDidThrow = false
    }
    
    // MARK: - Tests
    func test_whenValidPostfixReturnsNil_throws() {
        // when
        whenValidPostfixReturnsNil()
        
        // then
        XCTAssertThrowsError(try sut.evaluate())
    }
    
    func test_whenEvalShouldThrowOnFailingOperationThrows_throws() {
        // when
        whenEvalShouldThrowOnFailingOperationDidThrow()
        
        // then
        XCTAssertThrowsError(try sut.evaluate())
    }
    
    func test_whenEvalShouldThrowOnFailingOperationThrows_ErrorThrownIsTheOperationOne() {
        // when
        whenEvalShouldThrowOnFailingOperationDidThrow()
        var result: Error?
        do {
            let _ = try sut.evaluate()
        } catch {
            result = error
        }
        
        let nsResult = result as NSError?
        let nsExpectedResult = _failingError as NSError?
        // then
        XCTAssertNotNil(nsResult)
        XCTAssertNotNil(nsExpectedResult)
        XCTAssertEqual(nsResult?.domain, nsExpectedResult?.domain)
        XCTAssertEqual(nsResult?.code, nsExpectedResult?.code)
    }
    
    func test_whenValidPostfixReturnsValue_doesntThrow() {
        // when
        
        whenValidPostfixReturnsValue()
        // then
        XCTAssertNoThrow(try sut.evaluate())
    }
    
    func test_whenEvalShouldThrowOnFailingOperationReturnsNil_returnsEmptyValue() {
        // when
        whenEvalShouldThrowOnFailingOperationReturnsNil()
        
        // then
        XCTAssertEqual(try! sut.evaluate(), MockBinaryOperator.Operand.empty())
    }
    
    func test_whenEvalShouldThrowOnFailingOperationReturnsValue_returnsSameValue() {
        // when
        whenEvalShouldThrowOnFailingOperationReturnsValue()
        
        // then
        XCTAssertEqual(try! sut.evaluate(), expectedResult)
    }
    
    static var allTests = [
        ("test_whenValidPostfixReturnsNil_throws", test_whenValidPostfixReturnsNil_throws),
        ("test_whenEvalShouldThrowOnFailingOperationThrows_throws", test_whenEvalShouldThrowOnFailingOperationThrows_throws),
        ("test_whenEvalShouldThrowOnFailingOperationThrows_ErrorThrownIsTheOperationOne", test_whenEvalShouldThrowOnFailingOperationThrows_ErrorThrownIsTheOperationOne),
       ("test_whenValidPostfixReturnsValue_doesntThrow", test_whenValidPostfixReturnsValue_doesntThrow),
       ("test_whenEvalShouldThrowOnFailingOperationReturnsNil_returnsEmptyValue", test_whenEvalShouldThrowOnFailingOperationReturnsNil_returnsEmptyValue),
        
    ]
}
