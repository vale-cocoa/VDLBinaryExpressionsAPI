//
//  VDLBinaryExpressionsAPI
//  BinaryOperatorExpressionToken.swift
//  
//
//  Created by Valeriano Della Longa on 06/02/2020.
//  Copyright (c) 2020 Valeriano Della Longa
//

import Foundation

/// An enum for representing tokens in a binary operation expression.
public enum BinaryOperatorExpressionToken<T> where T: BinaryOperatorProtocol {
    public typealias Operand = T.Operand
    public typealias Operator = T
    
    case openingBracket
    case closingBracket
    case operand(Operand)
    case binaryOperator(Operator)
    
}

// MARK: - CustomStringConvertible conformance
extension BinaryOperatorExpressionToken: CustomStringConvertible where T: CustomStringConvertible, T.Operand: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .openingBracket:
            return "("
        case .closingBracket:
            return ")"
        case .operand(let operand):
            return operand.description
        case .binaryOperator(let binOp):
            return binOp.description
        }
    }
    
}

// MARK: - CustomDebugStringConvertibleConformance
extension BinaryOperatorExpressionToken: CustomDebugStringConvertible where T: CustomDebugStringConvertible, T.Operand: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        switch self {
        case .openingBracket:
            return "("
        case .closingBracket:
            return ")"
        case .operand(let operand):
            return operand.debugDescription
        case .binaryOperator(let binOp):
            return binOp.debugDescription
        }
    }
    
}

// MARK: - Equatable conformance
extension BinaryOperatorExpressionToken: Equatable where T: Equatable, T.Operand: Equatable { }

// MARK: - Codable conformance
extension BinaryOperatorExpressionToken: Codable where T: Codable, T.Operand: Codable {
    enum Base: String, Codable {
        case openingBracket
        case closingBracket
        case operand
        case binaryOperator
    }
    
    fileprivate func _base() throws -> Base {
        switch self {
        case .openingBracket:
            return .openingBracket
        case .closingBracket:
            return .closingBracket
        case .operand( _):
            return .operand
        case .binaryOperator( _):
            return .binaryOperator
        }
    }
    
    enum CodingKeys: CodingKey {
        case base
        case concrete
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let base = try self._base()
        try container.encode(base, forKey: .base)
        if case .operand(let concrete) = self {
            try container.encode(concrete, forKey: .concrete)
        } else if case .binaryOperator(let concrete) = self {
            try container.encode(concrete, forKey: .concrete)
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let base = try container.decode(Base.self, forKey: .base)
        switch base {
        case .openingBracket:
            self = .openingBracket
        case .closingBracket:
            self = .closingBracket
        case .operand:
            let concrete = try container.decode(Operand.self, forKey: .concrete)
            self = .operand(concrete)
        case .binaryOperator:
            let concrete = try container.decode(Operator.self, forKey: .concrete)
            self = .binaryOperator(concrete)
        }
    }
    
}
