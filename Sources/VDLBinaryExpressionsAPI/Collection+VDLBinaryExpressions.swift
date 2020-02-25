//
//  VDLBinaryExpressionsAPI
//  Collection+VDLBinaryExpressions.swift
//
//
//  Created by Valeriano Della Longa on 06/02/2020.
//  Copyright (c) 2020 Valeriano Della Longa
//

import Foundation

// MARK: - Public API
extension Collection {
    /// Validates as a binary operation expression —if possible— in postfix notation and
    /// returns an `Array` containing the elements of the callee collection to form the
    /// equivalent binary expression in postfix notation.
    ///
    /// - Returns: An `Array` containing the callee tokens ordered as
    /// a valid binary operation expression in postfix notation.
    /// `nil` if the callee collection elements are not in order to form a valid binary
    /// expression  in either infix or postfix notations.
    ///
    /// - Note: Bracket tokens —when present in the callee— will be removed, that is
    /// an expression in  postfix notation doesn't need them for establishing different
    /// evaluation priority of operands.
    public func validPostfix<T: BinaryOperatorProtocol>()
        -> [Self.Iterator.Element]?
        where Self.Iterator.Element == BinaryOperatorExpressionToken<T>
    {
        // When collection is already in valid postfix notation,
        // then just return an Array of its elements.
        guard
            !self.isValidPostfixNotation()
            else { return Array(self) }
        
        // Otherwise try to convert it to postfix notation.
        return try? self.convertToPostfixNotation()
    }
    
    /// Validates as a binary operation expression —if possible— in infix notation and
    /// returns an `Array` containing the elements of the callee collection to form the
    /// equivalent binary expression in infix notation.
    ///
    /// - Returns: An `Array` containing the callee tokens ordered as
    /// a valid binary operation expression in infix notation.
    /// `nil` if the callee collection elements are not in order to form a valid binary
    /// expression  in either infix or postfix notations.
    ///
    /// - Note: in case the callee collection elements are ordered in infix notation,
    /// bracket tokens not necessary for the priority and associaticity operators order will be
    /// removed from the returned expression.
    /// On the other hand, if the callee collection elements are ordered in postfix notation,
    ///  then bracket token might be added to the result when needed for the operators
    ///  associativity and priority order.
    public func validInfix<T: BinaryOperatorProtocol>()
        -> [Self.Iterator.Element]?
        where Self.Iterator.Element == BinaryOperatorExpressionToken<T>
    {
        
        return try? self.convertToInfixNotation()
    }
    
    /// Combines with the given non empty `Collection`  into a valid binary
    ///  expression in infix notation using the given operator.
    ///
    /// - Parameter by: The binary operation to use as operator
    ///
    /// - Parameter with: Another not empty `Collection` to combine with,
    /// used as righmost operand in the resulting expression. It can be either in postfix or
    ///  infix notation.
    ///
    /// - Returns: an `Array` of `BinaryOperatorExpressionToken`
    ///  ordered as a valid binary operation expression in infix notation.
    ///
    /// - Throws: `BinaryExpressionError.notValid` in case the combinig
    ///  operation cannot be done (either self and/or given expression are not valid binary
    ///  operation expression, or empty).
    ///
    /// - Note: both expressions (callee and the one given as parameter) must
    ///  not be empty and valid either in postfix or infix notations.
    public func infix<C: Collection, T: BinaryOperatorProtocol>
        (by operation: T, with rhs: C)
        throws -> [Self.Iterator.Element]
        where C.Iterator.Element == Self.Iterator.Element, Self.Iterator.Element == BinaryOperatorExpressionToken<T>
    {
        // Try to get the postfix result by using postfix(by:with:)
        let postfix = try self.postfix(by: operation, with: rhs)
        
        // Return it converted in infix notation using the
        // helper struct.
        return try! postfix.convertToInfixNotation()
    }
    
    /// Combines with the given not empty `Collection` into a valid binary operation
    /// expression in postfix notation using the given operation.
    ///
    /// - Parameter by: the binary operation to use as operator.
    ///
    /// - Parameter with: another not empty `Collection` to combine with, used
    ///  as rightmost operand in the resulting expression. It can be either in postfix or
    ///  infix notation.
    ///
    /// - Returns: an `Array` of `BinaryOperatorExpressionToken`
    ///  ordered as a valid binary operation expression in postfix notation.
    ///
    /// - Throws: `BinaryExpressionError.notValid` in case the
    ///  combinig operation cannot be done (either self or given expression are not valid
    ///  binary operation expression or empty).
    ///
    /// - Note: both expressions (callee and the one given as parameter) must
    ///  not be empty and valid either in postfix or infix notations.
    public func postfix<C: Collection, T: BinaryOperatorProtocol>
        (by operation: T, with rhs: C)
        throws -> [Self.Iterator.Element]
        where C.Iterator.Element == Self.Iterator.Element, Self.Iterator.Element == BinaryOperatorExpressionToken<T>
    {
        guard
            let lhsRPN = self.validPostfix(),
            let rhsRPN = rhs.validPostfix(),
            !lhsRPN.isEmpty,
            !rhsRPN.isEmpty
            else { throw BinaryExpressionError.notValid }
        
        return lhsRPN + rhsRPN + [.binaryOperator(operation)]
    }

    /// Returns the result from evaluating the calee as binary expression.
    ///
    /// - Returns: The result from evaluating the binary expression.
    /// - Throws: `BinaryExpressionError.notValid` in case the callee
    ///  collection is not a valid binary expression in either postfix or infix notation.
    public func evaluated<T: BinaryOperatorProtocol>()
        throws -> T.Operand
        where
        Self.Iterator.Element == BinaryOperatorExpressionToken<T>,
        T.Operand: RepresentableAsEmptyProtocol
    {
        // try to get the collection in postfix notation via
        // helper struct in case it is not already in postfix notation.
        let postfix = self.isValidPostfixNotation() ? Array(self) : try self.convertToPostfixNotation()
        // when the obtained postfix notation expression is empty, then
        // return the empty value.
        guard
            !postfix.isEmpty
            else { return T.Operand.empty() }
        
        // Otherwise calculate the result
        // via postfixEvaluationByMapping(::) method.
        // We use the very same operands values and the binaryOperation
        // stored by each operator for the mapping.
        let result = try postfix
            .postfixEvaluationByMapping(
                onOperandTransform: { $0 },
                onOperatorTransform: { $0.binaryOperation }
        )
        
        return result
    }
    
}

