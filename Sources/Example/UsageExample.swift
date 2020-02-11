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
        
        if (lhs.isEmpty || rhs.isEmpty) { throw Error.failure }
        
        let lhsFixed = lhs
            .components(separatedBy: " ")
            .map { $0.lowercased() }
            .map { $0.capitalized }
            .joined()
        let rhsFixed = rhs
            .components(separatedBy: " ")
            .map { $0.lowercased() }
            .map { $0.capitalized }
            .joined()
        var res = lhsFixed + rhsFixed
        let first = res.dropFirst()
        res = (first.lowercased()) + res
        
        return res
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
