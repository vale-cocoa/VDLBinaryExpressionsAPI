//
//  VDLBinaryExpressionsAPITests
//  PostfixByWithTests.swift
//
//
//  Created by Valeriano Della Longa on 18/02/2020.
//  Copyright (c) 2020 Valeriano Della Longa
//

import XCTest
@testable import VDLBinaryExpressionsAPI

import Foundation

final class PostfixByWithTests: XCTestCase {
    struct _Sut {
        var lhs: AnyCollection<Token> = AnyCollection([])
        var rhs: AnyCollection<Token> = AnyCollection([])
        var operation: MockBinaryOperator = .failingOperation
    }
    
    var sut: _Sut!
    var expectedResult: Result<[Token], Error>!
    
    // MARK: - Test lifecycle
    override func setUp() {
        super.setUp()
        
        sut = _Sut()
        expectedResult = .failure(BinaryExpressionError.notValid)
    }
    
    override func tearDown() {
        sut = nil
        expectedResult = nil
    }
    
    // MARK: - Given
    func givenNotValidExpression() -> AnyCollection<Token> {
        let notValid: [Token] = [.openingBracket, .operand(10), .operand(20), .binaryOperator(.add), .closingBracket]
        
        return AnyCollection(notValid)
    }
    
    func givenSimpleValidExpressionsNotEmpty() -> [AnyCollection<Token>]
    {
        let postfix = MockBinaryOperator.givenSimpleBinaryOperationExpressions()
            .dropFirst()
            .map { $0.expression }
        let infix = MockBinaryOperator.givenSimpleBinaryOperationExpressions(postfix: false)
            .dropFirst()
            .map { $0.expression }
        
        return (postfix + infix)
            .shuffled()
    }
    
    // MARK: - Helpers
    func givenExpectedResultSetup() {
        guard
            let lhs = self.sut.lhs.validPostfix(),
            let rhs = self.sut.rhs.validPostfix(),
            !lhs.isEmpty,
            !rhs.isEmpty
            else {
                self.expectedResult = .failure(BinaryExpressionError.notValid)
                return
        }
        
        let opToken: Token = .binaryOperator(self.sut.operation)
        let postfix = lhs + rhs + [opToken]
        self.expectedResult = .success(postfix)
    }
    
    // MARK: - When
    func whenEitherOrBothOperandsEmptyOrNotValid_cases()
        -> [() -> Void]
    {
        var cases = [() -> Void]()
        
        let empty = MockBinaryOperator.givenEmptyExpression().expression
        let notValid = givenNotValidExpression()
        let valid = MockBinaryOperator.givenJustOperandExpression().expression
        let emptyOrInvalid = [empty, notValid]
        
        for anOp in MockBinaryOperator.allCases {
            for shouldMakeItThrow in emptyOrInvalid {
                cases.append {
                    self.sut = _Sut(lhs: valid, rhs: shouldMakeItThrow, operation: anOp)
                    self.givenExpectedResultSetup()
                }
                
                cases.append {
                    self.sut = _Sut(lhs: shouldMakeItThrow, rhs: valid, operation: anOp)
                    self.givenExpectedResultSetup()
                }
                
                cases.append {
                    self.sut = _Sut(lhs: shouldMakeItThrow, rhs: shouldMakeItThrow, operation: anOp)
                }
                
            }
        }
        
        return cases
    }
    
    func whenBothOperandsAreValidAndNotEmpty_cases() -> [() -> Void]
    {
        var cases = [() -> Void]()
        let lhsExpressions = givenSimpleValidExpressionsNotEmpty()
        let rhsExpressions = givenSimpleValidExpressionsNotEmpty()
        
        for anOp in MockBinaryOperator.allCases {
            for lhs in lhsExpressions {
                for rhs in rhsExpressions {
                    cases.append {
                        self.sut = _Sut(lhs: lhs, rhs: rhs, operation: anOp)
                        self.givenExpectedResultSetup()
                    }
                }
            }
        }
        
        return cases
    }
    
    // MARK: - Then
    func thenResultIsExpected() {
        let result: Result<[Token], Error>!
        do {
            let postfix = try sut.lhs.postfix(by: sut.operation, with: sut.rhs)
            result = .success(postfix)
        } catch {
            result = .failure(error)
        }
        
        switch (result, expectedResult) {
        case (.success(let resultInfix), .success(let expectedInfix)):
            XCTAssertEqual(resultInfix, expectedInfix)
            
        case (.failure(let resultError as NSError), .failure(let expectedError as NSError)):
            XCTAssertEqual(resultError.domain, expectedError.domain)
            XCTAssertEqual(resultError.code, expectedError.code)
        default:
            XCTFail()
        }
    }
    
    func thenResultIsValidPostfixNotation() {
        let postfix: [Token]!
        do {
            postfix = try sut.lhs.postfix(by: sut.operation, with: sut.rhs)
            XCTAssertTrue(postfix.isValidPostfixNotation())
        } catch {
            XCTFail("operation did throw")
        }
    }
    
    // MARK: - Tests
    func test_whenNotValidOrEmpty_throws() {
        for when in whenEitherOrBothOperandsEmptyOrNotValid_cases() {
            // when
            when()
            
            // then
            XCTAssertThrowsError(try sut.lhs.postfix(by: sut.operation, with: sut.rhs))
        }
    }
    
    func test_whenThrows_ErrorIsExpected() {
        for when in whenEitherOrBothOperandsEmptyOrNotValid_cases() {
            // when
            when()
            
            // then
            thenResultIsExpected()
        }
    }
    
    func test_whenNotEmptyValidOperands_doesntThrow() {
        for when in whenBothOperandsAreValidAndNotEmpty_cases() {
            // when
            when()
            
            // then
            XCTAssertNoThrow(try sut.lhs.postfix(by: sut.operation, with: sut.rhs))
        }
    }
    
    func test_whenNotEmptyValidOperands_resultIsExpected() {
        for when in whenBothOperandsAreValidAndNotEmpty_cases() {
            // when
            when()
            
            // then
            thenResultIsExpected()
        }
    }
    
    func test_whenNotEmptyValidOperands_resultIsValidPostfix() {
        for when in whenBothOperandsAreValidAndNotEmpty_cases() {
            // when
            when()
            
            // then
            thenResultIsValidPostfixNotation()
        }
    }
    
    
    
    static var allTests = [
        ("test_whenNotValidOrEmpty_throws_", test_whenNotValidOrEmpty_throws),
        ("test_whenThrows_ErrorIsExpected", test_whenThrows_ErrorIsExpected),
        ("test_whenNotEmptyValidOperands_doesntThrow", test_whenNotEmptyValidOperands_doesntThrow),
        ("test_whenNotEmptyValidOperands_resultIsExpected", test_whenNotEmptyValidOperands_resultIsExpected),
        ("test_whenNotEmptyValidOperands_resultIsValidPostfix", test_whenNotEmptyValidOperands_resultIsValidPostfix),
        
    ]
}
