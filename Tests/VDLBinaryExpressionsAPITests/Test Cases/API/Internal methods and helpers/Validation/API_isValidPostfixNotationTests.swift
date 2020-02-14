//
//  VDLBinaryExpressionsAPI
//  API_isValidPostfixNotationTests.swift
//  
//
//  Created by Valeriano Della Longa on 06/02/2020.
//  Copyright (c) 2020 Valeriano Della Longa
//

import XCTest
@testable import VDLBinaryExpressionsAPI

final class API_isValidPostfixNotationTests: XCTestCase {
    typealias Token = BinaryOperatorExpressionToken<MockBinaryOperator>
    
    // MARK: - Properties
    var sut: [Token]!
    var _evalDidThrow: Bool!
    
    // MARK: - Test lifecycle
    override func setUp() {
        super.setUp()
        
    }
    
    override func tearDown() {
        self.sut = nil
        self._evalDidThrow = nil
        
        super.tearDown()
    }
    
    // MARK: - Given
    func givenValidPostfixExpression() {
        sut = [.operand(10), .operand(20), .binaryOperator(.add)]
    }
    
    func givenNotValidPostfixExpression() {
        sut = [.operand(10), .binaryOperator(.add)]
    }
    
    // MARK: - When
    func whenEvalDidntThrow() {
        givenValidPostfixExpression()
        set_evalDidThrow()
    }
    
    func whenEvalDidThrow() {
        givenNotValidPostfixExpression()
        set_evalDidThrow()
    }
    
    func set_evalDidThrow() {
        do {
            let _ = try _eval(postfix: sut)
            _evalDidThrow = true
        } catch {
            _evalDidThrow = false
        }
    }
    
    // MARK: - Tests
    func test_whenEvalDoesntThrow_returnsTrue() {
        // when
        whenEvalDidntThrow()
        
        // then
        XCTAssertTrue(_isValidPostfixNotation(expression: sut))
    }
    
    func test_whenEvalThrows_returnsFalse() {
        // when
        whenEvalDidThrow()
        
        // then
        XCTAssertFalse(_isValidPostfixNotation(expression: sut))
    }
    
    static var allTests = [
        ("test_whenEvalDoesntThrow_returnsTrue", test_whenEvalDoesntThrow_returnsTrue),
        ("test_whenEvalThrows_returnsFalse", test_whenEvalThrows_returnsFalse),
        
    ]
    
}
