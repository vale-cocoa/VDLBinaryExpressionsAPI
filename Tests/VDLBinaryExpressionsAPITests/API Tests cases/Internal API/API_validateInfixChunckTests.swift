//
//  API_validateInfixChunckTests.swift
//  
//
//  Created by Valeriano Della Longa on 08/02/2020.
//

import XCTest
@testable import PostfixExpressionBuilder

final class API_validateInfixChunckTests: XCTestCase {
    typealias Token = BinaryOperatorExpressionToken<MockBinaryOperator>
    
    // MARK: - Properties
    var sut: (prev: Token?, current: Token)!
    
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
    
    // MARK: - Tests
    func test_whenPrevIsNil_DoesntThrow() {
        // when
        sut = (nil, .operand(10))
        
        // then
        XCTAssertNoThrow(try _validate(infixChunk: sut))
        
        // when
        sut = (nil, .binaryOperator(.add))
        
        // then
        XCTAssertNoThrow(try _validate(infixChunk: sut))
        
        // when
        sut = (nil, .openingBracket)
        
        // then
        XCTAssertNoThrow(try _validate(infixChunk: sut))
        
        // when
        sut = (nil, .closingBracket)
        
        // then
        XCTAssertNoThrow(try _validate(infixChunk: sut))
    }
    
    func test_whenPrevIsOpeningBracketAndCurrentIsAllOtherCases() {
        // when
        sut = (.openingBracket, .openingBracket)
        
        // then
        XCTAssertNoThrow(try _validate(infixChunk: sut))
        
        // when
        sut = (.openingBracket, .operand(10))
        
        // then
        XCTAssertNoThrow(try _validate(infixChunk: sut))
        
        // when
        sut = (.openingBracket, .binaryOperator(.add))
        
        // then
        XCTAssertThrowsError(try _validate(infixChunk: sut))
        
        // when
        sut = (.openingBracket, .closingBracket)
        
        // then
        XCTAssertThrowsError(try _validate(infixChunk: sut))
    }
    
    func test_whenPrevIsOperandAndCurrentIsAllOtherCases() {
        // when
        sut = (.operand(10), .closingBracket)
        
        // then
        XCTAssertNoThrow(try _validate(infixChunk: sut))
        
        // when
        sut = (.operand(10), .binaryOperator(.add))
        
        // then
        XCTAssertNoThrow(try _validate(infixChunk: sut))
        
        // when
        sut = (.operand(10), .openingBracket)
        
        // then
        XCTAssertThrowsError(try _validate(infixChunk: sut))
        
        // when
        sut = (.operand(10), .operand(20))
        
        // then
        XCTAssertThrowsError(try _validate(infixChunk: sut))
    }
    
    func test_whenPrevIsBinaryOperatorAndCurrentIsAllOtherCases() {
        // when
        sut = (.binaryOperator(.add), .operand(10))
        
        // then
        XCTAssertNoThrow(try _validate(infixChunk: sut))
        
        // when
        sut = (.binaryOperator(.add), .openingBracket)
        
        // then
        XCTAssertNoThrow(try _validate(infixChunk: sut))
        
        // when
        sut = (.binaryOperator(.add), .closingBracket)
        
        // then
        XCTAssertThrowsError(try _validate(infixChunk: sut))
        
        // when
        sut = (.binaryOperator(.add), .binaryOperator(.multiply))
        
        // then
        XCTAssertThrowsError(try _validate(infixChunk: sut))
    }
    
    func test_whenPrevIsClosingBracketAndCurrentIsAllOtherCases() {
        // when
        sut = (.closingBracket, .closingBracket)
        
        // then
        XCTAssertNoThrow(try _validate(infixChunk: sut))
        
        // when
        sut = (.closingBracket, .binaryOperator(.add))
        
        // then
        XCTAssertNoThrow(try _validate(infixChunk: sut))
        
        // when
        sut = (.closingBracket, .openingBracket)
        
        // then
        XCTAssertThrowsError(try _validate(infixChunk: sut))
        
        // when
        sut = (.closingBracket, .operand(10))
        
        // then
        XCTAssertThrowsError(try _validate(infixChunk: sut))
    }
    
    static var allTests = [
        ("test_whenPrevIsNil_DoesntThrow", test_whenPrevIsNil_DoesntThrow),
        ("test_whenPrevIsOpeningBracketAndCurrentIsAllOtherCases", test_whenPrevIsOpeningBracketAndCurrentIsAllOtherCases),
        ("test_whenPrevIsOperandAndCurrentIsAllOtherCases", test_whenPrevIsOperandAndCurrentIsAllOtherCases),
        ("test_whenPrevIsBinaryOperatorAndCurrentIsAllOtherCases", test_whenPrevIsBinaryOperatorAndCurrentIsAllOtherCases),
        ("test_whenPrevIsClosingBracketAndCurrentIsAllOtherCases", test_whenPrevIsClosingBracketAndCurrentIsAllOtherCases),
        
    ]
    
}
