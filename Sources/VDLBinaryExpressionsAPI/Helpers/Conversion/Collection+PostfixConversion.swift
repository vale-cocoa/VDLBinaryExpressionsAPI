//
//  VDLBinaryExpressionsAPI
//  Collection+PostfixConversion.swift
//  
//
//  Created by Valeriano Della Longa on 20/02/2020.
//  Copyright (c) 2020 Valeriano Della Longa
//

import Foundation

extension Collection {
    /// Supposed to be called on infix expressions. When called on expressions already in
    /// postfix notation, it'll throw.
    /// No need to change this behavior since it is used internally and only with the
    /// purpose of attempting to convert to postfix those expressions which are not in that notation
    /// already.
    func convertToPostfixNotation<T: BinaryOperatorProtocol>()
        throws -> [Self.Iterator.Element]
    where Self.Iterator.Element == BinaryOperatorExpressionToken<T>
    {
        // Function internal helpers
        typealias Operator = T
        
        typealias Operand = Operator.Operand
        
        typealias Token = Self.Iterator.Element
        
        typealias _InfixChunk = (previousToken: Token?, currentToken: Token)
        
        func _validate(infixChunk: _InfixChunk) throws {
            switch (infixChunk.previousToken, infixChunk.currentToken) {
           // When there's no preceding token, then the chunk is valid.
            case (nil, _):
                return
            case (.openingBracket, .operand):
                // i.e. "( 10" IS VALID!
                return
            case (.binaryOperator, .operand):
                // i.e. "+ 10" IS VALID!
                return
            case (.operand, .binaryOperator):
                // i.e. "10 +" IS VALID!
                return
            case (.closingBracket, .binaryOperator):
                // i.e. ") +" IS VALID!
                return
            case (.openingBracket, .openingBracket):
                // i.e. "( (" IS VALID!
                return
            case (.binaryOperator, .openingBracket):
                // i.e. "+ (" IS VALID!
                return
            case (.operand, .closingBracket):
                // i.e. "10 )" IS VALID!
                return
            case (.closingBracket, .closingBracket):
                // i.e. ") )" IS VALID!
                return
            case (.closingBracket, .openingBracket):
                // i.e. ") (" NOT VALID!
                throw BinaryExpressionError.notValid
            case (.closingBracket, .operand):
                // i.e. ") 10" NOT VALID!
                throw BinaryExpressionError.notValid
            case (.operand, .openingBracket):
                // i.e. "10 (" NOT VALID!
                throw BinaryExpressionError.notValid
            case (.operand, .operand):
                // i.e. "10 20" NOT VALID!
                throw BinaryExpressionError.notValid
            case (.binaryOperator, .closingBracket):
                // i.e. "+ )" NOT VALID!
                throw BinaryExpressionError.notValid
            case (.binaryOperator, .binaryOperator):
                // i.e. "+ *" NOT VALID!
                throw BinaryExpressionError.notValid
            case (.openingBracket, .closingBracket):
                // i.e. "( )" NOT VALID!
                throw BinaryExpressionError.notValid
            case (.openingBracket, .binaryOperator):
                // i.e. "( +" NOT VALID!
                throw BinaryExpressionError.notValid
            }
        }
        
        // End of function's helpers
        
        // Early return in case given collection is empty.
        guard
            !self.isEmpty
            else { return [] }
        
        var postfix = [Token]()
        var stack = [Token]()
        var lastToken: Token? = nil
        
        // Loop over every token in the collection
        MainFL: for token in self {
            // On every iteration the current token must be validated
            // against the one from the previous iteration.
            // In this way we can address invalid infix notations.
            try _validate(infixChunk: (lastToken, token))
            
            // Infix expression is valid so far, let's check the token
            // for this iteration:
            switch token {
            case .operand( _):
                // operand goes straight in the final postfix expression
                postfix.append(token)
            case .openingBracket:
                // An opening bracket goes in the stack.
                stack.append(token)
            case .closingBracket:
                // A closing braket signals the end of a possible
                // subexpression.
                // Though we pop tokens in the stack…
                while let popped = stack.popLast() {
                    switch popped {
                    case .openingBracket:
                        // Found the matching open paranthesis: done.
                        lastToken = token
                        continue MainFL
                    case .binaryOperator( _):
                        // Append the operator to the final postfix expression.
                        postfix.append(popped)
                    case .operand( _):
                        fallthrough
                    case .closingBracket:
                        // Operands and closing parethensis are
                        // NOT supposed to be in the stack.
                        // This branch should never execute in this
                        // algorithm.
                        fatalError("Ooops… \(token) should not be in the operators stack!")
                    }
                }
                // Popped all tokens in the stack:
                // a matching opening bracket was not found, therefore
                // the whole expression is not valid.
                throw BinaryExpressionError.notValid
            case .binaryOperator(let opX):
                // An operator signals we have to first check
                // inside the stack for operators that should
                // be placed before this one in the final expression.
                SubWL: while
                    let peeked = stack.last
                {
                    switch peeked {
                    case .binaryOperator(let opY) where opY.goesBeforeInPostfixConversion(than: opX):
                        // The operator found in the stack must
                        // be placed in the postfix expression before
                        // this one according to their associativity
                        // and priority.
                        // Let's pop it from the stack too.
                        postfix.append(peeked)
                        _ = stack.popLast()
                    case .binaryOperator:
                        // The operator in the stack goes after this one
                        // in the postfix expression according to the
                        // comparsion of their associativity and
                        // priority.
                        // We can stop peeking the stack.
                        break SubWL
                    case .openingBracket:
                        // An opening bracket in the stack means this
                        // token has to be placed before the other ones
                        // in the stack.
                        // We can stop peeking the stack.
                        break SubWL
                    case .closingBracket:
                        fallthrough
                    case .operand(_):
                        // Operands and closing parethensis are
                        // NOT supposed to be in the stack.
                        // This branch should never execute in this
                        // algorithm.
                        fatalError("Ooops… \(peeked) should not be in the operators stack!")
                    }
                }
                // Done checking the stack for other operators that
                // should appear before this one in the final postfix
                // expression. We can put this operator in the stack.
                stack.append(token)
            }
            // Done checking the token for this iteration.
            // We can save it as the last one for the next iteration
            // checkings.
            lastToken = token
        }
        
        // Done analyzing all tokens in the infix expression.
        // At this point the postfix expression can't be empty,
        // otherwise the infix expression was not valid
        // (containing only operators and or parenthesis).
        guard
            !postfix.isEmpty
            else { throw BinaryExpressionError.notValid }
        
        // Let's pop every operator left in the stack at add them to the
        // final postfix expression.
        while let popped = stack.popLast() {
            // At this point the stack should only contain operators
            // and not opening parenthesis.
            // In case an open parenthesis is found then the infix
            // expression was not valid missing one or more closing
            // parenthesis.
            guard
                case .binaryOperator( _) = popped
                else { throw BinaryExpressionError.notValid }
            
            postfix.append(popped)
        }
        
        // Infix expression was valid, return the postfix notation.
        return postfix
    }
    
}
