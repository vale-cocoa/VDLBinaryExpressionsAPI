//
//  VDLBinaryExpressionsAPITests
//  MockDummyOperator+InfixConversionTests.swift
//  
//
//  Created by Valeriano Della Longa on 25/02/2020.
//  Copyright (c) 2020 Valeriano Della Longa
//

import Foundation
@testable import VDLBinaryExpressionsAPI

extension MockDummyOperator {
    private static func _NoneAnyAssociativityNone() -> [DummyTokenValidExpression]
    {
        var expressions = [DummyTokenValidExpression]()
        for op in Self.allCases {
            let opToken: DummyToken = .binaryOperator(op)
            let a: DummyToken = .operand(MockBinaryOperator.givenRandomInt())
            let b: DummyToken = .operand(MockBinaryOperator.givenRandomInt())
            
            let postfix: [DummyToken] = [a, b, opToken]
            let infix: [DummyToken] = [a, opToken, b]
            expressions.append((infix, postfix))
        }
        
        return expressions
    }
    
    private static func _LeftLeftNone() -> [DummyTokenValidExpression]
    {
        var expressions = [DummyTokenValidExpression]()
        
        let leftAssociativeOperations = Self.allCases
            .filter { $0.associativity == .left }
        for lhsOp in leftAssociativeOperations {
            let lhsToken: DummyToken = .binaryOperator(lhsOp)
            for op in leftAssociativeOperations {
                let opToken: DummyToken = .binaryOperator(op)
                
                let a: DummyToken = .operand(MockBinaryOperator.givenRandomInt())
                let b: DummyToken = .operand(MockBinaryOperator.givenRandomInt())
                let c: DummyToken = .operand(MockBinaryOperator.givenRandomInt())
                
                let postfix: [DummyToken] = [a, b, lhsToken, c, opToken]
                let infix: [DummyToken] = op.priority > lhsOp.priority ? [.openingBracket, a, lhsToken, b, .closingBracket, opToken, c] : [a, lhsToken, b, opToken, c]
                expressions.append((infix, postfix))
            }
        }
        
        return expressions
    }
    
    private static func _RightLeftNone() -> [DummyTokenValidExpression]
    {
        var expressions = [DummyTokenValidExpression]()
        
        let leftAssociativeOperations = Self.allCases
            .filter { $0.associativity == .left }
        let rightAssociativeOperations = Self.allCases
            .filter {$0.associativity == .right }
        for lhsOp in rightAssociativeOperations {
            let lhsToken: DummyToken = .binaryOperator(lhsOp)
            for op in leftAssociativeOperations {
                let opToken: DummyToken = .binaryOperator(op)
                
                let a: DummyToken = .operand(MockBinaryOperator.givenRandomInt())
                let b: DummyToken = .operand(MockBinaryOperator.givenRandomInt())
                let c: DummyToken = .operand(MockBinaryOperator.givenRandomInt())
                
                let postfix: [DummyToken] = [a, b, lhsToken, c, opToken]
                let infix: [DummyToken] = op.priority < lhsOp.priority ? [.openingBracket, a, lhsToken, b, .closingBracket, opToken, c] : [a, lhsToken, b, opToken, c]
                expressions.append((infix, postfix))
            }
        }
        
        return expressions
    }
    
    private static func _AnyAssociativityRightNone() -> [DummyTokenValidExpression]
    {
        var expressions = [DummyTokenValidExpression]()
        
        let rightAssociativeOperations = Self.allCases
            .filter {$0.associativity == .right }
        for lhsOp in Self.allCases {
            let lhsToken: DummyToken = .binaryOperator(lhsOp)
            for op in rightAssociativeOperations {
                let opToken: DummyToken = .binaryOperator(op)
                
                let a: DummyToken = .operand(MockBinaryOperator.givenRandomInt())
                let b: DummyToken = .operand(MockBinaryOperator.givenRandomInt())
                let c: DummyToken = .operand(MockBinaryOperator.givenRandomInt())
                
                let postfix: [DummyToken] = [a, b, lhsToken, c, opToken]
                let infix: [DummyToken] = op.priority >= lhsOp.priority ? [.openingBracket, a, lhsToken, b, .closingBracket, opToken, c] : [a, lhsToken, b, opToken, c]
                expressions.append((infix, postfix))
            }
        }
        
        return expressions
    }
    
    private static func _NoneLeftAnyAssociativity() -> [DummyTokenValidExpression]
    {
        var expressions = [DummyTokenValidExpression]()
        
        let leftAssociativeOperations = Self.allCases
            .filter { $0.associativity == .left }
        for rhsOp in Self.allCases {
            let rhsToken: DummyToken = .binaryOperator(rhsOp)
            for op in leftAssociativeOperations {
                let opToken: DummyToken = .binaryOperator(op)
                
                let a: DummyToken = .operand(MockBinaryOperator.givenRandomInt())
                let b: DummyToken = .operand(MockBinaryOperator.givenRandomInt())
                let c: DummyToken = .operand(MockBinaryOperator.givenRandomInt())
                
                let postfix: [DummyToken] = [a, b, c, rhsToken, opToken]
                let infix: [DummyToken] = op.priority > rhsOp.priority ? [a, opToken, .openingBracket, b, rhsToken, c, .closingBracket,] : [a, opToken, b, rhsToken, c]
                expressions.append((infix, postfix))
            }
        }
        
        return expressions
    }
    
