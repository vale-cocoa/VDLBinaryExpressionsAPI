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
    
    static var allTests = [
        ("test_whenEmpty_doesntThrow", test_whenEmpty_doesntThrow),
        ("test_whenEmpty_returnsEmpty", test_whenEmpty_returnsEmpty),
        ("test_whenOperationOnly_throws", test_whenOperationOnly_throws),
        ("test_whenOperatorsOnly_throws", test_whenOperatorsOnly_throws),
        ("test_whenContainingBrackets_throws", test_whenContainingBrackets_throws),
        ("test_whenContainingBrackets_throws", test_whenContainingBrackets_throws),
        
    ]
}
