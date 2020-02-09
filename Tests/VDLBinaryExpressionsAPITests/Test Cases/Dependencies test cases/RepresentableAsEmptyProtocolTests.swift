//
//  VDLBinaryExpressionsAPI
//  RepresentableAsEmptyProtocolTests.swift
//  
//
//  Created by Valeriano Della Longa on 06/02/2020.
//  Copyright (c) 2020 Valeriano Della Longa
//
import XCTest
@testable import VDLBinaryExpressionsAPI

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
