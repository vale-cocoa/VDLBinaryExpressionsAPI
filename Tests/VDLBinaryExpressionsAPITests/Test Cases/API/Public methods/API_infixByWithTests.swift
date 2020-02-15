//
//  VDLBinaryExpressionsAPI
//  API_infixByWithTests.swift
//  
//
//  Created by Valeriano Della Longa on 15/02/2020.
//  Copyright (c) 2020 Valeriano Della Longa
//

import XCTest
@testable import VDLBinaryExpressionsAPI

final class API_infixByWithTests: XCTestCase {
    typealias SubInfix = _SubInfixExpression<MockBinaryOperator>
    typealias Token = BinaryOperatorExpressionToken<MockBinaryOperator>
    
    struct _Sut {
        var lhs: [Token] = []
        var rhs: [Token] = []
        var operation: MockBinaryOperator = .failingOperation
    }
    
    // MARK: - Properties
    var sut: _Sut!
    
    var expectedResult: [Token]!
    
    var _validInfixReturnedValues: (lhs: [Token]?, rhs: [Token]?) {
        (self.sut.lhs.validInfix(), self.sut.rhs.validInfix())
    }
    
    var _subInfixFromInfixReturnedValues: (lhs: SubInfix, rhs: SubInfix)? {
        guard
            let lhs = self._validInfixReturnedValues.lhs,
            let rhs = self._validInfixReturnedValues.rhs,
            let sLhs = try? _subInfix(fromInfix: lhs),
            let sRhs = try? _subInfix(fromInfix: rhs)
            else { return nil }
        
        return (sLhs, sRhs)
    }
    
    var _subInfixLhsByRhsReturnedValue: SubInfix? {
        guard
            let lhs = _subInfixFromInfixReturnedValues?.lhs,
            let rhs = _subInfixFromInfixReturnedValues?.rhs
            else { return nil }
        
        return try? _subInfix(lhs: lhs, by: self.sut.operation, rhs: rhs)
    }
    
    let _bracketsCriteriaClosure: (MockBinaryOperator?, MockBinaryOperator, MockBinaryOperator?) -> (Bool, Bool) = { lhsOp, op, rhsOp in
        var putBracketsOnLhsExpression = false
        var putBracketsOnRhsExpression = false
        switch (lhsOp?.associativity, op.associativity, rhsOp?.associativity) {
        case (nil, _, nil):
            // two operands, any operation associativity
            break
        
        case (nil, .left, .some(_)):
            // - lhs is operand,
            // - combinig operator is left associative,
            // - rhs is expression whose main operator has any associativity
            putBracketsOnRhsExpression = op.priority > rhsOp!.priority
        
        case (nil, .right, .some(_)):
            // - lhs is operand,
            // - combinig operator is right associative,
            // - rhs is expression whose main operator has any associativity
            putBracketsOnRhsExpression = op.priority >= rhsOp!.priority
            
        case(.some(_), _, nil):
            // - lhs is expression whose main operator has any associativity,
            // - combinig operator has any associativity,
            // - rhs is operand
            putBracketsOnLhsExpression = op.priority > lhsOp!.priority
        
        case (.some(_), .left, .some(_)):
            // - lhs is expression whose main operator has any associativity,
            // - combinig operator is left associative,
            // - rhs is expression whose main operator has any associativity
            putBracketsOnLhsExpression = op.priority > lhsOp!.priority
            putBracketsOnRhsExpression = op.priority > rhsOp!.priority
            
        case (.some(_), .right, .some(_)):
            // - lhs is expression whose main operator has any associativity,
            // - combinig operator is right associative,
            // - rhs is expression whose main operator has any associativity
            putBracketsOnLhsExpression = op.priority > lhsOp!.priority
            putBracketsOnRhsExpression = op.priority >= rhsOp!.priority
        }
        
        return (putBracketsOnLhsExpression, putBracketsOnRhsExpression)
    }
    
    // MARK: - Test lifecycle
    override func setUp() {
        super.setUp()
     
        sut = _Sut()
        expectedResult = []
    }
    
    override func tearDown() {
        sut = nil
        expectedResult = nil
        
        super.tearDown()
    }
    
    // MARK: - Given
    func givenEmpty() -> [Token] {
        []
    }
    
    func givenNotValidExpression() -> [Token] {
        givenValidPostfixExpression() + [.openingBracket]
    }
    
    func givenValidPostfixExpression() -> [Token] {
        [.operand(10), .operand(20), .binaryOperator(.add)]
    }
    
    func givenValidOperandExpression() -> [Token] {
        [.operand(Int.random(in: 1...100))]
    }
    
    func givenValidBinaryAdditionExpressionInfix() -> [Token] {
        let lhs: Token = .operand(Int.random(in: 1...100))
        let rhs: Token = .operand(Int.random(in: 1...100))
        return [lhs, .binaryOperator(.add), rhs]
    }
    
