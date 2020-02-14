//
//  VDLBinaryExpressionsAPI
//  API.swift
//
//
//  Created by Valeriano Della Longa on 06/02/2020.
//  Copyright (c) 2020 Valeriano Della Longa
//

import Foundation

// MARK: - Public API
/// Error thrown by  API when validating and/or evaluating binary operation expressions in either postfix or infix notation.
public enum BinaryExpressionError: Error {
    /// Expression is not valid.
    case notValid
}

extension Collection {
    /// Validates as a binary operation expression —if possible— in postfix notation.
    ///
    /// - returns: either an `Array` of `BinaryOperatorExpressionToken` ordered as a valid binary operation expression in postfix notation, or `nil` if the expression is not valid in either infix or postfix notations.
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
    /// - returns: either an `Array` of `BinaryOperatorExpressionToken` ordered as a valid binary expression in infix notation, or `nil` if the expression is not valid in either infix or postfix notations.
    public func validInfix<T: BinaryOperatorProtocol>() -> [Self.Iterator.Element]?
        where Self.Iterator.Element == BinaryOperatorExpressionToken<T>
    {
        if _isValidInfixNotation(expression: self) {
            
            return Array(self)
        }
        
        return try? _convertFromRPNToInfix(expression: self)
    }
    /// Combines with the given non empty `Collection` of `BinaryExpressionToken` into a valid binary expression in infix notation using the given operator.
    ///
    /// - parameter by: the binary operation to use as operator
    /// - parameter with: another not empty `Collection` of `BinaryOperatorExpressionToken` to combine with, used as righmost operand. It can be either in postfix or infix notation.
    /// - returns: an `Array` of `BinaryOperatorExpressionToken` ordered as a valid binary operation expression in infix notation.
    /// - throws: `BinaryExpressionError.notValid` in case the combinig operation cannot be done (either self or given expression are not valid binary operation expression, or empty).
    /// - note: both expressions (callee and the one given as parameter) must not be empty and valid either in postfix or infix notations.
    public func infix<C: Collection, T: BinaryOperatorProtocol>(by operation: T, with rhs: C) throws -> [Self.Iterator.Element]
        where C.Iterator.Element == Self.Iterator.Element, Self.Iterator.Element == BinaryOperatorExpressionToken<T>
    {
        let lhsSubInfix = try _subInfix(fromInfix: self)
        let rhsSubInfix = try _subInfix(fromInfix: rhs)
        
        let result = try _subInfix(lhs: lhsSubInfix, by: operation, rhs: rhsSubInfix)
        
        return result.expression
    }
    
