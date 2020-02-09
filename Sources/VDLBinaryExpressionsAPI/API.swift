//
//  VDLBinaryExpressionsAPI
//  API.swift
//
//
//  Created by Valeriano Della Longa on 06/02/2020.
//  Copyright (c) 2020 Valeriano Della Longa
//
// MARK: - Public API
/// Error thrown by  API when validating and/or evaluating binary operation expressions in either postfix or infix notation.
public enum BinaryExpressionError: Error {
    /// Expression is not valid.
    case notValid
}

extension Collection {
    /// Validates as a binary operation expression —if possible— in postfix notation.
    ///
    /// - returns: either an `Array` of `BinaryOperatorExpressionToken` ordered as a valid binary operation expression in postfix notation, or `nil` if the represented expression was not valid in either infix or postfix notations.
    public func validPostfix<T: BinaryOperatorProtocol>() -> [Self.Iterator.Element]?
        where Self.Iterator.Element == BinaryOperatorExpressionToken<T>
    {
            if _isValidPostfixNotation(expression: self) {
                
                return Array(self)
            }
            
            return try? _convertToRPN(infixExpression: self)
    }
    
    /// Validates as a binary operation expression —if possible— in infix notation.
    ///
    /// - returns: either an `Array` of `BinaryOperatorExpressionToken` ordered as a valid binary expression in infix notation, or `nil` if the represented expression was not valid in either infix or postfix notations.
    public func validInfix<T: BinaryOperatorProtocol>() -> [Self.Iterator.Element]?
        where Self.Iterator.Element == BinaryOperatorExpressionToken<T>
    {
        if _isValidInfixNotation(expression: self) {
            
            return Array(self)
        }
        
        return try? _convertFromRPNToInfix(expression: self)
    }

    /// Combines with the given `Collection` of `BinaryOperatorExpressionToken` into a valid binary operation expression in postfix notation using the given operation.
    ///
    /// - parameter using: the binary operation to use as operator.
    /// - parameter with: another `Collection` of `BinaryOperatorExpressionToken` to combine with, used as rightmost operand. It can be either in postfix or infix notation.
    /// - returns: an `Array` of `BinaryOperatorExpressionToken` ordered as a valid binary operation expression in postfix notation.
    /// - throws: `BinaryExpressionError.notValid` in case the combinig operation cannot be done (either self or given expression are not valid binary operation expression).
    public func postfixCombining<C: Collection, T: BinaryOperatorProtocol>(using operation: T, with rhs: C) throws -> [Self.Iterator.Element]
        where C.Iterator.Element == Self.Iterator.Element, Self.Iterator.Element == BinaryOperatorExpressionToken<T>
    {
        guard
            let lhsRPN = self.validPostfix(),
            let rhsRPN = rhs.validPostfix()
            else { throw BinaryExpressionError.notValid }
        
        return lhsRPN + rhsRPN + [.binaryOperator(operation)]
    }
    
    /// Evaluates the represented binary operation expression.
    ///
    /// - returns: the result from evaluating the represented binary operation expression.
    /// - throws: `BinaryExpressionError.notValid` in case the represented expression was not valid in either postfix or infix notation or an `Error` thrown by one of the binary operations applied while evaluating the result.
    public func evaluate<T: BinaryOperatorProtocol>() throws -> T.Operand
        where Self.Iterator.Element == BinaryOperatorExpressionToken<T>, T.Operand: RepresentableAsEmptyProtocol
    {
        guard
            let postfix = self.validPostfix()
            else { throw BinaryExpressionError.notValid }
        
        let evaluated = try _eval(postfix: postfix, shouldThrowOnFailingOp: true)
        
        return evaluated ?? T.Operand.empty()
    }
    
}

// MARK: - Helpers
func _isValidInfixNotation<C: Collection, T: BinaryOperatorProtocol>(expression: C) -> Bool
    where C.Iterator.Element == BinaryOperatorExpressionToken<T>
{
    guard
        !expression.isEmpty
        else { return true }
    
    guard
        let _ = try? _convertToRPN(infixExpression: expression)
        else { return false }
    
    return true
}