    private static func _NoneRightLeft() -> [DummyTokenValidExpression]
    {
        var expressions = [DummyTokenValidExpression]()
        
        let leftAssociativeOperations = Self.allCases
            .filter { $0.associativity == .left }
        let rightAssociativeOperations = Self.allCases
            .filter {$0.associativity == .right }
        for rhsOp in leftAssociativeOperations {
            let rhsToken: DummyToken = .binaryOperator(rhsOp)
            for op in rightAssociativeOperations {
                let opToken: DummyToken = .binaryOperator(op)
                
                let a: DummyToken = .operand(MockBinaryOperator.givenRandomInt())
                let b: DummyToken = .operand(MockBinaryOperator.givenRandomInt())
                let c: DummyToken = .operand(MockBinaryOperator.givenRandomInt())
                
                let postfix: [DummyToken] = [a, b, c, rhsToken, opToken]
                let infix: [DummyToken] = op.priority >= rhsOp.priority ? [a, opToken, .openingBracket, b, rhsToken, c, .closingBracket,] : [a, opToken, b, rhsToken, c]
                expressions.append((infix, postfix))
            }
        }
        
        return expressions
    }
    
    private static func _NoneRightRight() -> [DummyTokenValidExpression]
    {
        var expressions = [DummyTokenValidExpression]()
        
        let rightAssociativeOperations = Self.allCases
            .filter {$0.associativity == .right }
        for rhsOp in rightAssociativeOperations {
            let rhsToken: DummyToken = .binaryOperator(rhsOp)
            for op in rightAssociativeOperations {
                let opToken: DummyToken = .binaryOperator(op)
                
                let a: DummyToken = .operand(MockBinaryOperator.givenRandomInt())
                let b: DummyToken = .operand(MockBinaryOperator.givenRandomInt())
                let c: DummyToken = .operand(MockBinaryOperator.givenRandomInt())
                
                let postfix: [DummyToken] = [a, b, c, rhsToken, opToken]
                let infix: [DummyToken] = op.priority < rhsOp.priority ? [a, opToken, .openingBracket, b, rhsToken, c, .closingBracket,] : [a, opToken, b, rhsToken, c]
                expressions.append((infix, postfix))
            }
        }
        
        return expressions
    }
    
    private static func _LeftLeftAnyAssociativity() -> [DummyTokenValidExpression]
    {
        var expressions = [DummyTokenValidExpression]()
        
        let leftAssociativeOperations = Self.allCases
            .filter { $0.associativity == .left }
        for lhsOp in leftAssociativeOperations
        {
            let lhsToken: DummyToken = .binaryOperator(lhsOp)
            for op in  leftAssociativeOperations
            {
                let opToken: DummyToken = .binaryOperator(op)
                for rhsOp in Self.allCases
                {
                    let rhsToken: DummyToken = .binaryOperator(rhsOp)
                    
                    let a: DummyToken = .operand(MockBinaryOperator.givenRandomInt())
                    let b: DummyToken = .operand(MockBinaryOperator.givenRandomInt())
                    let c: DummyToken = .operand(MockBinaryOperator.givenRandomInt())
                    let d: DummyToken = .operand(MockBinaryOperator.givenRandomInt())
                    
                    let postfix: [DummyToken] = [a, b, lhsToken, c, d, rhsToken, opToken]
                    
                    let lhsInfix: [DummyToken] = op.priority > lhsOp.priority ? [.openingBracket, a, lhsToken, b, .closingBracket] : [a, lhsToken, b]
                    let rhsInfix: [DummyToken] = op.priority > rhsOp.priority ? [.openingBracket, c, rhsToken, d, .closingBracket] : [c, rhsToken, d]
                    let infix: [DummyToken] = lhsInfix + [opToken] + rhsInfix
                    expressions.append((infix, postfix))
                }
                
            }
        }
        
        return expressions
    }
    
