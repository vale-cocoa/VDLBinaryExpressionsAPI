//
//  VDLBinaryExpressionsAPITests
//  MockBinaryOperator+CommonExpressions.swift
//  
//
//  Created by Valeriano Della Longa on 18/02/2020.
//  Copyright (c) 2020 Valeriano Della Longa
//

import Foundation
import Foundation
import XCTest
@testable import VDLBinaryExpressionsAPI

typealias Token = BinaryOperatorExpressionToken<MockBinaryOperator>

extension MockBinaryOperator {
    typealias GivenExpressionAndValue<C: Collection> = (expression: C, value: Result<Self.Operand, Swift.Error>) where C.Iterator.Element == Token
    
    static func givenSimpleBinaryExpression(lhs: Operand, rhs: Operand, operation: Self, postfixNotation: Bool = true) -> GivenExpressionAndValue<AnyCollection<Token>>
    {
        let lhsToken: Token = .operand(lhs)
        let rhsToken: Token = .operand(rhs)
        let opToken: Token = .binaryOperator(operation)
        let expression = postfixNotation ? [lhsToken, rhsToken, opToken] : [lhsToken, opToken, rhsToken]
        let result: Result<Operand, Swift.Error>!
        do {
            let value = try operation.binaryOperation(lhs, rhs)
            result = .success(value)
        } catch {
            result = .failure(error)
        }
        
        return (AnyCollection(expression), result)
    }
    
    static func givenRandomInt() -> Int { .random(in: 1...100) }
    
    static func givenEmptyExpression() -> GivenExpressionAndValue<AnyCollection<Token>>
    {
        return (AnyCollection([Token]()), .success(0))
    }
    
    static func givenJustOperandExpression() -> GivenExpressionAndValue<AnyCollection<Token>>
    {
        let operand = givenRandomInt()
        return (AnyCollection([.operand(operand)]), .success(operand))
    }
    
    // MARK: - Simple binary expressions in postfix notation
    static func givenSimpleAdditionExpression(postfix: Bool = true) -> GivenExpressionAndValue<AnyCollection<Token>>
    {
        return givenSimpleBinaryExpression(lhs: givenRandomInt(), rhs: givenRandomInt(), operation: .add, postfixNotation: postfix)
    }
    
    static func givenSimpleMultiplicationExpression(postfix: Bool = true) -> GivenExpressionAndValue<AnyCollection<Token>>
    {
        return givenSimpleBinaryExpression(lhs: givenRandomInt(), rhs: givenRandomInt(), operation: .multiply, postfixNotation: postfix)
    }
    
    static func givenSimpleSubtractionExpression(postfix: Bool = true) -> GivenExpressionAndValue<AnyCollection<Token>>
    {
        return givenSimpleBinaryExpression(lhs: givenRandomInt(), rhs: givenRandomInt(), operation: .subtract, postfixNotation: postfix)
    }
    
    static func givenNotFailingSimpleDivisionExpression(postfix: Bool = true) -> GivenExpressionAndValue<AnyCollection<Token>>
    {
        return givenSimpleBinaryExpression(lhs: givenRandomInt(), rhs: givenRandomInt(), operation: .divide, postfixNotation: postfix)
    }
    static func givenFailingSimpleDivisionExpression(postfix: Bool = true) -> GivenExpressionAndValue<AnyCollection<Token>>
    {
        return givenSimpleBinaryExpression(lhs: givenRandomInt(), rhs: 0, operation: .divide, postfixNotation: postfix)
    }
    
    static func givenSimpleFailingOperationExpression(postfix: Bool = true) -> GivenExpressionAndValue<AnyCollection<Token>>
    {
        return givenSimpleBinaryExpression(lhs: givenRandomInt(), rhs: givenRandomInt(), operation: .failingOperation, postfixNotation: postfix)
    }
    
    static func givenSimpleBinaryOperationExpressions(postfix: Bool = true) -> [GivenExpressionAndValue<AnyCollection<Token>>] {
        return [
            givenEmptyExpression(),
            givenJustOperandExpression(),
            givenSimpleAdditionExpression(postfix: postfix),
            givenSimpleMultiplicationExpression(postfix: postfix),
            givenSimpleSubtractionExpression(postfix: postfix),
            givenNotFailingSimpleDivisionExpression(postfix: postfix),
            givenFailingSimpleDivisionExpression(postfix: postfix),
            givenSimpleFailingOperationExpression(postfix: postfix),
            
        ]
    }
    
}

