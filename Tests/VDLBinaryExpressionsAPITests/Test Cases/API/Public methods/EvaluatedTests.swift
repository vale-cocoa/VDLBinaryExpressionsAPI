//
//  VDLBinaryExpressionsAPITests
//  EvaluatedTests.swift
//
//
//  Created by Valeriano Della Longa on 18/02/2020.
//  Copyright (c) 2020 Valeriano Della Longa
//

import XCTest
@testable import VDLBinaryExpressionsAPI

import Foundation

final class EvaluatedTests: XCTestCase {
    var sut: AnyCollection<Token>!
    var expectedResult: Result<Int, Error>!
    
    // MARK: - Test lifecycle
    override func setUp() {
        super.setUp()
        
        sut = AnyCollection([])
        expectedResult = .success(0)
    }
    
    override func tearDown() {
        sut = nil
        expectedResult = nil
        
        super.tearDown()
    }
    
    // MARK: - Given
    
    // MARK: - When
    func whenNotValid() {
        sut = AnyCollection([.openingBracket, .operand(10), .operand(20), .binaryOperator(.add), .closingBracket])
        expectedResult = .failure(BinaryExpressionError.notValid)
    }
    
    func whenValid_cases() -> [() -> Void] {
        var cases = [() -> Void]()
        let validCases = MockBinaryOperator.givenSimpleBinaryOperationExpressions(postfix: false).dropFirst(2) + MockBinaryOperator.givenSimpleBinaryOperationExpressions()
        for validCase in validCases {
            cases.append {
                self.sut = validCase.expression
                self.expectedResult = validCase.value
            }
        }
        
        return cases
    }
    
    // MARK: - Then
    func thenResultIsExpected() {
        let result: Result<Int, Error>!
        do {
            let evaluation = try sut.evaluated()
            result = .success(evaluation)
        } catch {
            result = .failure(error)
        }
        
        switch (result, expectedResult) {
        case (.success(let evaluation), .success(let expectedEvaluation)):
            XCTAssertEqual(evaluation, expectedEvaluation)
        case (.failure(let resultError as NSError), .failure(let expectedError as NSError)):
            XCTAssertEqual(resultError.domain, expectedError.domain)
            XCTAssertEqual(resultError.code, expectedError.code)
        default:
            XCTFail()
        }
        
    }
    
    // MARK: Tests
    func test_whenNotValid_throws()
    {
        // when
        whenNotValid()
        
        // then
        XCTAssertThrowsError(try self.sut.evaluated())
    }
    
    func test_whenNotValid_throwsExpectedError()
    {
        // when
        whenNotValid()
        
        // then
        thenResultIsExpected()
    }
    
    func test_whenEmpty_doesntThrow() {
        XCTAssertNoThrow(try sut.evaluated())
    }
    
    func test_whenEmpty_returnsExpectedResult() {
        thenResultIsExpected()
    }
    
    func test_whenEmpty_returnsOperandsEmptyValue() {
        XCTAssertEqual(try! sut.evaluated(), MockBinaryOperator.Operand.empty())
    }
    
    func test_whenValid_DoesntThrowNotValidError() {
        // given
        let notValidError = BinaryExpressionError.notValid as NSError
        
        for when in whenValid_cases() {
            // when
            when()
            
            let result: Result<Int, Error>!
            do
            {
                let evaluated = try sut.evaluated()
                result = .success(evaluated)
            } catch {
                result = .failure(error)
            }
            
            // then
            switch result {
            case .success(_):
                continue
            case .failure(let resultError as NSError):
                XCTAssertNotEqual(resultError.domain, notValidError.domain)
            case .none:
                fatalError("WTF?! Result should be set!")
            }
        }
    }
    
    func test_whenValid_ResultIsExpected() {
        for when in whenValid_cases() {
            // when
            when()
            
            // then
            thenResultIsExpected()
        }
    }
    
    static var allTest = [
        ("test_whenNotValid_throws", test_whenNotValid_throws),
        ("test_whenNotValid_throwsExpectedError", test_whenNotValid_throwsExpectedError),
        ("test_whenEmpty_doesntThrow", test_whenEmpty_doesntThrow),
        ("test_whenEmpty_returnsExpectedResult", test_whenEmpty_returnsExpectedResult),
        ("test_whenEmpty_returnsOperandsEmptyValue", test_whenEmpty_returnsOperandsEmptyValue),
        ("test_whenValid_DoesntThrowNotValidError", test_whenValid_DoesntThrowNotValidError),
        ("test_whenValid_ResultIsExpected", test_whenValid_ResultIsExpected),
        
    ]
}
