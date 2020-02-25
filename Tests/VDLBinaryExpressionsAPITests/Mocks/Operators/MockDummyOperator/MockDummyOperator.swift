//
//  VDLBinaryExpressionsAPITests
//  MockDummyOperator.swift
//  
//
//  Created by Valeriano Della Longa on 21/02/2020.
//  Copyright (c) 2020 Valeriano Della Longa
//

@testable import VDLBinaryExpressionsAPI
import Foundation

enum MockDummyOperator: CaseIterable, BinaryOperatorProtocol, Equatable {
    case leftVeryLow
    case leftLow
    case leftHigh
    case rightVeryLow
    case rightLow
    case rightHigh
    
    // MARK: - BinaryOperatorProtocol conformance
    typealias Operand = Int
    
    fileprivate static func _dummyBinOp
        (lhs: Operand, rhs: Operand) throws
        -> Operand
    {
        return Int.min
    }
    
    var binaryOperation: (Int, Int) throws -> Int { return Self._dummyBinOp(lhs:rhs:) }
    
    var priority: Int {
        switch self {
        case .leftVeryLow: return 0
        case .rightVeryLow: return 0
        case .leftLow: return 5
        case .rightLow: return 5
        case .leftHigh: return 10
        case .rightHigh: return 10
        }
    }
    
    var associativity: BinaryOperatorAssociativity {
        switch self {
        case .leftVeryLow, .leftLow, .leftHigh: return .left
        case .rightVeryLow, .rightLow, .rightHigh: return .right
        }
    }
    
}

// MARK: - CustomStringConvertible and CustomDebugStringConvertible
extension MockDummyOperator: CustomStringConvertible {
    var description: String {
        switch self {
        case .leftVeryLow: return "<L0>"
        case .leftLow: return "<L5>"
        case .leftHigh: return "<L10>"
        case .rightVeryLow: return "<R0>"
        case .rightLow: return "<R5>"
        case .rightHigh: return "<R10>"
        }
    }
}

extension MockDummyOperator: CustomDebugStringConvertible {
    var debugDescription: String { return description }
}

// MARK: - Useful typealiases
typealias DummyToken = BinaryOperatorExpressionToken<MockDummyOperator>
typealias DummyTokenValidExpression = (infix: [DummyToken], postfix: [DummyToken])

