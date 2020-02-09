//
//  VDLBinaryExpressionsAPI
//  API_addBracketsTests.swift
//
//
//  Created by Valeriano Della Longa on 06/02/2020.
//  Copyright (c) 2020 Valeriano Della Longa
//
import XCTest
@testable import VDLBinaryExpressionsAPI

final class API_addBracketsTests: XCTestCase {
    typealias Token = BinaryOperatorExpressionToken<MockBinaryOperator>
    
    // MARK: - properties
    var sut: _SubInfixExpression<MockBinaryOperator>!
    
    // MARK: - Given
    func givenWhenNotValid() -> [() -> Void] {
        return [
            whenExpressionSingleTokenNotOperandAndNilMainOperator,
            whenExpressionSingleTokenOperandAndNotNilMainOperator,
            whenExpressionMultipleTokensAndNilMainOperator,
            whenExpressionInvalidInfixAndNotNilMainOperator,
            
        ]
    }
    
    func givenWhenValid() -> [() -> Void] {
        return [
            whenExpressionSingleTokenIsOperandAndNilMainOperator,
            whenExpressionValidInfixAndNotNilMainOperator,
            whenExpressionValidInfixAndMainOperatorMultiply,
            whenExpressionValidInfixAndMainOperatorAdd,
            
        ]
    }
    
    // MARK: - When
    // MARK: - SUT NOT valid
    func whenExpressionSingleTokenNotOperandAndNilMainOperator() {
        sut = (expression: [.openingBracket], mainOperator: nil)
    }
    
    func whenExpressionSingleTokenOperandAndNotNilMainOperator() {
        sut = (expression: [.operand(10)], mainOperator: .add)
    }
    
    func whenExpressionMultipleTokensAndNilMainOperator() {
        sut = (expression: [.operand(100), .operand(200)], mainOperator: nil)
    }
    
    func whenExpressionInvalidInfixAndNotNilMainOperator() {
        sut = (expression: [.operand(100), .operand(200)], mainOperator: .add)
    }
    
    // MARK: - SUT valid
    func whenExpressionSingleTokenIsOperandAndNilMainOperator() {
        sut = (expression: [.operand(10)], mainOperator: nil)
    }
    func whenExpressionValidInfixAndNotNilMainOperator() {
        sut = (expression: [.operand(10), .binaryOperator(.add), .operand(20)], mainOperator: .add)
    }
    
    func whenExpressionValidInfixAndMainOperatorMultiply() {
        sut = _SubInfixExpression<MockBinaryOperator>(expression: [.operand(10), .binaryOperator(.multiply), .operand(5)], mainOperator: .multiply)
    }
    
    func whenExpressionValidInfixAndMainOperatorAdd() {
        sut = _SubInfixExpression<MockBinaryOperator>(expression: [.operand(10), .binaryOperator(.add), .operand(5)], mainOperator: .add)
    }
    
    // MARK: - Test lifecycle
    override func setUp() {
        super.setUp()
        
        
    }
    
    override func tearDown() {
        self.sut = nil
        
        super.tearDown()
    }
    
    // MARK: - Tests
    func test_whenNotValid_throws() {
        // given
        let whenNotValidCases = self.givenWhenNotValid()
        
        // when
        for whenNotValidCase in whenNotValidCases {
            whenNotValidCase()
            
            // then
            XCTAssertThrowsError(try _addBracketsIfNeeded(subInfix: sut, otherOperator: .multiply))
        }
    }
    
    func test_whenValid_doesntThrow() {
        // given
        let whenValidCases = self.givenWhenValid()
        for whenValidCase in whenValidCases {
            whenValidCase()
            // then
            XCTAssertNoThrow(try _addBracketsIfNeeded(subInfix: sut, otherOperator: .multiply))
        }
    
    }
    
    func test_whenOneOperandSubInfix_doesntAddBrackets() {
        // when
        whenExpressionSingleTokenIsOperandAndNilMainOperator()
        // guaranted by test_addBrackets_whenValid_doesntThrows()
        let result = try! _addBracketsIfNeeded(subInfix: sut, otherOperator: .add)
        
        // then
        XCTAssertEqual(sut.expression, result.expression)
    }
    
    func test_whenSubInfixMainOperatorHigherPriorityThanOther_doesntAddBrackets() {
        // when
        whenExpressionValidInfixAndMainOperatorMultiply()
        // guaranted by test_addBrackets_whenValid_doesntThrows()
        let result = try! _addBracketsIfNeeded(subInfix: sut, otherOperator: .add)
        
        // then
        XCTAssertEqual(sut.expression, result.expression)
    }
    
    func test_whenSubInfixMainOperatorLowerPriorityThanOther_addBrackets() {
        // when
        whenExpressionValidInfixAndMainOperatorAdd()
        let expectedResult = [.openingBracket] + sut.expression + [.closingBracket]
        // guaranted by test_addBrackets_whenValid_doesntThrows()
        let result = try! _addBracketsIfNeeded(subInfix: sut, otherOperator: .multiply)
        
        // then
        XCTAssertEqual(result.expression, expectedResult)
    }
    
    static var allTests = [
        ("test_whenNotValid_throws", test_whenNotValid_throws),
        ("test_whenValid_doesntThrow", test_whenValid_doesntThrow),
        ("test_whenOneOperandSubInfix_doesntAddBrackets", test_whenOneOperandSubInfix_doesntAddBrackets),
        ("test_whenSubInfixMainOperatorHigherPriorityThanOther_doesntAddBrackets", test_whenSubInfixMainOperatorHigherPriorityThanOther_doesntAddBrackets),
        ("test_whenSubInfixMainOperatorLowerPriorityThanOther_addBrackets", test_whenSubInfixMainOperatorLowerPriorityThanOther_addBrackets),
        
    ]
}
