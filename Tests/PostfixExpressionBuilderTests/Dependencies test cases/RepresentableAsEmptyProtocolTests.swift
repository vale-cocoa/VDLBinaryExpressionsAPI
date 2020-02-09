//
//  RepresentableAsEmptyProtocolTests.swift
//  
//
//  Created by Valeriano Della Longa on 07/02/2020.
//

import XCTest
@testable import PostfixExpressionBuilder

final class RepresentableAsEmptyProtocolTests: XCTestCase {
    // MARK: - Properties
    
    // MARK: - Test Lifecycle
    
    // MARK: - Tests
    func test_RepresentableAsEmptyProtocol_canConformTo() {
        // given
        let str = "Hello World"
        // when
        // then
        XCTAssertTrue((str as Any) is RepresentableAsEmptyProtocol)
    }
    
    func test_empty_returnsAnEmptyValue() {
        // given
        let sut = String.empty()
        
        // when
        // then
        XCTAssertTrue(sut.isEmpty)
    }
    
    static var allTests = [
        ("test_RepresentableAsEmptyProtocol_canConformTo", test_RepresentableAsEmptyProtocol_canConformTo),
        ("test_empty_returnsAnEmptyValue", test_empty_returnsAnEmptyValue),
        
    ]
}

extension String: RepresentableAsEmptyProtocol {
    public static func empty() -> String {
        return ""
    }
}