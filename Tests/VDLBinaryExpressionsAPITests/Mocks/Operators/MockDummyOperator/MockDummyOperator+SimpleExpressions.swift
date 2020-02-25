//
//  VDLBinaryExpressionsAPITests
//  MockDummyOperator+SimpleExpressions.swift
//  
//
//  Created by Valeriano Della Longa on 23/02/2020.
//  Copyright (c) 2020 Valeriano Della Longa
//

@testable import VDLBinaryExpressionsAPI
import Foundation

// MARK: - Basic valid expressions
extension MockDummyOperator {
    private static func simpleExprBuilder(for op: Self)
        -> DummyTokenValidExpression
    {
        let lhs = MockBinaryOperator.givenRandomInt()
        let rhs = MockBinaryOperator.givenRandomInt()
        
        let infix: [DummyToken] = [.operand(lhs), .binaryOperator(op), .operand(rhs)]
        let postfix: [DummyToken] = [infix[0], infix[2], infix[1]]
        
        return (infix: infix, postfix: postfix)
    }
    
    static func givenSimple_L0_Expression() -> DummyTokenValidExpression {
        return simpleExprBuilder(for: .leftVeryLow)
    }
    
    static func givenSimple_L5_Expression() -> DummyTokenValidExpression {
        return simpleExprBuilder(for: .leftLow)
    }
    
    static func givenSimple_L10_Expression() -> DummyTokenValidExpression {
        return simpleExprBuilder(for: .leftHigh)
    }
    
    static func givenSimple_R0_Expression() -> DummyTokenValidExpression {
        return simpleExprBuilder(for: .rightVeryLow)
    }
    
    static func givenSimple_R5_Expression() -> DummyTokenValidExpression {
        return simpleExprBuilder(for: .rightLow)
    }
    
    static func givenSimple_R10_Expression() -> DummyTokenValidExpression {
        return simpleExprBuilder(for: .rightHigh)
    }
    
    static func givenValidSimpleExpressionsOfTwoOperands() -> [(DummyTokenValidExpression)]
    {
         return [
            givenSimple_L0_Expression(),
            givenSimple_L5_Expression(),
            givenSimple_L10_Expression(),
            givenSimple_R0_Expression(),
            givenSimple_R5_Expression(),
            givenSimple_R10_Expression(),
        ]
    }
    
}

