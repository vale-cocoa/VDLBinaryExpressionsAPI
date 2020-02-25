//
//  VDLBinaryExpressionsAPI
//  Collection+PostfixValidation.swift
//  
//
//  Created by Valeriano Della Longa on 20/02/2020.
//  Copyright (c) 2020 Valeriano Della Longa
//

import Foundation

extension Collection
{
    func isValidPostfixNotation<T: BinaryOperatorProtocol>()
        -> Bool
        where Self.Iterator.Element == BinaryOperatorExpressionToken<T>
    {
        // empty expressions are valid.
        guard
            !self.isEmpty
            else { return true }
        
        // Evaluate expression by mocking its content.
        // The evaluation will only throw when the expression is
        // not valid in postfix notation (contains brackets, operands
        // and operators are not in the right amount in
        // each other respect nor in the right order).
        let dummy = try? self
            .postfixEvaluationByMapping(
                onOperandTransform: _Dummy._transformOperand(_:),
                onOperatorTransform: _Dummy._transformOperator(_:)
        )
        
        // If the evaluation returned a value then expression was
        // in valid postfix notation, otherwise it wasn't.
        return dummy != nil
        
    }
    
}

// This private type will be used internally for mapping
// postfixEvaluationByMapping(::) method so that it will
// execute the evaluation throwing only when the expression
// is not valid in postfix notation.
fileprivate enum _Dummy<T: BinaryOperatorProtocol> {
    typealias Operator = T
    
    typealias Operand = T.Operand

    case dummy
    
    // Operands will be mapped to this enum value
    static func _transformOperand(_ operand: Operand)
        throws -> _Dummy
    {
        return .dummy
    }
    
    // Operators will be mapped to a binary function which always
    // returns this enum value.
    // That is, operations in the expression are just mocked
    // hence will never fail nor time will be spent on their
    // computation.
    static func _transformOperator(_ binaryOperator: Operator)
        throws -> BinaryOperation<_Dummy>
    {
        return { _, _ in
            return .dummy
        }
    }
    
}
