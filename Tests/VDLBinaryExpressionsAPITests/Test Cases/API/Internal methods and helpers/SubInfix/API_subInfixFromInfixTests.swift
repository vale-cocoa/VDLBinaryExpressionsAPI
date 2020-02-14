//
//  VDLBinaryExpressionsAPI
//  API_subInfixFromInfixTests.swift
//  
//
//  Created by Valeriano Della Longa on 13/02/2020.
//  Copyright (c) 2020 Valeriano Della Longa
//

import XCTest
@testable import VDLBinaryExpressionsAPI

final class API_subInfixFromInfixTests: XCTestCase {
    typealias SubInfix = _SubInfixExpression<MockBinaryOperator>
    typealias Token = BinaryOperatorExpressionToken<MockBinaryOperator>
    
    // MARK: - Properties
    var sut: [Token]!
    var _validPostfix: [Token]? { return sut.validPostfix() }
    var result: SubInfix!
    var expectedResult: SubInfix!
    
    
    // MARK: Test lifecycle
    override func setUp() {
        super.setUp()
        
    }
    
    override func tearDown() {
        self.sut = nil
        self.result = nil
        self.expectedResult = nil
        
        super.tearDown()
    }
    
    // MARK: - Given
    func givenEmptyExpression() {
        sut = []
    }
    
    func givenInvalidExpression() {
        sut = [.binaryOperator(.add), .operand(10), .operand(30), .closingBracket]
    }
    
    func givenValidJustOperand() {
        sut = [.operand(10)]
    }
    
    func givenValidJustOperandInBrakets() {
        sut = [.openingBracket, .operand(10), .closingBracket]
        expectedResult = ([.operand(10)], nil)
    }
    
    func givenValidPostfixTwoOperandsThenAdd() {
        sut = [.operand(10), .operand(20), .binaryOperator(.add)]
    }
    
    func givenValidInfixWithJustOneOperation() {
        sut = [.operand(10), .binaryOperator(.add), .operand(20)]
        expectedResult = (sut, .add)
    }
        
    private func givenValidInfixExpressionsWithMoreOperationsPerExpectedResults() -> [([Token], SubInfix)]
    {
        // 10 + 20 * 30
        let first: [Token] = [.operand(10), .binaryOperator(.add), .operand(20), .binaryOperator(.multiply), .operand(30)]
        
        // (10 + 20) * 30
        let second: [Token] = [.openingBracket, .operand(10), .binaryOperator(.add), .operand(20), .closingBracket, .binaryOperator(.multiply), .operand(30)]
        
        // (10 + 20) * (30 + 40)
        let third: [Token] = [.openingBracket, .operand(10), .binaryOperator(.add), .operand(20), .closingBracket, .binaryOperator(.multiply), .openingBracket, .operand(30), .binaryOperator(.add), .operand(40), .closingBracket]
        
        return [
            (first, (first, .add)),
            (second, (second, .multiply) ),
            (third, (third, .multiply)),
            
        ]
    }
    
    // MARK: - When
    func whenEmptyExpression() {
        givenEmptyExpression()
        // guaranted by test_whenEmptyExpression_doesntThrow()
        result = try! _subInfix(fromInfix: sut)
    }
    
    func whenValidPostfixReturnsNil() {
        givenInvalidExpression()
    }
    
    func whenValidJustOperandInBrackets() {
        givenValidJustOperandInBrakets()
        
        // guaranted by test_justOperandInBrackets_doesntThrow()
        result = try! _subInfix(fromInfix: sut)
    }
    
    func whenValidPostfixReturnsValueJustOperand() {
        givenValidJustOperand()
        // guaranted by test_whenValidPostfixReturnsValue_doesntThrow()
        result = try! _subInfix(fromInfix: sut)
    }
    
    func whenValidInfixWithJustOneOperation() {
        givenValidInfixWithJustOneOperation()
        
        // guaranted by test_whenValidInfix_doesntThrow()
        result = try! _subInfix(fromInfix: sut)
    }
    
    private func whenValidInfixExpressionsGroup(given: [([Token], SubInfix)]) -> [() -> Void] {
        var result: [() -> Void] = []
        for values in given {
            result.append {
                self.sut = values.0
                self.expectedResult = values.1
                // guaranted by test_whenValidInfix_doesntThrow()
                self.result = try! _subInfix(fromInfix: self.sut)
            }
        }
        
        return result
    }
    
    // MARK: - Tests
    func test_whenEmptyExpression_doesntThrow() {
        // when
        whenEmptyExpression()
        
        // then
        XCTAssertNoThrow(try _subInfix(fromInfix: sut))
    }
    
