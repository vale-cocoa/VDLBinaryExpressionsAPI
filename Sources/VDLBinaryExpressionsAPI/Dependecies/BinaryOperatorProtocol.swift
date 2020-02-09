//
//  BinaryOperatorProtocol.swift
//  
//
//  Created by Valeriano Della Longa on 06/02/2020.
//

import Foundation
/// A protocol defining a type representing operators for semigroup binary functions executable over its associated type.
public protocol BinaryOperatorProtocol {
    /// The associated type over which the binary operations are executable.
    associatedtype Operand
    
    /// The binary operation represented by the operator.
    var binaryOperation: (Operand, Operand) throws -> Operand { get }
    
    /// The priority of this operator.
    var priority: Int { get }
    
    /// The direction for the associativity of the operation.
    var associativity: BinaryOperatorAssociativity { get }
}

extension BinaryOperatorProtocol {
    func hasPrecedenceInPostfixConversion(then other: Self) -> Bool {
        switch other.associativity {
        case .left:
            
            return other.priority <= self.priority
        case .right:
            
            return other.priority < self.priority
        }
    }
}
