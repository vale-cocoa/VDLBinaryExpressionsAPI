//
//  API_evalTests.swift
//  
//
//  Created by Valeriano Della Longa on 07/02/2020.
//

import XCTest
@testable import PostfixExpressionBuilder

final class API_evalTests: XCTestCase {
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
    func givenExpectedResult_whenTwoOperandsThenOperation() -> Token.Operand {
        whenTwoOperandsThenOperation()
        let opToken = sut.last!
        let lhsToken = sut.first!
        let rhsToken = sut[1]
        guard
            case .operand(let lhs) = lhsToken,
            case .operand(let rhs) = rhsToken,
            case .binaryOperator(let op) = opToken
            else { fatalError() }
        
        return try! op.binaryOperation(lhs, rhs)
    }
    
    func givenExpectedResult_whenTwoOperandsThenOperationThenTwoOperandsThenTwoOperations() -> Token.Operand {
        whenTwoOperandsThenOperationThenTwoOperandsThenTwoOperations()
        let mainOpToken = sut.popLast()!
        let rhsSubOpToken = sut.popLast()
        let rhsSubRhsToken = sut.popLast()
        let rhsSubLhsToken = sut.popLast()!
        let lhsSubOpToken = sut.popLast()!
        let lhsSubRhsToken = sut.popLast()!
        let lhsSubLhsToken = sut.popLast()!
        
        guard
            case .binaryOperator(let mainOp) = mainOpToken,
            case .binaryOperator(let rhsOp) = rhsSubOpToken,
            case .operand(let rhsSubRhs) = rhsSubRhsToken,
            case .operand(let rhsSubLhs) = rhsSubLhsToken,
            let rhs = try? rhsOp.binaryOperation(rhsSubLhs, rhsSubRhs),
            case .binaryOperator(let lhsOp) = lhsSubOpToken,
            case .operand(let lhsSubRhs) = lhsSubRhsToken,
            case .operand(let lhsSubLhs) = lhsSubLhsToken,
            let lhs = try? lhsOp.binaryOperation(lhsSubLhs, lhsSubRhs)
            else { fatalError() }
        
        return try! mainOp.binaryOperation(lhs, rhs)
        
    }
    
    // MARK: - When
    func whenEmpty() {
        sut = []
    }
    
    func whenTwoOperandsThenOperation() {
        sut = [.operand(10), .operand(20), .binaryOperator(.add)]
    }
    
    func whenTwoOperandsThenFailingOperation() {
        sut = [.operand(10), .operand(20), .binaryOperator(.failingOperation)]
    }
    
    func whenTwoOperandsThenOperationThenTwoOperandsThenTwoOperations()
    {
        sut = [.operand(10), .operand(20), .binaryOperator(.add), .operand(30), .operand(40), .binaryOperator(.add), .binaryOperator(.multiply)]
    }
    
    // MARK: - Tests
    func test_whenEmpty_doesntThrow() {
        // when
        whenEmpty()
        
        // then
        XCTAssertNoThrow(try _eval(postfix: sut, shouldThrowOnFailingOp: true))
        XCTAssertNoThrow(try _eval(postfix: sut, shouldThrowOnFailingOp: false))
    }
    
    func test_whenEmpty_returnsNil() {
        // when
        whenEmpty()
        
        // then
        // guaranted by test_whenEmpty_doesntThrow()
        XCTAssertNil(try! _eval(postfix: sut, shouldThrowOnFailingOp: true))
        XCTAssertNil(try! _eval(postfix: sut, shouldThrowOnFailingOp: false))
    }
    
    func test_whenOneOperandThenOperation_Throws() {
        // when
        sut = [.operand(10), .binaryOperator(.add)]
        
        // then
        XCTAssertThrowsError(try _eval(postfix: sut, shouldThrowOnFailingOp: true))
        XCTAssertThrowsError(try _eval(postfix: sut, shouldThrowOnFailingOp: false))
    }
    
