//
//  VDLBinaryExpressionsAPI
//  BinaryOperatorExpressionTokenTests.swift
//
//
//  Created by Valeriano Della Longa on 06/02/2020.
//  Copyright (c) 2020 Valeriano Della Longa
//

import XCTest
@testable import VDLBinaryExpressionsAPI

final class BinaryOperatorExpressionTokenTests: XCTestCase {
    typealias Token = BinaryOperatorExpressionToken<MockBinaryOperator>
    // MARK: - Properties
    var sut: Token!
    
    // MARK: - Lifecycle
    override func setUp() {
        super.setUp()
        
    }
    
    override func tearDown() {
        self.sut = nil
        
        super.tearDown()
    }
    
    // MARK: - Tests
    func test_cases() {
        XCTAssertNotNil(sut = .openingBracket)
        XCTAssertNotNil(sut = .closingBracket)
        XCTAssertNotNil(sut = .operand(Int.random(in: 1...100)))
        for anOp in MockBinaryOperator.allCases {
            XCTAssertNotNil(sut = .binaryOperator(anOp))
        }
    }
    
    func test_isOpeningBracket() {
        sut = .openingBracket
        XCTAssertTrue(sut.isOpeningBracket)
        
        sut = .operand(Int.random(in: 1...100))
        XCTAssertFalse(sut.isOpeningBracket)
        
        for anOp in MockBinaryOperator.allCases {
            sut = .binaryOperator(anOp)
            XCTAssertFalse(sut.isOpeningBracket)
        }
        
        sut = .closingBracket
        XCTAssertFalse(sut.isOpeningBracket)
    }
    
    func test_isClosingBracket() {
        sut = .closingBracket
        XCTAssertTrue(sut.isClosingBracket)
        
        sut = .operand(Int.random(in: Int.min...Int.max))
        XCTAssertFalse(sut.isClosingBracket)
        
        sut = .openingBracket
        XCTAssertFalse(sut.isClosingBracket)
        
        for anOp in MockBinaryOperator.allCases {
            sut = .binaryOperator(anOp)
            XCTAssertFalse(sut.isClosingBracket)
        }
    }
    
    func test_isOperand() {
        sut = .operand(Int.random(in: Int.min...Int.max))
        XCTAssertTrue(sut.isOperand)
        
        sut = .openingBracket
        XCTAssertFalse(sut.isOperand)
        
        sut = .closingBracket
        XCTAssertFalse(sut.isOperand)
        
        for anOp in MockBinaryOperator.allCases {
            sut = .binaryOperator(anOp)
            XCTAssertFalse(sut.isOperand)
        }
    }
    
    func test_isBinaryOperator() {
        for anOp in MockBinaryOperator.allCases {
            sut = .binaryOperator(anOp)
            XCTAssertTrue(sut.isBinaryOperator)
        }
        
        sut = .operand(Int.random(in: Int.min...Int.max))
        XCTAssertFalse(sut.isBinaryOperator)
     
        sut = .openingBracket
        XCTAssertFalse(sut.isBinaryOperator)
        
        sut = .closingBracket
        XCTAssertFalse(sut.isBinaryOperator)
    }
    
    func test_equatable() {
        // when
        sut = .openingBracket
        
        // then
        XCTAssertTrue(sut == .openingBracket)
        XCTAssertTrue(sut != .closingBracket)
        XCTAssertTrue(sut != .operand(Int.random(in: 1...100)))
        for anOp in MockBinaryOperator.allCases {
            XCTAssertTrue(sut != .binaryOperator(anOp))
        }
        
        // when
        sut = .closingBracket
        // then
        XCTAssertTrue(sut == .closingBracket)
        XCTAssertTrue(sut != .openingBracket)
        XCTAssertTrue(sut != .operand(Int.random(in: 1...100)))
        for anOp in MockBinaryOperator.allCases {
            XCTAssertTrue(sut != .binaryOperator(anOp))
        }
        
        // given
        let randomOperandInUse = Int.random(in: 1...100)
        let differentOperand = Int.random(in: 101...200)
        
        // when
        sut = .operand(randomOperandInUse)
        // then
        XCTAssertTrue(sut == .operand(randomOperandInUse))
        XCTAssertTrue(sut != .operand(differentOperand))
        XCTAssertTrue(sut != .openingBracket)
        XCTAssertTrue(sut != .closingBracket)
        for anOp in MockBinaryOperator.allCases {
            XCTAssertTrue(sut != .binaryOperator(anOp))
        }
        
        // when
        for anOp in MockBinaryOperator.allCases {
            sut = .binaryOperator(anOp)
            
            // then
            XCTAssertTrue(sut == .binaryOperator(anOp))
            let otherOps = MockBinaryOperator.allCases.filter { $0 != anOp }
            for otherOp in otherOps {
                XCTAssertTrue(sut != .binaryOperator(otherOp))
            }
            XCTAssertTrue(sut != .operand(Int.random(in: 1...100)))
            XCTAssertTrue(sut != .openingBracket)
            XCTAssertTrue(sut != .closingBracket)
        }
        
    }
    
    func test_Codable_encode_doesntThrow() {
        // given
        let encoder = JSONEncoder()
        
        // when
        sut = .openingBracket
        // then
        XCTAssertNoThrow(try encoder.encode(sut))
     
        // when
        sut = .closingBracket
        // then
        XCTAssertNoThrow(try encoder.encode(sut))
        
        // when
        sut = .operand(Int.random(in: 1...100))
        // then
        XCTAssertNoThrow(try encoder.encode(sut))
        
        // when
        for anOp in MockBinaryOperator.allCases {
            sut = .binaryOperator(anOp)
            
            // then
            XCTAssertNoThrow(try encoder.encode(sut))
        }
    }
    
    func test_Codable_decode_doesntThrow() {
        // given
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        var data: Data!
        
        // when
        sut = .openingBracket
        data = try! encoder.encode(sut)
        // then
        XCTAssertNoThrow(try decoder.decode(BinaryOperatorExpressionToken<MockBinaryOperator>.self, from: data))
     
        // when
        sut = .closingBracket
        data = try! encoder.encode(sut)
        // then
        XCTAssertNoThrow(try decoder.decode(BinaryOperatorExpressionToken<MockBinaryOperator>.self, from: data))
        
        // when
        data = try! encoder.encode(sut)
        // then
        XCTAssertNoThrow(try decoder.decode(BinaryOperatorExpressionToken<MockBinaryOperator>.self, from: data))
        
        // when
        for anOp in MockBinaryOperator.allCases {
            sut = .binaryOperator(anOp)
            data = try! encoder.encode(sut)
            // then
            XCTAssertNoThrow(try decoder.decode(BinaryOperatorExpressionToken<MockBinaryOperator>.self, from: data))
        }
    }
    
    static var allTests = [
        ("test_cases", test_cases),
        ("test_isOpeningBracket", test_isOpeningBracket),
        ("test_isClosingBracket", test_isClosingBracket),
        ("test_isOperand", test_isOperand),
        ("test_isBinaryOperator", test_isBinaryOperator),
        ("test_equatable", test_equatable),
        ("test_Codable_encode_doesntThrow", test_Codable_encode_doesntThrow),
        ("test_Codable_decode_doesntThrow", test_Codable_decode_doesntThrow),
        
    ]
}