// MARK: - infix expressions for operator precedence evaluation
extension MockBinaryOperator {
    // A + B + C
    static func givenInfixOperandAddOperandAddOperand() -> GivenExpressionAndValue<AnyCollection<Token>>
    {
        let a = givenRandomInt()
        let b = givenRandomInt()
        let c = givenRandomInt()
        
        let infix: [Token ] = [.operand(a), .binaryOperator(.add), .operand(b), .binaryOperator(.add), .operand(c)]
        
        return (AnyCollection(infix), .success(a + b + c))
    }
    
    // A + B * C
    static func givenInfixOperandAddOperandMultiplyOperand() -> GivenExpressionAndValue<AnyCollection<Token>>
    {
        let a = givenRandomInt()
        let b = givenRandomInt()
        let c = givenRandomInt()
        
        let infix: [Token ] = [.operand(a), .binaryOperator(.add), .operand(b), .binaryOperator(.multiply), .operand(c)]
        
        return (AnyCollection(infix), .success(a + b * c))
    }
    
    // A + B - C
    static func givenInfixOperandAddOperandSubtractOperand() -> GivenExpressionAndValue<AnyCollection<Token>>
    {
        let a = givenRandomInt()
        let b = givenRandomInt()
        let c = givenRandomInt()
        
        let infix: [Token ] = [.operand(a), .binaryOperator(.add), .operand(b), .binaryOperator(.subtract), .operand(c)]
        
        return (AnyCollection(infix), .success(a + b - c))
    }
    
    // A + B / C
    static func givenInfixOperandAddOperandDivideOperand() -> GivenExpressionAndValue<AnyCollection<Token>>
    {
        let a = givenRandomInt()
        let b = givenRandomInt()
        let c = givenRandomInt()
        
        let infix: [Token ] = [.operand(a), .binaryOperator(.add), .operand(b), .binaryOperator(.divide), .operand(c)]
        
        return (AnyCollection(infix), .success(a + b / c))
    }
    
    // A * B + C
    static func givenInfixOperandMultiplyOperandAddOperand() -> GivenExpressionAndValue<AnyCollection<Token>>
    {
        let a = givenRandomInt()
        let b = givenRandomInt()
        let c = givenRandomInt()
        
        let infix: [Token ] = [.operand(a), .binaryOperator(.multiply), .operand(b), .binaryOperator(.add), .operand(c)]
        
        return (AnyCollection(infix), .success(a * b + c))
    }
    
    // A * B * C
    static func givenInfixOperandMultiplyOperandMultiplyOperand() -> GivenExpressionAndValue<AnyCollection<Token>>
    {
        let a = givenRandomInt()
        let b = givenRandomInt()
        let c = givenRandomInt()
        
        let infix: [Token ] = [.operand(a), .binaryOperator(.multiply), .operand(b), .binaryOperator(.multiply), .operand(c)]
        
        return (AnyCollection(infix), .success(a * b * c))
    }
    
    // A * B - C
    static func givenInfixOperandMultiplyOperandSubtractOperand() -> GivenExpressionAndValue<AnyCollection<Token>>
    {
        let a = givenRandomInt()
        let b = givenRandomInt()
        let c = givenRandomInt()
        
        let infix: [Token ] = [.operand(a), .binaryOperator(.multiply), .operand(b), .binaryOperator(.subtract), .operand(c)]
        
        return (AnyCollection(infix), .success(a * b - c))
    }
    
    // A * B / C
    static func givenInfixOperandMultiplyOperandDivideOperand() -> GivenExpressionAndValue<AnyCollection<Token>>
    {
        let a = givenRandomInt()
        let b = givenRandomInt()
        let c = givenRandomInt()
        
        let infix: [Token ] = [.operand(a), .binaryOperator(.multiply), .operand(b), .binaryOperator(.divide), .operand(c)]
        
        return (AnyCollection(infix), .success(a * b / c))
    }
    
    // A - B + C
    static func givenInfixOperandSubtractOperandAddOperand() -> GivenExpressionAndValue<AnyCollection<Token>>
    {
        let a = givenRandomInt()
        let b = givenRandomInt()
        let c = givenRandomInt()
        
        let infix: [Token ] = [.operand(a), .binaryOperator(.subtract), .operand(b), .binaryOperator(.add), .operand(c)]
        
        return (AnyCollection(infix), .success(a - b + c))
    }
    
