//
//  VDLBinaryExpressionsAPI
//  BinaryOperatorProtocolTests.swift
//  
//
//  Created by Valeriano Della Longa on 06/02/2020.
//  Copyright (c) 2020 Valeriano Della Longa
//

import XCTest
@testable import VDLBinaryExpressionsAPI

final class BinaryOperatorProtocolTests: XCTestCase {
    // MARK: - Properties
    var sut: MockDummyOperator!
    
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
        for aCase in MockDummyOperator.allCases {
            // when
            sut = aCase
            // then
            XCTAssertNotNil(sut.binaryOperation)
        }
    }
    
    func test_priority() {
        // given
        for aCase in MockDummyOperator.allCases {
            // when
            sut = aCase
            // then
            XCTAssertNotNil(sut.priority)
        }
    }
    
    func test_associativity() {
        // given
        for aCase in MockDummyOperator.allCases {
            // when
            sut = aCase
            // then
            XCTAssertNotNil(sut.associativity)
        }
    }
    
    func test_goesBeforeInPostfixConversionThan_whenOtherAssociativityIsLeft() {
        // given
        for aCase in MockDummyOperator.allCases {
            sut = aCase
            // when
            let others = MockDummyOperator.allCases.filter { ($0 != aCase && $0.associativity == .left) }
            for other in others {
                let result = sut.goesBeforeInPostfixConversion(than: other)
                // then
                XCTAssertEqual(result, (other.priority <= sut.priority))
            }
        }
        
    }
    
    func test_goesBeforeInPostfixConversionThan_whenOtherAssociativityIsRight() {
        // given
        for aCase in MockDummyOperator.allCases {
            sut = aCase
            // when
            let others = MockDummyOperator.allCases.filter { ($0 != aCase && $0.associativity == .right) }
            for other in others {
                let result = sut.goesBeforeInPostfixConversion(than: other)
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
        ("test_goesBeforeInPostfixConversionThan_whenOtherAssociativityIsLeft", test_goesBeforeInPostfixConversionThan_whenOtherAssociativityIsLeft),
        ("test_goesBeforeInPostfixConversionThan_whenOtherAssociativityIsRight", test_goesBeforeInPostfixConversionThan_whenOtherAssociativityIsRight),
        
    ]
}
