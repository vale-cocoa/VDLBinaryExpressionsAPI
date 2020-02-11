//
//  VDLBinaryExpressionAPI
//  MyStringOperators.swift
//  
//
//  Created by Valeriano Della Longa on 11/02/2020.
//  Copyright (c) 2020 Valeriano Della Longa
//

import Foundation
public enum MyStringOperators: BinaryOperatorProtocol {
    case shuffling
    case camelCasing
    
    enum Error: Swift.Error {
        case failure
    }
    
    static func shuffle(lhs: String, rhs: String) throws -> String {
        guard
            !lhs.isEmpty,
            !rhs.isEmpty
            else { throw Error.failure}
        
        return zip(lhs, rhs)
            .map { (String($0.0), String($0.1)) }
            .reduce("") { $0 + ($1.0 + $1.1) }
    }
    
    static func camelCase(lhs: String, rhs: String) throws -> String {
        guard
            !(lhs.isEmpty && rhs.isEmpty)
            else { return "" }
        
        let lhsCap = try _wordsCapitalized(on: lhs)
        let rhsCap = try _wordsCapitalized(on: rhs)
        let res = lhsCap + rhsCap
        let first = res.first!
        
        return (first.lowercased()) + (res.dropFirst())
    }
    
    private static func _wordsCapitalized(on string: String) throws -> String {
        guard
            !string.isEmpty
            else { throw Error.failure }
        
        return string
            .components(separatedBy: " ")
            .map { $0.lowercased() }
            .map { $0.capitalized }
            .joined()
    }
    
    // MARK: - BinaryOperatorProtocol conformance
    public typealias Operand = String
    
    public var binaryOperation: (String, String) throws -> String {
        switch self {
        case .shuffling: return Self.shuffle
        case .camelCasing: return Self.camelCase
        }
    }
    
    public var priority: Int {
        switch self {
        case .shuffling:
            return 10
        case.camelCasing:
            return 50
        }
    }
    
    public var associativity: BinaryOperatorAssociativity {
        switch self {
        case .shuffling:
            return .left
        case .camelCasing:
            return .left
        }
    }
    
}

extension String: RepresentableAsEmptyProtocol {
    public static func empty() -> String {
        return ""
    }
}

typealias Token = BinaryOperatorExpressionToken<MyStringOperators>

let anInfix: [Token] = [
    .openingBracket,
    .operand("Hello World!"),
    .binaryOperator(.camelCasing),
    .operand("This is a fun"),
    .closingBracket,
    .binaryOperator(.shuffling),
    .operand("experiment")
]

extension MyStringOperators: Codable {
    enum Base: String, Codable {
        case shufflingEncodedOperator
        case camelCaseEncodedOperator
        
        fileprivate var concrete: MyStringOperators {
            switch self {
            case .camelCaseEncodedOperator:
                return .camelCasing
            case .shufflingEncodedOperator:
                return .shuffling
            }
        }
    }
    
    fileprivate var base: Base {
        switch self {
        case .shuffling:
            return .shufflingEncodedOperator
        case .camelCasing:
            return .camelCaseEncodedOperator
        }
    }
    
    enum CodingKeys: CodingKey {
        case base
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let base = try container.decode(Base.self, forKey: .base)
        self = base.concrete
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.base, forKey: .base)
    }
    
}
