//
//  BinaryOperatorProtocolTests.swift
//  
//
//  Created by Valeriano Della Longa on 06/02/2020.
//

import XCTest
@testable import PostfixExpressionBuilder

final class BinaryOperatorProtocolTests: XCTestCase {
    // MARK: - Properties
    var sut: MockBinaryOperator!
    
    // MARK: - Tests lifecycle
    override func setUp() {
        super.setUp()
        
    }
    
    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }
    
    // MARK: - Tests
    func test_associatedType() {
        XCTAssertTrue(MockBinaryOperator.Operand.self == Int.self)
    }
    
    func test_binaryOperation() {
        // given
        for aCase in MockBinaryOperator.allCases {
            // when
            sut = aCase
            // then
            XCTAssertNotNil(sut.binaryOperation)
        }
    }
    
    func test_priority() {
        // given
        for aCase in MockBinaryOperator.allCases {
            // when
            sut = aCase
            // then
            XCTAssertNotNil(sut.priority)
        }
    }
    
    func test_associativity() {
        // given
        for aCase in MockBinaryOperator.allCases {
            // when
            sut = aCase
            // then
            XCTAssertNotNil(sut.associativity)
        }
    }
    
    func test_hasPrecedenceInPostfixConversionThen_whenOtherAssociativityIsLeft() {
        // given
        for aCase in MockBinaryOperator.allCases {
            sut = aCase
            // when
            let others = MockBinaryOperator.allCases.filter { ($0 != .add && $0.associativity == .left) }
            for other in others {
                let result = sut.hasPrecedenceInPostfixConversion(then: other)
                // then
                XCTAssertEqual(result, (other.priority <= sut.priority))
            }
        }
        
    }
    
    func test_hasPrecedenceInPostfixConversionThen_whenOtherAssociativityIsRight() {
        // given
        for aCase in MockBinaryOperator.allCases {
            sut = aCase
            // when
            let others = MockBinaryOperator.allCases.filter { ($0 != .add && $0.associativity == .right) }
            for other in others {
                let result = sut.hasPrecedenceInPostfixConversion(then: other)
                // then
                XCTAssertEqual(result, (other.priority < sut.priority))
            }
        }
    }
    
    static var allTests = [
        ("test_associatedType", test_associatedType),
        ("test_binaryOperation", test_binaryOperation),
        ("test_priority", test_priority),
        ("test_associativity", test_associativity),
        ("test_hasPrecedenceInPostfixConversionThen_whenOtherAssociativityIsLeft", test_hasPrecedenceInPostfixConversionThen_whenOtherAssociativityIsLeft),
        ("test_hasPrecedenceInPostfixConversionThen_whenOtherAssociativityIsRight", test_hasPrecedenceInPostfixConversionThen_whenOtherAssociativityIsRight),
        
    ]
}