func _isValidPostfixNotation<C: Collection, T: BinaryOperatorProtocol>(expression: C) -> Bool
    where C.Iterator.Element == BinaryOperatorExpressionToken<T>
{
    do {
        let _ = try _eval(postfix: expression)
        
        return true
    } catch {
        
        return false
    }
}

func _convertFromRPNToInfix<C: Collection, T: BinaryOperatorProtocol>(expression: C) throws -> [BinaryOperatorExpressionToken<T>]
    where C.Iterator.Element == BinaryOperatorExpressionToken<T>
{
    typealias Token = C.Iterator.Element
    
    // Early return empty expression when given expression is empty
    guard
        !expression.isEmpty
        else { return [] }
    
    var stack = [_SubInfixExpression<T>]()
    
    // Iterate over tokens in the given expression:
    for token in expression {
        // Analyze the token for this iteration:
        switch token {
        case .operand:
            // It's an operand, hence let's put it in the stack
            // as a subinfix without main operator.
            let sub: _SubInfixExpression = (expression: [token], mainOperator: nil)
            stack.append(sub)
        case .binaryOperator(let op):
            // It's an operator, therefore let's pop two subinfix
            // from the stack.
            // In case there aren't two elements in the stack,
            // then given expression is not valid in postfix
            // notation
            guard
                let rhs = stack.popLast(),
                let lhs = stack.popLast()
                else { throw BinaryExpressionError.notValid }
            
            // Add brackets to the two subinfix according
            // to comparsions between this operand
            // and their main operator associativity and priority.
            let subLhs = try _addBracketsIfNeeded(subInfix: lhs, otherOperator: op)
            let subRhs = try _addBracketsIfNeeded(subInfix: rhs, otherOperator: op)
            // Create a new subinfix combining the two subinfix from
            // the stack and this operator.
            // Then put it in the stack.
            let subExpression = subLhs.expression + [token] + subRhs.expression
            let sub = (expression: subExpression, mainOperator: op)
            stack.append(sub)
        case .openingBracket:
            fallthrough
        case .closingBracket:
            // Found brackets, and they are not allowed
            // in the postfix notation.
            // Thus the given expression is not valid.
            throw BinaryExpressionError.notValid
        }
    }
    
    // Done iterating over tokens in the given expression.
    // At this point the stack should contain one element only which
    // is the expression converted in infix notation (as subinfix).
    // If it doesn't, then the given expression was not valid
    // (containig only operands, or too few operators).
    guard
        stack.count == 1
        else { throw BinaryExpressionError.notValid }
    
    // Return the result expression in in infix notation.
    return stack.popLast()!.expression
}

