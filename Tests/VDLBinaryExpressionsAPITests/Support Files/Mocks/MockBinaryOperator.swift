//
//  VDLBinaryExpressionsAPI
//  MockBinaryOperator.swift
//  
//
//  Created by Valeriano Della Longa on 06/02/2020.
//  Copyright (c) 2020 Valeriano Della Longa
//
import Foundation
import XCTest
@testable import VDLBinaryExpressionsAPI

extension Int: RepresentableAsEmptyProtocol {
    public static func empty() -> Int {
        return 0
    }
    
    public var isEmpty: Bool { return self == 0 }
}

enum MockBinaryOperator: BinaryOperatorProtocol, Equatable, CaseIterable {
    case add
    case multiply
    case failingOperation
    
    enum Error: Swift.Error {
        case failedOperation
    }
    
    // MARK: - BinaryOperatorProtocol Conformance
    typealias Operand = Int
    
    var binaryOperation: (Int, Int) throws -> Int {
        switch self {
        case .add:
            return { lhs, rhs in return lhs + rhs }
        case .multiply:
            return { lhs, rhs in return lhs * rhs}
        case .failingOperation:
            fallthrough
        @unknown default:
            return { _, _ in throw Error.failedOperation }
        }
    }
    
    var associativity: BinaryOperatorAssociativity { return self ~=  .failingOperation ? .right : .left }
    
    var priority: Int {
        switch self {
        case .add:
            return 30
        case . multiply:
            return 50
        case .failingOperation:
            fallthrough
        @unknown default:
            return 9
        }
    }
}

// MARK: - Other Protocols Conformances
extension MockBinaryOperator: CustomStringConvertible {
    var description: String {
        switch self {
        case .add:
            return "+"
        case .multiply:
            return "*"
        case .failingOperation:
            return "ƒ"
        }
    }
}

extension MockBinaryOperator: CustomDebugStringConvertible {
    var debugDescription: String {
        return self.description
    }
}

extension MockBinaryOperator: Codable {
    enum Base: String, Codable {
        case add
        case multiply
        case failingOperation
        
        fileprivate func _concrete() -> MockBinaryOperator {
            switch self {
            case .add:
                return .add
            case .multiply:
                return .multiply
            case .failingOperation:
                return .failingOperation
            }
        }
        
    }
    
    fileprivate func _base() -> Base {
        switch self {
        case .add:
            return .add
        case .multiply:
            return .multiply
        case .failingOperation:
            return .failingOperation
        }
    }
    
    enum CodingKeys: CodingKey {
        case base
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let base = self._base()
        try container.encode(base, forKey: .base)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let base = try container.decode(Base.self, forKey: .base)
        self = base._concrete()
    }
}