    func test_whenTwoOperandsThenOperation_doesntThrow() {
        // when
        sut = [.operand(10), .operand(20), .binaryOperator(.add)]
        
        // then
        XCTAssertNoThrow(try _eval(postfix: sut, shouldThrowOnFailingOp: true))
        XCTAssertNoThrow(try _eval(postfix: sut, shouldThrowOnFailingOp: false))
    }
    
    func test_whenTwoOperandsThenFailingOperation_shoudlThrowOnFailingOpIsTrue_throws() {
        // when
        whenTwoOperandsThenFailingOperation()
        
        // then
        XCTAssertThrowsError(try _eval(postfix: sut, shouldThrowOnFailingOp: true))
    }
    
    func test_whenTwoOperandsThenFailingOperation_shoudlThrowOnFailingOpIsFalse_doesntThrow() {
        // when
        whenTwoOperandsThenFailingOperation()
        
        // then
        XCTAssertNoThrow(try _eval(postfix: sut, shouldThrowOnFailingOp: false))
    }
    
    func test_whenTwoOperandsThenFailingOperation_shoudlThrowOnFailingOpIsFalse_returnsNil() {
        // when
        whenTwoOperandsThenFailingOperation()
        
        // then
        // guaranted by test_whenTwoOperandsThenFailingOperation_shoudlThrowOnFailingOpIsFalse_doesntThrow()
        XCTAssertNil(try! _eval(postfix: sut, shouldThrowOnFailingOp: false))
    }
    
    func test_whenTwoOperandsThenOperation_doesntReturnNil() {
        // when
        whenTwoOperandsThenOperation()
        
        // then
        // guaranted by test_whenTwoOperandsThenOperation_doesntThrow()
        XCTAssertNotNil(try! _eval(postfix: sut, shouldThrowOnFailingOp: false))
        XCTAssertNotNil(try! _eval(postfix: sut, shouldThrowOnFailingOp: true))
    }
    
    func test_whenTwoOperandsThenOperation_evaluatesCorrectly() {
        // given
        let expectedResult = givenExpectedResult_whenTwoOperandsThenOperation()
        
        // when
        whenTwoOperandsThenOperation()
        
        // then
        // guaranted by:
        // test_whenTwoOperandsThenOperation_doesntThrow()
        // test_whenTwoOperandsThenOperation_doesntReturnNil()
        XCTAssertEqual(try! _eval(postfix: sut, shouldThrowOnFailingOp: false)!, expectedResult)
        XCTAssertEqual(try! _eval(postfix: sut, shouldThrowOnFailingOp: true)!, expectedResult)
    }
    
    func test_whenContainingOpeningbracket_throws() {
        // when
        sut = [.openingBracket, .operand(10), .operand(30), .binaryOperator(.add)]
        
        // then
        XCTAssertThrowsError(try _eval(postfix: sut, shouldThrowOnFailingOp: false))
        XCTAssertThrowsError(try _eval(postfix: sut, shouldThrowOnFailingOp: true))
    }
    
    func test_whenContainingClosingbracket_throws() {
        // when
        sut = [.operand(10), .operand(30), .binaryOperator(.add), .closingBracket]
        
        // then
        XCTAssertThrowsError(try _eval(postfix: sut, shouldThrowOnFailingOp: false))
        XCTAssertThrowsError(try _eval(postfix: sut, shouldThrowOnFailingOp: true))
    }
    
    func test_whenThreeOperandsThenOperation_throws() {
        // when
        sut = [.operand(5), .operand(10), .operand(30), .binaryOperator(.add)]
        
        // then
        XCTAssertThrowsError(try _eval(postfix: sut, shouldThrowOnFailingOp: false))
        XCTAssertThrowsError(try _eval(postfix: sut, shouldThrowOnFailingOp: true))
    }
    
    func test_whenTwoOperandsThenOperationThenTwoOperandsThenTwoOperations_doesntThrow() {
        // when
        whenTwoOperandsThenOperationThenTwoOperandsThenTwoOperations()
        
        // then
        XCTAssertNoThrow(try _eval(postfix: sut, shouldThrowOnFailingOp: true))
        XCTAssertNoThrow(try _eval(postfix: sut, shouldThrowOnFailingOp: false))
    }
    
