//
//  VDLBinaryExpressionsAPI
//  Collection+PostfixEvaluationMapped.swift
//  
//
//  Created by Valeriano Della Longa on 20/02/2020.
//  Copyright (c) 2020 Valeriano Della Longa
//

import Foundation

extension Collection {
    /// Performs a postfix evaluation of the contained elements, mapping operands
    /// via the given `onOperandTransform` closure and mapping
    /// operators to binary operations via the given `onOperatorEvaluator` closure.
    ///
    /// Evaluation of a postfix expression is done by iterating over every token contained in it,
    /// and by using a stack to store operands, which will then be popped out in couples every
    /// time an operator token is found, The operator will then be applied to the two operands,
    /// and the result will then be stored again in the stack. By the end of this iteration, the stack
    /// should contain only one operand element which is the result of the evaluation.
    ///
    /// This method does this kind of evaluation in a generic fashion:
    /// * when an operand token is evaluated, it maps its associated value
    /// to `MappedOperand` concrete type using the given
    /// `onOperandTransform` closure and then stores it into the stack;
    /// * when an operator token is evaluated, it maps its associated value to a
    /// `BinaryOperation<MappedOperand>` using the given
    /// `onOperatorTransform` closure.
    ///  The resulting `BinaryOperation` will then be applied to the first two
    ///  elements popped off the stack .
    ///
    /// For example using it in the following way,  will use the same type of `Operand`
    /// associated to operand tokens, and the very same binary operation
    ///  associated to an operator token:
    /// ```swift
    /// let result = try expression.postfixEvaluationByMapping(
    ///     onOperandTransform: {$0},
    ///     onOperatorTransform: { $0.binaryOperation }
    ///     )
    /// ```
    ///
    /// - Parameter onOperandTransform: The closure used to map every contained
    /// instance of concrete`Operand` to a corresponding instance of
    /// the concrete `MappedOperand` type.
    ///
    /// - Parameter onOperatorTransform: The closure used to map every contained
    /// instance of concrete `Operator` type into a corresponding binary operation closure
    /// applicable to instances of `MappedOperand` concrete type.
    ///
    /// - Returns: The result of `MappedOperand` concrete type for the evaluation as
    /// postfix expression of the content, opportunely mapping each `Operand` to `MappedOperand` and each `Operator` to a binary operation.
    ///
    /// - Throws:`BinaryExpressionError.notValid` when empty or when the
    /// content is not an expression valid in postfix notation.
    /// Note that an expression containig either `.openingBracket` or
    /// `.closingBracket` tokens is also not valid in postfix notation.
    /// Rethrows errors eventually thrown by the given closure when mapping an operand
    /// to a `MappedOperand`.
    /// Rethrows errors eventually thrown by the given closure when mapping an operator
    /// to a `BinaryExpression<MapOperand>`.
    /// Rethrows errors eventually thrown by `BinaryExpression<MapOperand>`
    /// when applied.
    ///
    /// - Complexity: O(n)
    func postfixEvaluationByMapping<Operator: BinaryOperatorProtocol, MappedOperand>(
        onOperandTransform: @escaping (Self.Iterator.Element.Operand) throws -> MappedOperand,
        onOperatorTransform: @escaping (Operator) throws -> BinaryOperation<MappedOperand>
    ) throws -> MappedOperand
        where Self.Iterator.Element == BinaryOperatorExpressionToken<Operator>
    {
        // Empty postfix expressions cannot be evaluated.
        guard
            !self.isEmpty
            else { throw BinaryExpressionError.notValid }
        
        // the stack contanining the operands (mapped)
        var stack = [MappedOperand]()
        // Iterate on every token of the postfix expression
        for token in self {
            switch token {
            case .operand(let concreteOperand):
                // try to map the operand to the result type
                let t = try onOperandTransform(concreteOperand)
                // then store it into the stack
                stack.append(t)
            
            case .binaryOperator(let concreteOperator):
                // try to get two operands from the stack,
                // otherwise the expression is not in valid postfix
                // notation (contains too many operators)
                guard
                    let rhs = stack.popLast(),
                    let lhs = stack.popLast()
                    else { throw BinaryExpressionError.notValid }
                // try to map the operator to the destination type
                // binaryOperation
                let binaryOperation = try onOperatorTransform(concreteOperator)
                // try to calculate result for this operator
                let partial = try binaryOperation(lhs, rhs)
                // then store it in the stack
                stack.append(partial)
            default:
                // valid postfix expressions can contain only operand
                // and operator tokens.
                throw BinaryExpressionError.notValid
            }
        }
        // Result is last element left in the stack.
        // In case the stack doesn't contain any element, or more
        // than one, then the expression was not a valid postfix
        // (too many operands).
        guard
            let result = stack.popLast(),
            stack.isEmpty
            else { throw BinaryExpressionError.notValid }
        
        return result
    }
    
}
