//
//  VDLBinaryExpressionsAPITests
//  MockDummyOperator+PostfixConversionTests.swift
//  
//
//  Created by Valeriano Della Longa on 23/02/2020.
//  Copyright (c) 2020 Valeriano Della Longa
//

@testable import VDLBinaryExpressionsAPI
import Foundation

// MARK: - Given cases for PostfixConversionTests
extension MockDummyOperator {
    private static func _threeOperandsOperation_LorR_L() -> [DummyTokenValidExpression]
    {
        var expressions = [DummyTokenValidExpression]()
        
        let leftAssociativeOps = Self.allCases
            .filter { $0.associativity == .left }
        
        for rhsOp in leftAssociativeOps {
            let rhsOpToken: DummyToken = .binaryOperator(rhsOp)
            for lhsOp in Self.allCases {
                let lhsOpToken: DummyToken = .binaryOperator(lhsOp)
                
                let a: DummyToken = .operand(MockBinaryOperator.givenRandomInt())
                let b: DummyToken = .operand(MockBinaryOperator.givenRandomInt())
                let c: DummyToken = .operand(MockBinaryOperator.givenRandomInt())
                
                let infix: [DummyToken] = [a, lhsOpToken, b, rhsOpToken, c]
                let postfix: [DummyToken] = rhsOp.priority <= lhsOp.priority ? [a, b, lhsOpToken, c, rhsOpToken] : [a, b, c, rhsOpToken, lhsOpToken]
                
                expressions.append((infix, postfix))
            }
        }
        
        return expressions
    }
    
    private static func _threeOperandsOperations_LorR_R() -> [DummyTokenValidExpression]
    {
        var expressions = [DummyTokenValidExpression]()
        
        let rightAssociativeOps = Self.allCases
        .filter { $0.associativity == .right }
        
        for rhsOp in rightAssociativeOps {
            let rhsOpToken: DummyToken = .binaryOperator(rhsOp)
            for lhsOp in Self.allCases {
                let lhsOpToken: DummyToken = .binaryOperator(lhsOp)
                
                let a: DummyToken = .operand(MockBinaryOperator.givenRandomInt())
                let b: DummyToken = .operand(MockBinaryOperator.givenRandomInt())
                let c: DummyToken = .operand(MockBinaryOperator.givenRandomInt())
                
                let infix: [DummyToken] = [a, lhsOpToken, b, rhsOpToken, c]
                let postfix: [DummyToken] = rhsOp.priority < lhsOp.priority ? [a, b, lhsOpToken, c, rhsOpToken] : [a, b, c, rhsOpToken, lhsOpToken]
                
                expressions.append((infix, postfix))
            }
        }
        
        return expressions
    }
    
    private static func _threeOperandsOperation_BracketedLorR_LorR() -> [DummyTokenValidExpression]
    {
        var expressions = [DummyTokenValidExpression]()
        
        for lhsOp in Self.allCases {
            let lhsOpToken: DummyToken = .binaryOperator(lhsOp)
            for rhsOp in Self.allCases {
                let rhsOpToken: DummyToken = .binaryOperator(rhsOp)
                
                let a: DummyToken = .operand(MockBinaryOperator.givenRandomInt())
                let b: DummyToken = .operand(MockBinaryOperator.givenRandomInt())
                let c: DummyToken = .operand(MockBinaryOperator.givenRandomInt())
                
                let infix: [DummyToken] = [.openingBracket, a, lhsOpToken, b, .closingBracket, rhsOpToken, c]
                let postfix: [DummyToken] = [a, b, lhsOpToken, c, rhsOpToken]
                
                expressions.append((infix, postfix))
            }
        }
        
        return expressions
    }
    
    private static func _threeOperandsOperations_LorR_BracketedLorR() -> [DummyTokenValidExpression]
    {
        var expressions = [DummyTokenValidExpression]()
        
        for lhsOp in Self.allCases {
            let lhsOpToken: DummyToken = .binaryOperator(lhsOp)
            for rhsOp in Self.allCases {
                let rhsOpToken: DummyToken = .binaryOperator(rhsOp)
                
                let a: DummyToken = .operand(MockBinaryOperator.givenRandomInt())
                let b: DummyToken = .operand(MockBinaryOperator.givenRandomInt())
                let c: DummyToken = .operand(MockBinaryOperator.givenRandomInt())
                
                let infix: [DummyToken] = [a, lhsOpToken, .openingBracket, b, rhsOpToken, c, .closingBracket]
                let postfix: [DummyToken] = [a, b, c, rhsOpToken, lhsOpToken]
                
                expressions.append((infix, postfix))
            }
        }
        
        return expressions
    }
    
    private static func _moreComplexCases() -> [DummyTokenValidExpression]
    {
        var expressions = [DummyTokenValidExpression]()
        
        let a: DummyToken = .operand(MockBinaryOperator.givenRandomInt())
        let b: DummyToken = .operand(MockBinaryOperator.givenRandomInt())
        let c: DummyToken = .operand(MockBinaryOperator.givenRandomInt())
        let d: DummyToken = .operand(MockBinaryOperator.givenRandomInt())
       
        let infix1: [DummyToken] = [a, .binaryOperator(.leftLow), b, .binaryOperator(.rightVeryLow), c, .binaryOperator(.leftVeryLow), d]
        let postfix1: [DummyToken] = [a, b, .binaryOperator(.leftLow), c, .binaryOperator(.rightVeryLow), d, .binaryOperator(.leftVeryLow)]
        expressions.append((infix1, postfix1))
        
        let infix2: [DummyToken] = [a, .binaryOperator(.rightLow), b, .binaryOperator(.leftHigh), c, .binaryOperator(.rightHigh), d]
        let postfix2: [DummyToken] = [a, b, c, d, .binaryOperator(.rightHigh), .binaryOperator(.leftHigh), .binaryOperator(.rightLow)]
        expressions.append((infix2, postfix2))
        
        let infix3: [DummyToken] = [a, .binaryOperator(.leftHigh), b, .binaryOperator(.rightHigh), c, .binaryOperator(.leftLow), d]
        let postfix3: [DummyToken] = [a, b, c, .binaryOperator(.rightHigh), .binaryOperator(.leftHigh), d, .binaryOperator(.leftLow)]
        expressions.append((infix3, postfix3))
        
        return expressions
    }
    
    static func givenValidExpressionsOfThreeOperands() -> [DummyTokenValidExpression] {
        return
            _threeOperandsOperation_LorR_L() +
            _threeOperandsOperations_LorR_R() +
            _threeOperandsOperation_BracketedLorR_LorR() +
            _threeOperandsOperations_LorR_BracketedLorR() +
            _moreComplexCases()
    }
    
}