    func givenValidBinaryMultiplicationExpressionInfix() -> [Token] {
        let lhs: Token = .operand(Int.random(in: 1...100))
        let rhs: Token = .operand(Int.random(in: 1...100))
        return [lhs, .binaryOperator(.multiply), rhs]
    }
    
    func givenValidBinarySubtractionExpressionInfix() -> [Token] {
        let lhs = Int.random(in: 1...100)
        let rhs = Int.random(in: 0..<lhs)
        return [.operand(lhs), .binaryOperator(.subtract), .operand(rhs)]
    }
    
    func givenValidBinaryDivisionExpressionInfix() -> [Token] {
        let lhs = Int.random(in: 1...100)
        let rhs = Int.random(in: 1...lhs)
        return [.operand(lhs), .binaryOperator(.divide), .operand(rhs)]
    }
    
    func givenValidFailingOperationExpressionInfix() -> [Token] {
        let lhs = Int.random(in: 1...100)
        let rhs = Int.random(in: 1...100)
        return [.operand(lhs), .binaryOperator(.failingOperation), .operand(rhs)]
    }
    
    func givenInBrackets(_ other: @escaping () -> [Token]) -> [Token] {
        let expression = other()
        let bracketed = _putBrackets(on: expression)
        
        return bracketed
    }
    
    func givenAllValidBaseBinaryExpressionsInfix() -> [[Token]] {
        
        return [
            givenValidOperandExpression(),
            givenValidBinaryAdditionExpressionInfix(),
            givenValidBinaryMultiplicationExpressionInfix(),
            givenValidBinarySubtractionExpressionInfix(),
            givenValidBinaryDivisionExpressionInfix(),
            givenValidFailingOperationExpressionInfix()
        ]
    }
    
    // MARK: - When
    func whenLhsValidBinaryBaseExpressionInfixEveryOperatorRhsValidBinaryBaseExpressionInfix() -> [() -> Void] {
        var closures = [() -> Void]()
        
        let lhsValues = givenAllValidBaseBinaryExpressionsInfix().shuffled()
        let rhsValues = givenAllValidBaseBinaryExpressionsInfix().shuffled()
        for anOp in MockBinaryOperator.allCases {
            for lhs in lhsValues {
                for rhs in rhsValues {
                    closures.append {
                        self.sut = _Sut(lhs: lhs, rhs: rhs, operation: anOp)
                        
                        let lhsOp = try? _subInfix(fromInfix: lhs).mainOperator
                        let rhsOp = try? _subInfix(fromInfix: rhs).mainOperator
                        let bracketing: (lhs: Bool, rhs: Bool) = self._bracketsCriteriaClosure(lhsOp, anOp, rhsOp)
                        
                        self.expectedResult = self._expectedValidResultFromActualSUT(putBracketsOnLhs: bracketing.lhs, putBracketsOnRhs: bracketing.rhs)
                    }
                
                }
            }
        }
        
        return closures
    }
    
    // MARK: - When Helpers
    private func _expectedValidResultFromActualSUT(putBracketsOnLhs: Bool = false, putBracketsOnRhs: Bool = false) -> [Token] {
        let lhsExpr = putBracketsOnLhs ? _putBrackets(on: sut.lhs) : sut.lhs
        let rhsExpr = putBracketsOnRhs ? _putBrackets(on: sut.rhs) : sut.rhs
        
        return lhsExpr + [.binaryOperator(sut.operation)] + rhsExpr
    }
    
    private func _putBrackets(on infixExpression: [Token])
        -> [Token]
    {
        
        return [.openingBracket] + infixExpression + [.closingBracket]
    }
    
    // MARK: - Tests
    func test_whenValidInfixReturnsNil_throws() {
        // when
        sut.lhs = givenNotValidExpression()
        sut.rhs = givenValidOperandExpression()
        sut.operation = .add
        
        // then
        XCTAssertNil(_subInfixFromInfixReturnedValues)
        XCTAssertThrowsError(try sut.lhs.infix(by: sut.operation, with: sut.rhs))
        
        // when
        sut.rhs = givenNotValidExpression()
        sut.lhs = givenValidOperandExpression()
        sut.operation = .add
        
        // then
        XCTAssertNil(_subInfixFromInfixReturnedValues)
        XCTAssertThrowsError(try sut.lhs.infix(by: sut.operation, with: sut.rhs))
    }
    
    func test_whenSubinfixFromInfixReturnsEmpty_throws() {
        // when
        sut.lhs = givenEmpty()
        sut.rhs = givenValidOperandExpression()
        sut.operation = .add
        
        // then
        XCTAssertNotNil(_subInfixFromInfixReturnedValues)
        XCTAssertThrowsError(try sut.lhs.infix(by: sut.operation, with: sut.rhs))
        
        // when
        sut.rhs = givenEmpty()
        sut.lhs = givenValidOperandExpression()
        sut.operation = .add
        
        // then
        XCTAssertNotNil(_subInfixFromInfixReturnedValues)
        XCTAssertThrowsError(try sut.lhs.infix(by: sut.operation, with: sut.rhs))
    }
    