    // A - B * C
    static func givenInfixOperandSubtractOperandMultiplyOperand() -> GivenExpressionAndValue<AnyCollection<Token>>
    {
        let a = givenRandomInt()
        let b = givenRandomInt()
        let c = givenRandomInt()
        
        let infix: [Token ] = [.operand(a), .binaryOperator(.subtract), .operand(b), .binaryOperator(.multiply), .operand(c)]
        
        return (AnyCollection(infix), .success(a - b * c))
    }
    
    // A - B - C
    static func givenInfixOperandSubtractOperandSubtractOperand() -> GivenExpressionAndValue<AnyCollection<Token>>
    {
        let a = givenRandomInt()
        let b = givenRandomInt()
        let c = givenRandomInt()
        
        let infix: [Token ] = [.operand(a), .binaryOperator(.subtract), .operand(b), .binaryOperator(.subtract), .operand(c)]
        
        return (AnyCollection(infix), .success(a - b - c))
    }
    
    // A - B / C
    static func givenInfixOperandSubtractOperandDivideOperand() -> GivenExpressionAndValue<AnyCollection<Token>>
    {
        let a = givenRandomInt()
        let b = givenRandomInt()
        let c = givenRandomInt()
        
        let infix: [Token ] = [.operand(a), .binaryOperator(.subtract), .operand(b), .binaryOperator(.divide), .operand(c)]
        
        return (AnyCollection(infix), .success(a - b / c))
    }
    
    // A / B + C
    static func givenInfixOperandDivideOperandAddOperand() -> GivenExpressionAndValue<AnyCollection<Token>>
    {
        let a = givenRandomInt()
        let b = givenRandomInt()
        let c = givenRandomInt()
        
        let infix: [Token ] = [.operand(a), .binaryOperator(.divide), .operand(b), .binaryOperator(.add), .operand(c)]
        
        return (AnyCollection(infix), .success(a / b + c))
    }
    
    // A / * C
    static func givenInfixOperandDivideOperandMultiplyOperand() -> GivenExpressionAndValue<AnyCollection<Token>>
    {
        let a = givenRandomInt()
        let b = givenRandomInt()
        let c = givenRandomInt()
        
        let infix: [Token ] = [.operand(a), .binaryOperator(.divide), .operand(b), .binaryOperator(.multiply), .operand(c)]
        
        return (AnyCollection(infix), .success(a / b * c))
    }
    
    // A / - C
    static func givenInfixOperandDivideOperandSubtractOperand() -> GivenExpressionAndValue<AnyCollection<Token>>
    {
        let a = givenRandomInt()
        let b = givenRandomInt()
        let c = givenRandomInt()
        
        let infix: [Token ] = [.operand(a), .binaryOperator(.divide), .operand(b), .binaryOperator(.subtract), .operand(c)]
        
        return (AnyCollection(infix), .success(a / b - c))
    }
    
    // A / B / C
    static func givenInfixOperandDivideOperandDivideOperand() -> GivenExpressionAndValue<AnyCollection<Token>>
    {
        let a = givenRandomInt()
        let b = givenRandomInt()
        let c = givenRandomInt()
        
        let infix: [Token ] = [.operand(a), .binaryOperator(.divide), .operand(b), .binaryOperator(.divide), .operand(c)]
        
        return (AnyCollection(infix), .success(a / b / c))
    }
    
    static func givenValidInfixOfThreeOperandsTwoNotFailingOperators() -> [GivenExpressionAndValue<AnyCollection<Token>>]
    {
        return [
            givenInfixOperandAddOperandAddOperand(),
            givenInfixOperandAddOperandMultiplyOperand(),
            givenInfixOperandAddOperandSubtractOperand(),
            givenInfixOperandAddOperandDivideOperand(),
            givenInfixOperandMultiplyOperandAddOperand(),
            givenInfixOperandMultiplyOperandMultiplyOperand(),
            givenInfixOperandMultiplyOperandSubtractOperand(),
            givenInfixOperandMultiplyOperandDivideOperand(),
            givenInfixOperandSubtractOperandAddOperand(),
            givenInfixOperandSubtractOperandMultiplyOperand(),
            givenInfixOperandSubtractOperandSubtractOperand(),
            givenInfixOperandSubtractOperandDivideOperand(),
            givenInfixOperandDivideOperandAddOperand(),
            givenInfixOperandDivideOperandMultiplyOperand(),
            givenInfixOperandDivideOperandSubtractOperand(),
            givenInfixOperandDivideOperandDivideOperand()
        ]
    }
    
}
