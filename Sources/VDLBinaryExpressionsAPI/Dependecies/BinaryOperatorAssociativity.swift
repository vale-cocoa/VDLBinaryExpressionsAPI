//
//  VDLBinaryExpressionsAPI
//  BinaryOperatorAssociativity.swift
//  
//
//  Created by Valeriano Della Longa on 06/02/2020.
//  Copyright (c) 2020 Valeriano Della Longa
//
import Foundation

/// An `enum` defining the associativity direction of an associative binary operator.
///
/// An associative binary operation can only associate in two ways, either left or right.
/// Given for example the binary operation `f(lhs: T, rhs: T) -> T` represented by
/// the operator `<+>`, then since it is associative it could be used in an infix expression as: `A <+> B <+> C`.
///  When its asociativity is `.left` then `A <+> B` would be firstly evaluated,
///  while if `right` then `B <+> C` would be firstly evaluated.
public enum BinaryOperatorAssociativity: CaseIterable, Codable, Equatable, CustomStringConvertible, CustomDebugStringConvertible {
    case left
    case right
    
    // MARK: - Codable conformance
    enum Base: String, Codable {
        case left
        case right
        
        fileprivate func _concrete() -> BinaryOperatorAssociativity {
            switch self {
            case .left:
                return .left
            case .right:
                return .right
            }
        }
    }
    
    private func _base() -> Base {
        switch self {
        case .left:
            return .left
        case .right:
            return .right
        }
    }
    
    enum CodingKeys: CodingKey {
        case base
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let base = self._base()
        try container.encode(base, forKey: .base)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let base = try container.decode(Base.self, forKey: .base)
        self = base._concrete()
    }
    
    // MARK: - CustomStringConvertible and CustomDebugStringConvertible conformance
    public var description: String {
        
        return self._base().rawValue
    }
    
    public var debugDescription: String {
        
        return self.description
    }
}