    /// Combines with the given not empty `Collection` of `BinaryOperatorExpressionToken` into a valid binary operation expression in postfix notation using the given operation.
    ///
    /// - parameter by: the binary operation to use as operator.
    /// - parameter with: another not empty `Collection` of `BinaryOperatorExpressionToken` to combine with, used as rightmost operand. It can be either in postfix or infix notation.
    /// - returns: an `Array` of `BinaryOperatorExpressionToken` ordered as a valid binary operation expression in postfix notation.
    /// - throws: `BinaryExpressionError.notValid` in case the combinig operation cannot be done (either self or given expression are not valid binary operation expression or empty).
    /// - note: both expressions (callee and the one given as parameter) must not be empty and valid either in postfix or infix notations.
    public func postfix<C: Collection, T: BinaryOperatorProtocol>(by operation: T, with rhs: C) throws -> [Self.Iterator.Element]
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

// MARK: - Internal API
// MARK: - Notation validation helpers
func _isValidInfixNotation<C: Collection, T: BinaryOperatorProtocol>(expression: C) -> Bool
    where C.Iterator.Element == BinaryOperatorExpressionToken<T>
{
    guard
        !expression.isEmpty
        else { return true }
    
    do {
        let _ = try _convertToRPN(infixExpression: expression)
        
        return true
    } catch {
        
        return false
    }
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

// MARK: - Conversion between notations helpers
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
            
            // Create a new subinfix combining the two subinfix from
            // the stack and this operator and add brackets to them
            // when needed.
            let subResult = try _subInfix(lhs: lhs, by: op, rhs: rhs)
            
            // Then put it in the stack.
            stack.append(subResult)
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

// MARK: - Subhelpers
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

// MARK: - SubInfixExpression
typealias _SubInfixExpression<T: BinaryOperatorProtocol> = (expression: [BinaryOperatorExpressionToken<T>], mainOperator: T?)

func _subInfix<C: Collection, T: BinaryOperatorProtocol>(fromInfix expression: C) throws -> _SubInfixExpression<T>
    where C.Iterator.Element == BinaryOperatorExpressionToken<T>
{
    // Early return in case expression is empty
    guard
        !expression.isEmpty
        else {
            return ([], nil) }
    
    // Early check on expression validity
    guard
        let postfix = expression.validPostfix()
        else { throw BinaryExpressionError.notValid }
    
    // Early return in case expression was just an operand.
    if postfix.count == 1 { return ([postfix.first!], nil) }
    
    // Check if given expression is a postfix.
    // Here the expression was already checked as being valid
    // and containing an operation rather than just an operand.
    // We throw an error if it was given in postfix expression,
    // since we use this method for building infix expressions from
    // postfix.
    guard
        !_isValidPostfixNotation(expression: expression)
        else { throw BinaryExpressionError.notValid }
    
    // Get the main operator of the infix expression:
    var mainOperator: T? = nil
    if case .binaryOperator(let concrete) = postfix.last {
        mainOperator = concrete
    } else {
        // This branch should never execute.
        fatalError("The postfix conversion didn't had an operator as its last token.")
    }
    
    // return result
    return (Array(expression), mainOperator)
}

// TODO: TESTS!
// Maybe it should also check for validity of given SubInfix…
// which means convert its expression to postfix,
// get if exits the main operator from the postfix expression
// and compare it with the one stored in the subinfix…
// …which can be done only when T: Equatable, meaning it wouldn't
// be useful at all!
// The problem is that to test these methods on this type,
// stuff has to be internal, otherwise I would have this stuff
// private… I might as well do that later on.
// Oh wait… I got it! I could make things different for the
// master and develop branches… Is that even possible?
// The idea is: have the master branch keep this stuff private,
// hence in it only major tests for the public API will exist
// then have the development branch keeping this stuff internal
// with their tests…
func _subInfix<T>(lhs: _SubInfixExpression<T>, by operation: T, rhs:  _SubInfixExpression<T>) throws -> _SubInfixExpression<T>
    where T: BinaryOperatorProtocol {
        typealias SubInfix = _SubInfixExpression<T>
        typealias Token = BinaryOperatorExpressionToken<T>
        guard
            !lhs.expression.isEmpty,
            !rhs.expression.isEmpty,
            _isValidInfixNotation(expression: lhs.expression),
            _isValidInfixNotation(expression: rhs.expression)
            else { throw BinaryExpressionError.notValid }
        
        func _putBrackets(on infixExpression: [Token])
            -> [Token]
        {
            if infixExpression.count == 1
            {
                return infixExpression
            } else if
                case .openingBracket = infixExpression.first!,
                case .closingBracket = infixExpression.last!
            {
                return infixExpression
            }
            
            return [.openingBracket] + infixExpression + [.closingBracket]
        }
        
        var lhsExpr = lhs.expression
        var rhsExpr = rhs.expression
        switch (lhs.mainOperator?.associativity, operation.associativity, rhs.mainOperator?.associativity) {
        // lhs and rhs are both operand
        case (nil, _, nil):
            break
        
        // lhs is operand, rhs is expression.
        case (nil, .left, .some(_)):
            rhsExpr = operation.priority > rhs.mainOperator!.priority ? _putBrackets(on: rhs.expression) : rhs.expression
        case (nil, .right, .some(_)):
            rhsExpr = operation.priority >= rhs.mainOperator!.priority ? _putBrackets(on: rhs.expression) : rhs.expression
        
        // lhs is expression, rhs is operand.
        case (.some(_), _, nil):
            lhsExpr = operation.priority > lhs.mainOperator!.priority ? _putBrackets(on: lhs.expression) : lhs.expression
        
        // lhs and rhs are expressions.
        // Operation is left associative
        case (.some(_), .left, .some(_)):
            lhsExpr = operation.priority > lhs.mainOperator!.priority ? _putBrackets(on: lhs.expression) : lhs.expression
            rhsExpr = operation.priority > rhs.mainOperator!.priority ? _putBrackets(on: rhs.expression) : rhs.expression
        
        // lhs and rhs are expressions.
        // Operation is right associative
        case (.some(_), .right, .some(_)):
            lhsExpr = operation.priority > lhs.mainOperator!.priority ? _putBrackets(on: lhs.expression) : lhs.expression
            rhsExpr = operation.priority >= rhs.mainOperator!.priority ? _putBrackets(on: rhs.expression) : rhs.expression
        }
        
        let combinedExpression: [Token] = lhsExpr + [.binaryOperator(operation)] + rhsExpr
        
        return (combinedExpression, operation)
}


