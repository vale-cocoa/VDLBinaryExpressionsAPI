//
//  VDLBinaryExpressionsAPI
//  AnyBinaryOperatorTests.swift
//  
//
//  Created by Valeriano Della Longa on 16/02/2020.
//  Copyright (c) 2020 Valeriano Della Longa
//

import XCTest
@testable import VDLBinaryExpressionsAPI

final class AnyBinaryOperatorTests: XCTestCase {
    // MARK: - Test lifecycle
    
    // MARK: - Given
    
    // MARK: - When
    
    // MARK: - Then
    func thenAreEqual<Operand>(sutResult: Result<Operand, Error>, expectedResult: Result<Operand, Error>) where Operand: Equatable {
        switch (sutResult, expectedResult) {
        case (.failure(let sutError as NSError), .failure(let expectedError as NSError)):
            XCTAssertEqual(sutError.domain, expectedError.domain)
            XCTAssertEqual(sutError.code, expectedError.code)
        case (.success(let sutOperationResult), .success(let operationExpectedResult)):
            XCTAssertEqual(sutOperationResult, operationExpectedResult)
        default:
            XCTFail()
        }
    }
    
    // MARK: - Tests
    func test_whenInitFromConcreteBase_conformsToBinaryOperationProtocol() {
        // given
        let concrete = MockConcreteBinaryOperator<Int>()
        
        // when
        let sut = AnyBinaryOperator.init(concrete)
        
        // then
        XCTAssertNotNil(sut.priority)
        XCTAssertNotNil(sut.associativity)
        XCTAssertNotNil(sut.binaryOperation)
        XCTAssert(type(of: sut).Operand.self == type(of: concrete).Operand.self)
        XCTAssert(type(of: sut.associativity).self == type(of: concrete.associativity).self)
        XCTAssert(type(of: sut.priority).self == type(of: concrete.priority).self)
        XCTAssert(type(of: sut.binaryOperation).self == type(of: concrete.binaryOperation).self)
    }
    
    func test_whenInitFromClosure_conformsToBinaryOperatorProtocol() {
        // given
        // when
        let sut = AnyBinaryOperator.init(byOperation: { _, _ throws -> Int in
            throw MockConcreteBinaryOperator<Int>.Error.operationNotImplemented
        })
        
        // then
        // then
        XCTAssertNotNil(sut.priority)
        XCTAssertNotNil(sut.associativity)
        XCTAssertNotNil(sut.binaryOperation)
        XCTAssert(type(of: sut).Operand.self == Int.self)
    }
    
    func test_whenInitFromConcrete_usesItsProtocolImplementation() {
        // given
        let concrete = MockConcreteBinaryOperator<Int>()
        let expectedOpResult: Result<Int, Error> = .failure(MockConcreteBinaryOperator<Int>.Error.operationNotImplemented)
        
        // when
        let sut = AnyBinaryOperator(concrete)
        let operationResult: Result<Int, Error>!
        do {
            let result = try sut.binaryOperation(10, 20)
            operationResult = .success(result)
        } catch {
            operationResult = .failure(error)
        }
        
        _ = sut.priority
        _ = sut.associativity
        
        // then
        XCTAssertTrue(concrete.binaryOperationCalled)
        thenAreEqual(sutResult: operationResult, expectedResult: expectedOpResult)
        XCTAssertTrue(concrete.priorityCalled)
        XCTAssertEqual(sut.priority, concrete.priority)
        XCTAssertTrue(concrete.associativityCalled)
        XCTAssertEqual(sut.associativity, concrete.associativity)
    }
    
    func test_whenInitFromClosure_protocolImplementationWorksAsExpected() {
        // given
        var closureCalled = false
        let priority = 500
        let associativity: BinaryOperatorAssociativity = .right
        let closure: (Int, Int) throws -> Int = { _, _ in
            closureCalled = true
            throw MockConcreteBinaryOperator<Int>.Error.operationNotImplemented
        }
        let expectedOpResult: Result<Int, Error> = .failure(MockConcreteBinaryOperator<Int>.Error.operationNotImplemented)
        
        // when
        let sut = AnyBinaryOperator(ofPriority: priority, ofAssociativity: associativity, byOperation: closure)
        let operationResult: Result<Int, Error>!
        do {
            let result = try sut.binaryOperation(10, 20)
            operationResult = .success(result)
        } catch {
            operationResult = .failure(error)
        }
        
        // then
        XCTAssertTrue(closureCalled)
        thenAreEqual(sutResult: operationResult, expectedResult: expectedOpResult)
        XCTAssertEqual(sut.priority, priority)
        XCTAssertEqual(sut.associativity, associativity)
    }
    
    static var allTests = [
        ("test_whenInitFromConcreteBase_conformsToBinaryOperationProtocol", test_whenInitFromConcreteBase_conformsToBinaryOperationProtocol),
        ("test_whenInitFromClosure_conformsToBinaryOperatorProtocol", test_whenInitFromClosure_conformsToBinaryOperatorProtocol),
        ("test_whenInitFromConcrete_usesItsProtocolImplementation", test_whenInitFromConcrete_usesItsProtocolImplementation),
        ("test_whenInitFromClosure_protocolImplementationWorksAsExpected", test_whenInitFromClosure_protocolImplementationWorksAsExpected),
        
    ]
    
}
