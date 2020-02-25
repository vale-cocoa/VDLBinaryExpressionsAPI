//
//  VDLBinaryExpressionsAPITests
//  MockDummyOperand.swift
//  
//
//  Created by Valeriano Della Longa on 20/02/2020.
//  Copyright (c) 2020 Valeriano Della Longa
//

import Foundation
import VDLBinaryExpressionsAPI

enum MockDummyOperand {
    case dummy
    
    enum Error: Swift.Error
    {
        case mapOperandFailed
        case mapOperatorFailed
        case mappedOperationFail
    }
    
    static func mapOperand(_ operand: MockBinaryOperator.Operand)
        throws -> Self
    {
        return .dummy
    }
    
    static func mapOperator
        (_ operator: MockBinaryOperator)
        throws -> BinaryOperation<MockDummyOperand>
    {
        return { _, _ in return .dummy }
    }
    
    static func mapOperandFail
        (_ operand: MockBinaryOperator.Operand)
        throws -> Self
    {
        throw Error.mapOperandFailed
    }
    
    static func mapOperatorFail
        (_ operator: MockBinaryOperator)
        throws -> BinaryOperation<MockDummyOperand>
    {
        throw Error.mapOperatorFailed
    }
    
    static func mapOperatorToFailingOperation
        (_ operator: MockBinaryOperator)
        throws -> BinaryOperation<MockDummyOperand>
    {
        return { _, _ in throw Error.mappedOperationFail }
    }
    
}
