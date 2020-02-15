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
    
    // MARK: - Test lifecycle
    override func setUp() {
        super.setUp()
     
        sut = _Sut()
    }
    
    override func tearDown() {
        sut = nil
        
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
    
    // MARK: - When
    
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
    
    static var allTests = [
        ("test_whenValidInfixReturnsNil_throws", test_whenValidInfixReturnsNil_throws),
        ("test_whenSubinfixFromInfixReturnsEmpty_throws", test_whenSubinfixFromInfixReturnsEmpty_throws),
        ("test_whenSubInfixLhsByRhsDoesntThrow_doesntThrow", test_whenSubInfixLhsByRhsDoesntThrow_doesntThrow),
        ("test_returnedValue_isValidInfix", test_returnedValue_isValidInfix),
        ("test_whenTwoOperandsAsLhsAndRhs_returnedValueIsExpectedResult", test_whenTwoOperandsAsLhsAndRhs_returnedValueIsExpectedResult),
        
    ]
}
