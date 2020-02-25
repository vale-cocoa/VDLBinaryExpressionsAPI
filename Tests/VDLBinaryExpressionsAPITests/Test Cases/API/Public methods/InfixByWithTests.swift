//
//  VDLBinaryExpressionsAPITests
//  InfixByWithTests.swift
//
//
//  Created by Valeriano Della Longa on 18/02/2020.
//  Copyright (c) 2020 Valeriano Della Longa
//

import XCTest
@testable import VDLBinaryExpressionsAPI

final class InfixByWithTests: XCTestCase {
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
            let lhs = self.sut.lhs.validInfix(),
            let rhs = self.sut.rhs.validInfix(),
            !lhs.isEmpty,
            !rhs.isEmpty
            else {
                self.expectedResult = .failure(BinaryExpressionError.notValid)
                return
        }
        
        let bracketingCriteria = self.shouldBracket(lhs: lhs, rhs: rhs, operation: self.sut.operation)
        
        let lhsResult = bracketingCriteria.bracketLhs ? self.bracketed(lhs) : lhs
        let rhsResult = bracketingCriteria.bracketRhs ? self.bracketed(rhs) : rhs
        let opToken: Token = .binaryOperator(self.sut.operation)
        let infix = lhsResult + [opToken] + rhsResult
        self.expectedResult = .success(infix)
    }
    
    func shouldBracket(lhs: [Token], rhs: [Token], operation: MockBinaryOperator) -> (bracketLhs: Bool, bracketRhs: Bool)
    {
        var shouldBracketLhs: Bool = false
        var shouldBracketRhs: Bool = false
        
        var lhsOp: MockBinaryOperator? = nil
        var rhsOP: MockBinaryOperator? = nil
        
        if case .binaryOperator(let op) = lhs.validPostfix()?.last
        {
            lhsOp = op
        }
        
        if case .binaryOperator(let op) = rhs.validPostfix()?.last
        {
            rhsOP = op
        }
        switch (lhsOp?.associativity,
                operation.associativity,
                rhsOP?.associativity)
        {
        case (.none, _, .none):
            break
            
        case (.left, .left, nil):
            shouldBracketLhs = operation.priority > lhsOp!.priority
            
        case (.right, .left, nil):
            shouldBracketLhs = operation.priority < lhsOp!.priority
            
        case (.some(_), .right, nil):
            shouldBracketLhs = operation.priority >= lhsOp!.priority
            
        case (nil, .left, .some(_)):
            shouldBracketRhs = operation.priority > rhsOP!.priority
            
        case (nil, .right, .left):
            shouldBracketRhs = operation.priority >= rhsOP!.priority
        
        case (nil, .right, .right):
            shouldBracketRhs = operation.priority < rhsOP!.priority
            
        case (.left, .left, .some(_)):
            shouldBracketLhs = operation.priority > lhsOp!.priority
            shouldBracketRhs = operation.priority > rhsOP!.priority
            
        case (.right, .left, .some(_)):
            shouldBracketLhs = operation.priority < lhsOp!.priority
            shouldBracketRhs = operation.priority > rhsOP!.priority
            
        case (.some(_), .right, .left):
            shouldBracketLhs = operation.priority >= lhsOp!.priority
            shouldBracketRhs = operation.priority >= rhsOP!.priority
            
        case (.some(_), .right, .right):
            shouldBracketLhs = operation.priority >= lhsOp!.priority
            shouldBracketRhs = operation.priority < rhsOP!.priority
        }
        
        return (shouldBracketLhs, shouldBracketRhs)
    }
    
    func bracketed(_ expression: [Token]) -> [Token] {
        return [.openingBracket] + expression + [.closingBracket]
    }
    
    // MARK: - When
    func whenPostfixByWithThrows_cases() -> [() -> Void] {
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
    
    func whenPostfixByWithDoesntThrow_cases() -> [() -> Void]
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
            let infix = try sut.lhs.infix(by: sut.operation, with: sut.rhs)
            result = .success(infix)
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
    
    func thenResultIsValidInfixNotation() {
        let infix: [Token]!
        do {
            infix = try sut.lhs.infix(by: sut.operation, with: sut.rhs)
            XCTAssertFalse(infix.isValidPostfixNotation())
            XCTAssertNotNil(infix.validPostfix())
        } catch {
            XCTFail("operation did throw")
        }
    }
    
    // MARK: - Tests
    func test_whenPostfixByWithThrows_throws() {
        for when in whenPostfixByWithThrows_cases() {
            // when
            when()
            
            // then
            XCTAssertThrowsError(try sut.lhs.infix(by: sut.operation, with: sut.rhs))
        }
        
    }
    
    func test_whenThrows_ErrorIsExpected() {
        for when in whenPostfixByWithThrows_cases() {
            // when
            when()
            
            // then
            thenResultIsExpected()
        }
    }
    
    func test_whenPostfixByWithDoesntThrow_doesntThrow() {
        for when in whenPostfixByWithDoesntThrow_cases() {
            // when
            when()
            
            // then
            XCTAssertNoThrow(try sut.lhs.infix(by: sut.operation, with: sut.rhs))
        }
    }
    
    func test_whenPostfixByWithDoesntThrow_resultIsExpected() {
        for when in whenPostfixByWithDoesntThrow_cases() {
            // when
            when()
            
            // then
            thenResultIsExpected()
        }
    }
    
    func test_whenPostfixByWithDoesntThrow_resultIsValidInfix() {
        for when in whenPostfixByWithDoesntThrow_cases() {
            // when
            when()
            
            // then
            thenResultIsValidInfixNotation()
        }
    }
    
    
    
    static var allTests = [
        ("test_whenPostfixByWithThrows_throws", test_whenPostfixByWithThrows_throws),
        ("test_whenThrows_ErrorIsExpected", test_whenThrows_ErrorIsExpected),
        ("test_whenPostfixByWithDoesntThrow_doesntThrow", test_whenPostfixByWithDoesntThrow_doesntThrow),
        ("test_whenPostfixByWithDoesntThrow_resultIsExpected", test_whenPostfixByWithDoesntThrow_resultIsExpected),
        ("test_whenPostfixByWithDoesntThrow_resultIsValidInfix", test_whenPostfixByWithDoesntThrow_resultIsValidInfix),
        
    ]
}