    func test_whenTwoOperandsThenOperationThenTwoOperandsThenTwoOperations_notNil() {
        // when
        whenTwoOperandsThenOperationThenTwoOperandsThenTwoOperations()
        
        // then
        // guaranted by test_whenTwoOperandsThenOperationThenTwoOperandsThenTwoOperations_doesntThrow()
        XCTAssertNotNil(try! _eval(postfix: sut, shouldThrowOnFailingOp: true))
        XCTAssertNotNil(try! _eval(postfix: sut, shouldThrowOnFailingOp: false))
    }
    
    func test_whenTwoOperandsThenOperationThenTwoOperandsThenTwoOperations_evaluatesCorrectly() {
        // given
        let expectedResult = givenExpectedResult_whenTwoOperandsThenOperationThenTwoOperandsThenTwoOperations()
        
        // when
        whenTwoOperandsThenOperationThenTwoOperandsThenTwoOperations()
        
        // then
        // guaranted by:
        // test_whenTwoOperandsThenOperationThenTwoOperandsThenTwoOperations_doesntThrow()
        // test_whenTwoOperandsThenOperationThenTwoOperandsThenTwoOperations_evaluatesCorrectly()
        XCTAssertEqual(try! _eval(postfix: sut, shouldThrowOnFailingOp: false)!, expectedResult)
        XCTAssertEqual(try! _eval(postfix: sut, shouldThrowOnFailingOp: true)!, expectedResult)
    }
    
    static var allTests = [
        ("test_whenEmpty_doesntThrow", test_whenEmpty_doesntThrow),
        ("test_whenEmpty_returnsNil" ,test_whenEmpty_returnsNil),
        ("test_whenOneOperandThenOperation_Throws", test_whenOneOperandThenOperation_Throws),
        ("test_whenOneOperandThenOperation_Throws", test_whenOneOperandThenOperation_Throws),
        ("test_whenTwoOperandsThenFailingOperation_shoudlThrowOnFailingOpIsTrue_throws", test_whenTwoOperandsThenFailingOperation_shoudlThrowOnFailingOpIsTrue_throws),
        ("test_whenTwoOperandsThenFailingOperation_shoudlThrowOnFailingOpIsFalse_doesntThrow", test_whenTwoOperandsThenFailingOperation_shoudlThrowOnFailingOpIsFalse_doesntThrow),
     ("test_whenTwoOperandsThenFailingOperation_shoudlThrowOnFailingOpIsFalse_returnsNil", test_whenTwoOperandsThenFailingOperation_shoudlThrowOnFailingOpIsFalse_returnsNil),
     ("test_whenTwoOperandsThenOperation_doesntReturnNil", test_whenTwoOperandsThenOperation_doesntReturnNil),
     ("test_whenTwoOperandsThenOperation_evaluatesCorrectly", test_whenTwoOperandsThenOperation_evaluatesCorrectly),
     ("test_whenContainingOpeningbracket_throws", test_whenContainingOpeningbracket_throws),
     ("test_whenContainingClosingbracket_throws", test_whenContainingClosingbracket_throws),
     ("test_whenTwoOperandsThenOperationThenTwoOperandsThenTwoOperations_doesntThrow", test_whenTwoOperandsThenOperationThenTwoOperandsThenTwoOperations_doesntThrow),
     ("test_whenTwoOperandsThenOperationThenTwoOperandsThenTwoOperations_notNil", test_whenTwoOperandsThenOperationThenTwoOperandsThenTwoOperations_notNil),
     ("test_whenTwoOperandsThenOperationThenTwoOperandsThenTwoOperations_evaluatesCorrectly", test_whenTwoOperandsThenOperationThenTwoOperandsThenTwoOperations_evaluatesCorrectly),
     
    ]
}
