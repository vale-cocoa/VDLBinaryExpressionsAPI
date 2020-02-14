//
//  VDLBinaryExpressionsAPI
//  API_convertFromRPNToInfixTests.swift
//  
//
//  Created by Valeriano Della Longa on 06/02/2020.
//  Copyright (c) 2020 Valeriano Della Longa
//

import XCTest
@testable import VDLBinaryExpressionsAPI

final class API_convertFromRPNToInfixTests: XCTestCase {
    typealias Token = BinaryOperatorExpressionToken<MockBinaryOperator>
    
    // MARK: - Properties
    var sut: [Token]!
    
    // MARK: - Test lifecycle
    override func setUp() {
        super.setUp()
        
    }
    
    override func tearDown() {
        self.sut = nil
        
        super.tearDown()
    }
    
    // MARK: - Given
    
    // MARK: - When
    func whenEmpty() {
        sut = []
    }
    
    // MARK: - Tests
    func test_whenEmpty_doesntThrow() {
        // when
        whenEmpty()
        
        // then
        XCTAssertNoThrow(try _convertFromRPNToInfix(expression: sut))
    }
    
    func test_whenEmpty_returnsEmpty() {
        // when
        whenEmpty()
        // guaranted by test_whenEmpty_doesntThrow()
        let result = try! _convertFromRPNToInfix(expression: sut)
        
        // then
        XCTAssertTrue(result.isEmpty)
    }
    
    func test_whenOperationOnly_throws() {
        // when
        sut = [.binaryOperator(.add)]
        
        // then
        XCTAssertThrowsError(try _convertFromRPNToInfix(expression: sut))
    }
    
    func test_whenOperatorsOnly_throws() {
        // when
        sut = [.operand(10), .operand(20)]
        
        // then
        XCTAssertThrowsError(try _convertFromRPNToInfix(expression: sut))
    }
    
    func test_whenContainingBrackets_throws() {
        // when
        sut = [.openingBracket,.operand(10), .operand(20), .binaryOperator(.add), .closingBracket]
        
        // then
        XCTAssertThrowsError(try _convertFromRPNToInfix(expression: sut))
    }
    
    func test_whenOperandsOnly_throws() {
        // when
        sut = [.operand(10), .operand(20), .operand(30)]
        
        // then
        XCTAssertThrowsError(try _convertFromRPNToInfix(expression: sut))
    }
    
    func test_whenFoundOnlyOneOperandFromStack_throws() {
        // when
        sut = [.operand(10), .binaryOperator(.add)]
        
        // then
        XCTAssertThrowsError(try _convertFromRPNToInfix(expression: sut))
        
        // when
        // One operation passes (10 + 20), the last one shouldn't cause
        // there'll be only one operand in the stack
        // (the result of the previous operation)
        sut = [.operand(10), .operand(20), .binaryOperator(.add), .binaryOperator(.multiply)]
        
        // then
        XCTAssertThrowsError(try _convertFromRPNToInfix(expression: sut))
    }
    
    func test_whenOperandOperandOperator_doesntThrow() {
        // when
        sut = [.operand(10), .operand(20), .binaryOperator(.add)]
        
        // then
        XCTAssertNoThrow(try _convertFromRPNToInfix(expression: sut))
    }
    
    func test_whenSubValidAdditionThenOperandThenMultiplyOperator_doesntThrow() {
        // when
        sut = [.operand(10), .operand(20), .binaryOperator(.add), .operand(30), .binaryOperator(.multiply)]
        
        // then
        XCTAssertNoThrow(try _convertFromRPNToInfix(expression: sut))
    }
    
    func test_whenSubValidAdditionThenOperandThenMultiplyOperator_addsBracketsToSubValidAddition() {
        // given
        let expectedResult: [Token] = [.openingBracket, .operand(10), .binaryOperator(.add), .operand(20), .closingBracket, .binaryOperator(.multiply), .operand(30)]
        
        // when
        sut = [.operand(10), .operand(20), .binaryOperator(.add), .operand(30), .binaryOperator(.multiply)]
        // guaranted by test_whenSubValidAdditionThenOperandThenMultiplyOperator_doesntThrow()
        let result = try! _convertFromRPNToInfix(expression: sut)
        
        // then
        XCTAssertEqual(result, expectedResult)
    }
    
    func test_whenThreeOperandsThenMultiplyOperatorThenAddOperator_doesntThrow() {
        // when
        sut = [.operand(10), .operand(20), .operand(30), .binaryOperator(.multiply), .binaryOperator(.add)]
        
        // then
        XCTAssertNoThrow(try _convertFromRPNToInfix(expression: sut))
    }
    
    func test_whenThreeOperandsThenMultiplyOperatorThenAddOperator_doesntAddBrackets() {
        // given
        let expectedResult: [Token] = [.operand(10), .binaryOperator(.add), .operand(20), .binaryOperator(.multiply), .operand(30)]
        
        // when
        sut = [.operand(10), .operand(20), .operand(30), .binaryOperator(.multiply), .binaryOperator(.add)]
        // guaranted by test_whenThreeOperandsThenMultiplyOperatorThenAddOperator_doesntThrow()
        let result = try! _convertFromRPNToInfix(expression: sut)
        
        // then
        XCTAssertEqual(result, expectedResult)
    }
    
    static var allTests = [
        ("test_whenEmpty_doesntThrow", test_whenEmpty_doesntThrow),
        ("test_whenEmpty_returnsEmpty", test_whenEmpty_returnsEmpty),
        ("test_whenOperationOnly_throws", test_whenOperationOnly_throws),
        ("test_whenOperatorsOnly_throws", test_whenOperatorsOnly_throws),
        ("test_whenContainingBrackets_throws", test_whenContainingBrackets_throws),
        ("test_whenContainingBrackets_throws", test_whenContainingBrackets_throws),
        ("test_whenOperandsOnly_throws", test_whenOperandsOnly_throws),
        ("test_whenFoundOnlyOneOperandFromStack_throws", test_whenFoundOnlyOneOperandFromStack_throws),
        ("test_whenOperandOperandOperator_doesntThrow", test_whenOperandOperandOperator_doesntThrow),
        ("test_whenSubValidAdditionThenOperandThenMultiplyOperator_doesntThrow",  test_whenSubValidAdditionThenOperandThenMultiplyOperator_doesntThrow),
        ("test_whenSubValidAdditionThenOperandThenMultiplyOperator_addsBracketsToSubValidAddition", test_whenSubValidAdditionThenOperandThenMultiplyOperator_addsBracketsToSubValidAddition),
        ("test_whenThreeOperandsThenMultiplyOperatorThenAddOperator_doesntThrow", test_whenThreeOperandsThenMultiplyOperatorThenAddOperator_doesntThrow),
        ("test_whenThreeOperandsThenMultiplyOperatorThenAddOperator_doesntAddBrackets", test_whenThreeOperandsThenMultiplyOperatorThenAddOperator_doesntAddBrackets),
        
    ]
}
