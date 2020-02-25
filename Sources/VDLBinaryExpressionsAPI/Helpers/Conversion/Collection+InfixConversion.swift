//
//  VDLBinaryExpressionsAPI
//  Collection+InfixConversion.swift
//  
//
//  Created by Valeriano Della Longa on 20/02/2020.
//  Copyright (c) 2020 Valeriano Della Longa
//

import Foundation

extension Collection {
    func convertToInfixNotation<T: BinaryOperatorProtocol>()
        throws -> [Self.Iterator.Element]
    where Self.Iterator.Element == BinaryOperatorExpressionToken<T>
    {
        // Internal function helpers
        typealias Token = Self.Iterator.Element
        
        typealias Operand = T.Operand
        
        typealias Operator = T
        
        // Puts in bracket a given infix expression, then returns it.
        func _bracketed(_ infixExpression: [Token]) -> [Token] {
            return [.openingBracket] + infixExpression + [.closingBracket]
        }
        
        // Internal typealias which represents an infix epression
        // associated to its "main operator".
        // That is the "main operator" is the last operator applied
        // in the infix exmpression evaluation, hence the one to take
        // into account for bracketing when combining the expression
        // with another one via another operation.
        typealias _SubInfix = (infixExpression: [Token], mainOperator: Operator?)
        
        // Combine two _SubInfix by an operation, applying bracketing
        // where needed depending on operators precedence.
        func _subInfix
            (lhs: _SubInfix,
             by operation: Operator,
             rhs:  _SubInfix)
            -> _SubInfix
        {
                var lhsExpr = lhs.infixExpression
                var rhsExpr = rhs.infixExpression
                switch (lhs.mainOperator?.associativity,
                        operation.associativity,
                        rhs.mainOperator?.associativity
                    )
                {
                // lhs and rhs are both operand
                case (nil, _, nil):
                    break
                
                // lhs is expression, rhs is operand.
                // Operation is left associative
                case (.left, .left, nil):
                    lhsExpr = operation.priority > lhs.mainOperator!.priority ? _bracketed(lhs.infixExpression) : lhs.infixExpression
                
                case (.right, .left, nil):
                    lhsExpr = operation.priority < lhs.mainOperator!.priority ? _bracketed(lhs.infixExpression) : lhs.infixExpression
                
                // lhs is expression, rhs is operand.
                // Operation is right associative
                case (.some(_), .right, nil):
                    lhsExpr = operation.priority >= lhs.mainOperator!.priority ? _bracketed(lhs.infixExpression) : lhs.infixExpression
                    
                // lhs is operand, rhs is expression.
                // Operation is left associative
                case (nil, .left, .some(_)):
                    rhsExpr = operation.priority > rhs.mainOperator!.priority ? _bracketed(rhs.infixExpression) : rhs.infixExpression
                // lhs is operand, rhs is expression.
                // Operation is right associative
                case (nil, .right, .left):
                    rhsExpr = operation.priority >= rhs.mainOperator!.priority ? _bracketed(rhs.infixExpression) : rhs.infixExpression
                
                case (nil, .right, .right):
                rhsExpr = operation.priority < rhs.mainOperator!.priority ? _bracketed(rhs.infixExpression) : rhs.infixExpression
                    
                // lhs and rhs are expressions.
                // Operation is left associative
                case (.left, .left, .some(_)):
                    lhsExpr = operation.priority > lhs.mainOperator!.priority ? _bracketed(lhs.infixExpression) : lhs.infixExpression
                    rhsExpr = operation.priority > rhs.mainOperator!.priority ? _bracketed(rhs.infixExpression) : rhs.infixExpression
                
                case (.right, .left, .some(_)):
                    lhsExpr = operation.priority < lhs.mainOperator!.priority ? _bracketed(lhs.infixExpression) : lhs.infixExpression
                    rhsExpr = operation.priority > rhs.mainOperator!.priority ? _bracketed(rhs.infixExpression) : rhs.infixExpression
                
                // lhs and rhs are both expressions.
                // Operation is right associative
                case (.some(_), .right, .left):
                    lhsExpr = operation.priority >= lhs.mainOperator!.priority ? _bracketed(lhs.infixExpression) : lhs.infixExpression
                    rhsExpr = operation.priority >= rhs.mainOperator!.priority ? _bracketed(rhs.infixExpression) : rhs.infixExpression
                    
                case (.some(_), .right, .right):
                    lhsExpr = operation.priority >= lhs.mainOperator!.priority ? _bracketed(lhs.infixExpression) : lhs.infixExpression
                    rhsExpr = operation.priority < rhs.mainOperator!.priority ? _bracketed(rhs.infixExpression) : rhs.infixExpression
                }
                
                let combinedExpression: [Token] = lhsExpr + [Token.binaryOperator(operation)] + rhsExpr
                
                return (combinedExpression, operation)
        }
        
        // Map an operand to _SubInfix type by setting it as its
        // expression and by setting nil as the _SubInfix mainOperator.
        func _onOperandTransform
            (_ operand: Operand)
            throws -> _SubInfix
        {
            return ([.operand(operand)], nil)
        }
        
        // Map every operator to a binary expression which combines two
        // _SubInfix using the internal function _subInfix(lhs:by:rhs:)
        func _onOperatorTransform
            (_ binaryOperator: Operator)
            throws -> BinaryOperation<_SubInfix>
        {
            return { lhs, rhs in
                return _subInfix(lhs: lhs, by: binaryOperator, rhs: rhs)
            }
        }
        // End of internal function helpers
        
        // Either the calee is already in postfix notation, or try
        // to obtain it in postfix notation.
        // When this throws, then the callee was not valid in both
        // notations.
        let postfix = self.isValidPostfixNotation() ? Array(self) : try self.convertToPostfixNotation()
        
        // Early return: when it's empty or containing
        // just one operand.
        guard postfix.count > 1 else { return postfix }
        
        // Get a _SubInfix by doing the evaluation of the obtained
        // postfix expression.
        // The evaluation mapping is done by internal functions.
        let subInfix = try! postfix.postfixEvaluationByMapping(
            onOperandTransform: _onOperandTransform(_:),
            onOperatorTransform: _onOperatorTransform(_:))
        
        // return the expression.
        return subInfix.infixExpression
    }
    
}