    func test_whenEmpty_returnsEmptyExpressionAndNilMainOperator() {
        // when
        whenEmptyExpression()
        
        // then
        XCTAssertTrue(result.expression.isEmpty)
        XCTAssertNil(result.mainOperator)
    }
    
    func test_whenValidPostfixReturnsNil_throws() {
        // when
        whenValidPostfixReturnsNil()
        
        // then
        XCTAssertNil(_validPostfix)
        XCTAssertThrowsError(try _subInfix(fromInfix: sut))
    }
    
    func test_whenValidPostfixReturnsValueJustOperand_doesntThrow() {
        // when
        whenValidPostfixReturnsValueJustOperand()
        
        // then
        XCTAssertNoThrow(try _subInfix(fromInfix: sut))
    }
    
    func test_whenJustOperand_returnsOperandAsExpressionAndNilAsMainOperator() {
        // when
        whenValidPostfixReturnsValueJustOperand()
        
        // then
        XCTAssertEqual(result.expression, sut)
        XCTAssertNil(result.mainOperator)
    }
    
    func test_justOperandInBrackets_doesntThrow() {
        // given
        givenValidJustOperandInBrakets()
        
        // then
        XCTAssertNoThrow(try _subInfix(fromInfix: sut))
    }
    
    func test_justOperandInBrackets_returnsOnlyOperandInExpressionAndNilAsMainOperator() {
        // when
        whenValidJustOperandInBrackets()
        
        // then
        XCTAssertEqual(result.expression, expectedResult.expression)
        XCTAssertNil(result.mainOperator)
    }
    
    func test_whenValidPostfixExpression_throws() {
        // given
        givenValidPostfixTwoOperandsThenAdd()
        
        // when
        // then
        XCTAssertThrowsError(try _subInfix(fromInfix: sut))
    }
    
    func test_whenValidInfix_doesntThrow() {
        // given
        givenValidInfixWithJustOneOperation()
        
        // when
        // then
        XCTAssertNoThrow(try _subInfix(fromInfix: sut))
    }
    
    func test_whenValidInfix_returnsSameExpressionAndMainOperatorNotNil() {
        // when
        whenValidInfixWithJustOneOperation()
        
        // then
        XCTAssertEqual(result.expression, sut)
        XCTAssertNotNil(result.mainOperator)
    }
    
    func test_whenValidInfixWithJustOneOperation_returnsExpected() {
        // when
        whenValidInfixWithJustOneOperation()
        
        // then
        XCTAssertEqual(result.expression, expectedResult.expression)
        XCTAssertEqual(result.mainOperator, expectedResult.mainOperator)
    }
    
    func test_whenValidInfixWithMoreOperations_resturnsExpected() {
        // when
        let whenClosures = self.whenValidInfixExpressionsGroup(given: self.givenValidInfixExpressionsWithMoreOperationsPerExpectedResults())
        for when in whenClosures {
            when()
            // then
            XCTAssertEqual(result.expression, expectedResult.expression)
            XCTAssertEqual(result.mainOperator, expectedResult.mainOperator)
        }
    }
    
    static var allTests = [
        ("test_whenEmptyExpression_doesntThrow", test_whenEmptyExpression_doesntThrow),
        ("test_whenEmpty_returnsEmptyExpressionAndNilMainOperator", test_whenEmpty_returnsEmptyExpressionAndNilMainOperator),
        ("test_whenValidPostfixReturnsNil_throws", test_whenValidPostfixReturnsNil_throws),
        ("test_whenValidPostfixReturnsValueJustOperand_doesntThrow", test_whenValidPostfixReturnsValueJustOperand_doesntThrow),
     ("test_whenJustOperand_returnsOperandAsExpressionAndNilAsMainOperator", test_whenJustOperand_returnsOperandAsExpressionAndNilAsMainOperator),
     ("test_justOperandInBrackets_doesntThrow", test_justOperandInBrackets_doesntThrow),
     ("test_justOperandInBrackets_returnsOnlyOperandInExpressionAndNilAsMainOperator", test_justOperandInBrackets_returnsOnlyOperandInExpressionAndNilAsMainOperator),
     ("test_whenValidPostfixExpression_throws" ,test_whenValidPostfixExpression_throws),
     ("test_whenValidInfix_doesntThrow", test_whenValidInfix_doesntThrow),
     ("test_whenValidInfix_returnsSameExpressionAndMainOperatorNotNil", test_whenValidInfix_returnsSameExpressionAndMainOperatorNotNil),
     ("test_whenValidInfixWithJustOneOperation_returnsExpected", test_whenValidInfixWithJustOneOperation_returnsExpected),
     ("test_whenValidInfixWithMoreOperations_resturnsExpected", test_whenValidInfixWithMoreOperations_resturnsExpected),
     
    ]
}