func _convertToRPN<C: Collection, T: BinaryOperatorProtocol>(infixExpression: C) throws -> [BinaryOperatorExpressionToken<T>]
    where C.Iterator.Element == BinaryOperatorExpressionToken<T>
{
    // Early return in case given collection is empty.
    guard
        !infixExpression.isEmpty
        else { return [] }
    
    typealias Token = C.Iterator.Element
    var postfix = [Token]()
    var stack = [Token]()
    var lastToken: Token? = nil
    
    // Loop over every token in the given collection
    MainFL: for token in infixExpression {
        // On every iteration the current  token must be validated
        // against the one from the previous iteration.
        // In this way we can address invalid infix notations.
        try _validate(infixChunk: (prev: lastToken, current: token))
        
        // Infix expression is valid so far, let's analyze the token
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
            // inside the stack:
            SubWL: while
                let peeked = stack.last
            {
                switch peeked {
                case .binaryOperator(let opY) where opY.hasPrecedenceInPostfixConversion(then: opX):
                    // The operator found in the stack must
                    // be placed in the infix expression before
                    // this one according to the comparsion of their
                    // associativity and priority.
                    // Let's pop it from the stack too.
                    postfix.append(peeked)
                    let _ = stack.popLast()
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
            // Done checkiong the stack for other operators that
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

func _validate<T: BinaryOperatorProtocol>(infixChunk:(prev: BinaryOperatorExpressionToken<T>?, current: BinaryOperatorExpressionToken<T>)) throws {
    // When there's no preceding token, then the chunk is valid.
    guard
        let prev = infixChunk.prev
        else { return }
    
    switch (prev, infixChunk.current) {
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

func _eval<C: Collection, T: BinaryOperatorProtocol>(postfix: C, shouldThrowOnFailingOp: Bool = false) throws -> BinaryOperatorExpressionToken<T>.Operand?
    where C.Iterator.Element == BinaryOperatorExpressionToken<T>
{
    typealias Token = C.Iterator.Element
    
    // Given expression is empty. Result is nil.
    guard
        !postfix.isEmpty
        else { return nil }
    
    var anOperatorFailed = false
    var stack = [Token.Operand]()
    
    // Iterate on every token in the given expression.
    for token in postfix {
        // Check on this iteration token
        switch token {
        case .operand(let operand):
            // It's an operand, it goes in the stack.
            stack.append(operand)
        case .binaryOperator(let binaryOp):
            // It's an operator. Get two operands from the stack.
            // In case there are not two operands left in the stack,
            // then the expression is not valid in postfix notation.
            guard
                let rhs = stack.popLast(),
                let lhs = stack.popLast()
                else { throw BinaryExpressionError.notValid }
            
            var partial: Token.Operand
            do {
                // calculate the result of this operation
                partial = try binaryOp.binaryOperation(lhs, rhs)
            } catch {
                // the opration failed…
                // …throw its error in case the caller had
                // flagged to do so.
                guard
                    shouldThrowOnFailingOp == false
                    else { throw error }
                
                // otherwise record that an operation failed
                // and use an operand as dummy result.
                anOperatorFailed = true
                partial = lhs
            }
            // put the result of this operation in the stack
            stack.append(partial)
        case .openingBracket:
            fallthrough
        case.closingBracket:
            // No brackets are allowed in the postfix notation:
            // the given expression is not valid.
            throw BinaryExpressionError.notValid
        }
    }
    
    // Done iterating over tokens in the given expression.
    // At this point the stack should contain one operand only which
    // is the result of the expression.
    // If it doesn't, then the given expression was not valid
    // (containig only operands, or too few operators).
    guard
        stack.count == 1
        else { throw BinaryExpressionError.notValid }
    
    // In case an operator has failed, we can discard the element
    // in the stack cause it won't be a valid result…
    if anOperatorFailed {
        // …though the postfix notation of the given expression
        // is valid, but its result won't be valid.
        let _ = stack.popLast()
    }
    
    // Return the result
    return stack.popLast()
}

/// Assumes that when `mainOperator != nil` it is really equal to the main operator of the `expression`.
/// Assumption is true while this type and the function
/// `_addBracketsIfNeeded(subInfix:otherOperator:)` are used inside this API.
typealias _SubInfixExpression<T: BinaryOperatorProtocol> = (expression: [BinaryOperatorExpressionToken<T>], mainOperator: T?)

func _addBracketsIfNeeded<T: BinaryOperatorProtocol>(subInfix: _SubInfixExpression<T>, otherOperator: T) throws ->  _SubInfixExpression<T> {
    guard
        let subMainOp = subInfix.mainOperator
        else {
            guard
                subInfix.expression.count == 1,
                case .operand = subInfix.expression.first!
                else { throw BinaryExpressionError.notValid }
            
            return subInfix
    }
    
    guard
        subInfix.expression.count > 1,
        _isValidInfixNotation(expression: subInfix.expression)
        else { throw BinaryExpressionError.notValid }
    
    guard
        subMainOp.priority < otherOperator.priority
        else { return subInfix }
    
    let newInfix: [BinaryOperatorExpressionToken<T>] = [.openingBracket] + subInfix.expression + [.closingBracket]
    
    return (expression: newInfix, mainOperator: subInfix.mainOperator)
}

