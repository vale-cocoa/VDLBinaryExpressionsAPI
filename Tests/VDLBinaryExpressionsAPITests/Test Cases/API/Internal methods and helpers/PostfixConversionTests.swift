//
//  VDLBinaryExpressionsAPITests
//  PostfixConversionTests.swift
//
//
//  Created by Valeriano Della Longa on 16/02/2020.
//  Copyright (c) 2020 Valeriano Della Longa
//

import XCTest
@testable import VDLBinaryExpressionsAPI

final class PostfixConversionTests: XCTestCase {
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
    func givenBaseExpressionsMakingValidateInfixChunkThrow()
        -> [AnyCollection<DummyToken>]
    {
        var expressions = [AnyCollection<DummyToken>]()
        
        expressions.append(AnyCollection([.closingBracket, .openingBracket]))
        
        expressions.append(AnyCollection([.closingBracket, .operand(10)]))
        
        expressions.append(AnyCollection([.operand(10), .openingBracket]))
        
        expressions.append(AnyCollection([.operand(10), .operand(20)]))
        
        expressions.append(AnyCollection([.openingBracket, .closingBracket]))
        
        for anOp in MockDummyOperator.allCases {
            let opToken: DummyToken = .binaryOperator(anOp)
            expressions.append(AnyCollection([opToken, .closingBracket]))
            expressions.append(AnyCollection([.openingBracket, opToken]))
            
            for anotherOp in MockDummyOperator.allCases {
                let otherOpToken: DummyToken = .binaryOperator(anotherOp)
                expressions.append(AnyCollection([opToken, otherOpToken]))
            }
        }
        
        return expressions
    }
    
    func givenInfixExpressionsWhereBracketingIsNotBalanced() -> [AnyCollection<DummyToken>]
    {
        var expressions = [[DummyToken]]()
        let validBaseInfix = MockDummyOperator.givenValidSimpleExpressionsOfTwoOperands()
            .map { $0.infix }
        let openingBracketExpr: [DummyToken] = [.openingBracket]
        let closingBracketExpr: [DummyToken] = [.closingBracket]
        
        for validLhs in validBaseInfix {
            let unbalancedOpening = openingBracketExpr + validLhs
            let unbalancingClosing = validLhs + closingBracketExpr
            
            expressions.append(unbalancedOpening)
            expressions.append(unbalancingClosing)
            
            for anOp in MockDummyOperator.allCases {
                let opTokenExpr: [DummyToken] = [.binaryOperator(anOp)]
                for validRhs in validBaseInfix.shuffled() {
                    let combinedUnbalancedOpening = unbalancedOpening + opTokenExpr + validRhs
                    let combinedUnbalancedClosing = validRhs + opTokenExpr + unbalancingClosing
                    expressions.append(combinedUnbalancedOpening)
                    expressions.append(combinedUnbalancedClosing)
                }
            }
        }
        
        return expressions
            .map {
                let bracketed = openingBracketExpr + $0 + closingBracketExpr
                
                return AnyCollection(bracketed)
        }
    }
    
    func givenValidInfixBaseExpressions() -> [AnyCollection<DummyToken>]
    {
        let baseInfix = MockDummyOperator.givenValidSimpleExpressionsOfTwoOperands()
            .map { AnyCollection($0.infix) }
        
        let justOperandExpr: AnyCollection<DummyToken> = AnyCollection([.operand(10)])
        
        return [justOperandExpr] + baseInfix
    }
    
    // MARK: - When
    func whenContainsTwoContiguousTokensNotValidInInfix_cases() -> [() -> Void]
    {
        return givenBaseExpressionsMakingValidateInfixChunkThrow()
            .map { invalidChunck in
                return {
                    self.sut = invalidChunck
                    self.expectedResult = .failure(BinaryExpressionError.notValid)
                }
        }
        
    }
    
    func whenBracketingIsNotBalanced_cases() -> [() -> Void]
    {
        return givenInfixExpressionsWhereBracketingIsNotBalanced()
            .map { expression in
                return {
                    self.sut = expression
                    self.expectedResult = .failure(BinaryExpressionError.notValid)
                }
        }
    }
    