    func test_whenSubInfixLhsByRhsDoesntThrow_doesntThrow() {
        // when
        sut.lhs = givenValidOperandExpression()
        sut.rhs = givenValidOperandExpression()
        sut.operation = .add
        
        // then
        XCTAssertNotNil(_subInfixLhsByRhsReturnedValue)
        XCTAssertNoThrow(try sut.lhs.infix(by: sut.operation, with: sut.rhs))
    }
    
    func test_returnedValue_isValidInfix() {
        // when
        sut.lhs = givenValidOperandExpression()
        sut.rhs = givenValidOperandExpression()
        sut.operation = .add
        // guaranted by test_whenSubInfixLhsByRhsDoesntThrow_doesntThrow()
        let result = try! sut.lhs.infix(by: sut.operation, with: sut.rhs)
        
        // then
        XCTAssertTrue(_isValidInfixNotation(expression: result))
    }
    
    func test_whenTwoOperandsAsLhsAndRhs_returnedValueIsExpectedResult() {
        // given
        let lhs = givenValidOperandExpression()
        let rhs = givenValidOperandExpression()
        for anOp in MockBinaryOperator.allCases {
            let expectedResult: [Token] = lhs + [.binaryOperator(anOp)] + rhs
            // when
            sut.lhs = lhs
            sut.rhs = rhs
            sut.operation = anOp
            let result = try! sut.lhs.infix(by: sut.operation, with: sut.rhs)
            
            // then
            XCTAssertEqual(result, expectedResult)
        }
    }
    
    func test_whenLhsValidBinaryBaseExpressionInfixEveryOperatorRhsValidBinaryBaseExpressionInfix_returnsExpectedResult() {
        // given
        let whenClosures = whenLhsValidBinaryBaseExpressionInfixEveryOperatorRhsValidBinaryBaseExpressionInfix()
        for when in whenClosures {
            // when
            when()
            let result = try! sut.lhs.infix(by: sut.operation, with: sut.rhs)
            // then
            XCTAssertEqual(result, expectedResult)
        }
    }
    
    func test_whenAlreadyBracketedAndShouldPutBrackets_doesntPutBrackets() {
        // given
        let bracketedAddition = givenInBrackets(givenValidBinaryAdditionExpressionInfix)
        sut = _Sut(lhs: bracketedAddition, rhs: givenValidOperandExpression(), operation: .multiply)
        expectedResult = _expectedValidResultFromActualSUT(putBracketsOnLhs: false)
        
        // when
        let result = try! sut.lhs.infix(by: sut.operation, with: sut.rhs)
        
        // then
        XCTAssertEqual(result, expectedResult)
    }
    
    func test_whenExpressionContainsBracketedExpressionAndShouldBracket_doesPutBrackets() {
        // given
        // lhs = E + F
        // rhs = (A + B) * (C + D)
        // expectedResult = (E + F) / ((A + B) * (C + D))
        let rhs = try! givenValidBinaryAdditionExpressionInfix().infix(by: .multiply, with: givenValidBinaryAdditionExpressionInfix())
        sut = _Sut(lhs: givenValidBinaryAdditionExpressionInfix(), rhs: rhs, operation: .divide)
        expectedResult = _expectedValidResultFromActualSUT(putBracketsOnLhs: true, putBracketsOnRhs: true)
        
        // when
        let result = try! sut.lhs.infix(by: sut.operation, with: sut.rhs)
        
        // then
        XCTAssertEqual(result, expectedResult)
    }
    
    static var allTests = [
        ("test_whenValidInfixReturnsNil_throws", test_whenValidInfixReturnsNil_throws),
        ("test_whenSubinfixFromInfixReturnsEmpty_throws", test_whenSubinfixFromInfixReturnsEmpty_throws),
        ("test_whenSubInfixLhsByRhsDoesntThrow_doesntThrow", test_whenSubInfixLhsByRhsDoesntThrow_doesntThrow),
        ("test_returnedValue_isValidInfix", test_returnedValue_isValidInfix),
        ("test_whenTwoOperandsAsLhsAndRhs_returnedValueIsExpectedResult", test_whenTwoOperandsAsLhsAndRhs_returnedValueIsExpectedResult),
        ("test_whenLhsValidBinaryBaseExpressionInfixEveryOperatorRhsValidBinaryBaseExpressionInfix_returnsExpectedResult", test_whenLhsValidBinaryBaseExpressionInfixEveryOperatorRhsValidBinaryBaseExpressionInfix_returnsExpectedResult),
        ("test_whenAlreadyBracketedAndShouldPutBrackets_doesntPutBrackets", test_whenAlreadyBracketedAndShouldPutBrackets_doesntPutBrackets),
        ("test_whenExpressionContainsBracketedExpressionAndShouldBracket_doesPutBrackets", test_whenExpressionContainsBracketedExpressionAndShouldBracket_doesPutBrackets),
        
    ]
}
