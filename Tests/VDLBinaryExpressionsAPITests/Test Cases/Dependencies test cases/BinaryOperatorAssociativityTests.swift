//
//  BinaryOperatorAssociativityTests.swift
//  
//
//  Created by Valeriano Della Longa on 06/02/2020.
//

import XCTest
@ testable import VDLBinaryExpressionsAPI

final class BinaryOperatorAssociativityTests: XCTestCase {
    // MARK: - Properties
    var sut: BinaryOperatorAssociativity!
    
    // MARK: - Tests lifecycle
    override func setUp() {
        super.setUp()
        
    }
    
    override func tearDown() {
        self.sut = nil
        
        super.tearDown()
    }
    
    // MARK: - Tests
    func test_enumCases() {
        sut = BinaryOperatorAssociativity.left
        sut = BinaryOperatorAssociativity.right
    }
    
    func test_conformsToCaseIterable() {
        XCTAssertNotNil(BinaryOperatorAssociativity.allCases)
    }
    
    func test_conformsToEquatable() {
        // when
        for aCase in BinaryOperatorAssociativity.allCases {
            sut = aCase
            // then
            XCTAssertTrue(sut == aCase)
        }
    }
    
    func test_conformsToCodable() {
        // when
        for aCase in BinaryOperatorAssociativity.allCases {
            sut = aCase
            
            // then
            XCTAssertTrue((sut as Any) is Codable)
        }
    }
    
    func test_Codable_encode_whenValid_doesntThrow() {
        // given
        let encoder = JSONEncoder()
        
        // when
        for aCase in BinaryOperatorAssociativity.allCases {
            sut = aCase
            
            // then
            XCTAssertNoThrow(try encoder.encode(sut))
        }
    }
    
    func test_Codable_decode_whenValid_doesntThrow() {
        // given
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        // when
        for aCase in BinaryOperatorAssociativity.allCases {
            sut = aCase
            // guaranted by test_Codable_encode_whenValid_doesntThrow()
            let data = try! encoder.encode(sut)
            
            // then
            XCTAssertNoThrow(try decoder.decode(BinaryOperatorAssociativity.self, from: data))
        }
    }
    
    func test_Codable_encodeAndDecode_returnsSame() {
        // given
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        var result = [BinaryOperatorAssociativity]()
        
        // when
        for aCase in BinaryOperatorAssociativity.allCases {
            // guaranted by test_Codable_encode_whenValid_doesntThrow()
            let data = try! encoder.encode(aCase)
            // guaranted by test_Codable_decode_whenValid_doesntThrow()
            let decoded = try! decoder.decode(BinaryOperatorAssociativity.self, from: data)
            result.append(decoded)
        }
        
        // then
        XCTAssertEqual(BinaryOperatorAssociativity.allCases, result)
    }
    
    static var allTests = [
        ("test_enumCases", test_enumCases),
        ("test_conformsToCaseIterable", test_conformsToCaseIterable),
        ("test_conformsToEquatable", test_conformsToEquatable),
        ("test_Codable_encode_whenValid_doesntThrow", test_Codable_encode_whenValid_doesntThrow),
        ("test_Codable_decode_whenValid_doesntThrow", test_Codable_decode_whenValid_doesntThrow),
        ("test_Codable_encodeAndDecode_returnsSame", test_Codable_encodeAndDecode_returnsSame),
        
    ]
}