    func whenTokensAreInValidInfixOrder_cases()
        -> [() -> Void]
    {
        let justOneOperand: DummyTokenValidExpression = ([.operand(10)], [.operand(10)])
        let base = [justOneOperand] + MockDummyOperator.givenValidSimpleExpressionsOfTwoOperands()
        
        var cases = [() -> Void]()
        
        for validAndResultLHS in base {
            for anOp in MockDummyOperator.allCases {
                let opTokenExpr: [DummyToken] = [.binaryOperator(anOp)]
                for validAndResultRHS in base.shuffled() {
                    cases.append {
                        self.sut = AnyCollection(validAndResultLHS.infix)
                        self.expectedResult = .success(validAndResultLHS.postfix)
                    }
                    
                    let combinedInfix = bracketed(validAndResultLHS.infix) + opTokenExpr + bracketed(validAndResultRHS.infix)
                    let combinedPostfix = validAndResultLHS.postfix + validAndResultRHS.postfix + opTokenExpr
                    
                    cases.append {
                        self.sut = AnyCollection(self.bracketed(combinedInfix))
                        self.expectedResult = .success(combinedPostfix)
                    }
                    
                }
            }
        }
        
        return cases
    }
    
    func whenValidWithMultipleDifferentOperators_cases()
        -> [() -> Void]
    {
        return MockDummyOperator.givenValidExpressionsOfThreeOperands()
            .map { given in
                return {
                    self.sut = AnyCollection(given.infix)
                    self.expectedResult = .success(given.postfix)
                }
        }
    }
    
    func bracketed(_ expression: [DummyToken]) -> [DummyToken]
    {
        return [.openingBracket] + expression + [.closingBracket]
    }
    
    // MARK: - Then
    func thenResultIsExpected() {
        let result: Result<[DummyToken], Error>!
        do {
            let postfix = try sut.convertToPostfixNotation()
            result = .success(postfix)
        } catch {
            result = .failure(error)
        }
        switch (result, expectedResult) {
        case (.success(let postfix), .success(let expected)):
            XCTAssertEqual(postfix, expected)
        case (.failure(let resultError as NSError), .failure(let expectedError as NSError)):
            XCTAssertEqual(resultError.domain, expectedError.domain)
            XCTAssertEqual(resultError.code, expectedError.code)
        default:
            XCTFail("result: \(String(describing: result)) — expectedResult: \(String(describing: expectedResult))")
        }
    }
    
    // MARK: - Tests
    func test_whenEmpty_doesntThrow() {
        XCTAssertNoThrow(try sut.convertToPostfixNotation())
    }
    
    func test_whenEmpty_returnsEmpty() {
        XCTAssertTrue(try! sut.convertToPostfixNotation().isEmpty)
    }
    
    func test_whenContainsTwoContiguousTokensNotValidInInfix_throws()
    {
        for when in whenContainsTwoContiguousTokensNotValidInInfix_cases() {
            // when
            when()
            
            // then
            XCTAssertThrowsError(try sut.convertToPostfixNotation())
        }
    }
    
    func test_whenBracketingIsNotBalanced_throws() {
        for when in whenBracketingIsNotBalanced_cases() {
            // when
            when()
            
            // then
            XCTAssertThrowsError(try sut.convertToPostfixNotation())
        }
    }
    
    func test_whenTokensAreInValidInfixOrderAndBracketingBalanced_doesntThrow()
    {
        for when in whenTokensAreInValidInfixOrder_cases() {
            // when
            when()
            
            // then
            XCTAssertNoThrow(try sut.convertToPostfixNotation())
        }
    }
    
    func test_whenTokensAreInValidInfixOrderAndBracketingBalanced_returnsExpectedValue() {
        for when in whenTokensAreInValidInfixOrder_cases() {
            // when
            when()
            
            // then
            thenResultIsExpected()
        }
    }
    
    func test_whenValidWithMultipleDifferentOperators_returnsExpectedValue()
    {
        for when in whenValidWithMultipleDifferentOperators_cases() {
            // when
            when()
            
            // then
            thenResultIsExpected()
        }
    }
    
    static var allTests = [
        ("test_whenEmpty_doesntThrow", test_whenEmpty_doesntThrow),
        ("test_whenEmpty_returnsEmpty", test_whenEmpty_returnsEmpty),
        ("test_whenContainsTwoContiguousTokensNotValidInInfix_throws", test_whenContainsTwoContiguousTokensNotValidInInfix_throws),
        ("test_whenBracketingIsNotBalanced_throws", test_whenBracketingIsNotBalanced_throws),
        ("test_whenTokensAreInValidInfixOrderAndBracketingBalanced_doesntThrow", test_whenTokensAreInValidInfixOrderAndBracketingBalanced_doesntThrow),
        ("test_whenTokensAreInValidInfixOrderAndBracketingBalanced_returnsExpectedValue", test_whenTokensAreInValidInfixOrderAndBracketingBalanced_returnsExpectedValue),
        ("test_whenValidWithMultipleDifferentOperators_returnsExpectedValue", test_whenValidWithMultipleDifferentOperators_returnsExpectedValue),
        
    ]
}