    private static func _RightLeftAnyAssociativity() -> [DummyTokenValidExpression]
    {
        var expressions = [DummyTokenValidExpression]()
        
        let leftAssociativeOperations = Self.allCases
            .filter { $0.associativity == .left }
        let rightAssociativeOperations = Self.allCases
        .filter {$0.associativity == .right }
        for lhsOp in rightAssociativeOperations
        {
            let lhsToken: DummyToken = .binaryOperator(lhsOp)
            for op in leftAssociativeOperations {
                let opToken: DummyToken = .binaryOperator(op)
                for rhsOp in Self.allCases
                {
                    let rhsToken: DummyToken = .binaryOperator(rhsOp)
                    
                    let a: DummyToken = .operand(MockBinaryOperator.givenRandomInt())
                    let b: DummyToken = .operand(MockBinaryOperator.givenRandomInt())
                    let c: DummyToken = .operand(MockBinaryOperator.givenRandomInt())
                    let d: DummyToken = .operand(MockBinaryOperator.givenRandomInt())
                    
                    let postfix: [DummyToken] = [a, b, lhsToken, c, d, rhsToken, opToken]
                    
                    let lhsInfix: [DummyToken] = op.priority < lhsOp.priority ? [.openingBracket, a, lhsToken, b, .closingBracket] : [a, lhsToken, b]
                    let rhsInfix: [DummyToken] = op.priority > rhsOp.priority ? [.openingBracket, c, rhsToken, d, .closingBracket] : [c, rhsToken, d]
                    let infix: [DummyToken] = lhsInfix + [opToken] + rhsInfix
                    expressions.append((infix, postfix))
                }
                
            }
        }
        
        return expressions
    }
    
    private static func _AnyAssociativityRightLeft() -> [DummyTokenValidExpression]
    {
        var expressions = [DummyTokenValidExpression]()
        
        let leftAssociativeOperations = Self.allCases
            .filter { $0.associativity == .left }
        let rightAssociativeOperations = Self.allCases
        .filter {$0.associativity == .right }
        for lhsOp in Self.allCases
        {
            let lhsToken: DummyToken = .binaryOperator(lhsOp)
            for op in rightAssociativeOperations {
                let opToken: DummyToken = .binaryOperator(op)
                for rhsOp in leftAssociativeOperations
                {
                    let rhsToken: DummyToken = .binaryOperator(rhsOp)
                    
                    let a: DummyToken = .operand(MockBinaryOperator.givenRandomInt())
                    let b: DummyToken = .operand(MockBinaryOperator.givenRandomInt())
                    let c: DummyToken = .operand(MockBinaryOperator.givenRandomInt())
                    let d: DummyToken = .operand(MockBinaryOperator.givenRandomInt())
                    
                    let postfix: [DummyToken] = [a, b, lhsToken, c, d, rhsToken, opToken]
                    
                    let lhsInfix: [DummyToken] = op.priority >= lhsOp.priority ? [.openingBracket, a, lhsToken, b, .closingBracket] : [a, lhsToken, b]
                    let rhsInfix: [DummyToken] = op.priority >= rhsOp.priority ? [.openingBracket, c, rhsToken, d, .closingBracket] : [c, rhsToken, d]
                    let infix: [DummyToken] = lhsInfix + [opToken] + rhsInfix
                    expressions.append((infix, postfix))
                }
                
            }
        }
        
        return expressions
    }
    
    private static func _AnyAssociativityRightRight() -> [DummyTokenValidExpression]
    {
        var expressions = [DummyTokenValidExpression]()
        
        let rightAssociativeOperations = Self.allCases
        .filter {$0.associativity == .right }
        for lhsOp in Self.allCases
        {
            let lhsToken: DummyToken = .binaryOperator(lhsOp)
            for op in rightAssociativeOperations {
                let opToken: DummyToken = .binaryOperator(op)
                for rhsOp in rightAssociativeOperations
                {
                    let rhsToken: DummyToken = .binaryOperator(rhsOp)
                    
                    let a: DummyToken = .operand(MockBinaryOperator.givenRandomInt())
                    let b: DummyToken = .operand(MockBinaryOperator.givenRandomInt())
                    let c: DummyToken = .operand(MockBinaryOperator.givenRandomInt())
                    let d: DummyToken = .operand(MockBinaryOperator.givenRandomInt())
                    
                    let postfix: [DummyToken] = [a, b, lhsToken, c, d, rhsToken, opToken]
                    
                    let lhsInfix: [DummyToken] = op.priority >= lhsOp.priority ? [.openingBracket, a, lhsToken, b, .closingBracket] : [a, lhsToken, b]
                    let rhsInfix: [DummyToken] = op.priority < rhsOp.priority ? [.openingBracket, c, rhsToken, d, .closingBracket] : [c, rhsToken, d]
                    let infix: [DummyToken] = lhsInfix + [opToken] + rhsInfix
                    expressions.append((infix, postfix))
                }
                
            }
        }
        
        return expressions
    }
    
    static func givenForBracketTesting() -> [DummyTokenValidExpression]
    {
        let _NoneSomeSome: [DummyTokenValidExpression] = _NoneLeftAnyAssociativity() + _NoneRightLeft() + _NoneRightRight()
        
        let _SomeSomeNone: [DummyTokenValidExpression] = _LeftLeftNone() + _RightLeftNone() + _AnyAssociativityRightNone()
        
        let _SomeSomeSome: [DummyTokenValidExpression] = _LeftLeftAnyAssociativity() + _RightLeftAnyAssociativity() + _AnyAssociativityRightLeft() + _AnyAssociativityRightRight()
        
        return _NoneAnyAssociativityNone() + _NoneSomeSome + _SomeSomeNone + _SomeSomeSome
    }
    
}
