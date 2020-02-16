//
//  VDLBinaryExpressionsAPI
//  MockConcreteBinaryOperator.swift
//  
//
//  Created by Valeriano Della Longa on 16/02/2020.
//  Copyright (c) 2020 Valeriano Della Longa
//

import XCTest
import Foundation
@testable import VDLBinaryExpressionsAPI

final class MockConcreteBinaryOperator<Operand>: BinaryOperatorProtocol

{
    enum Error: Swift.Error {
        case operationNotImplemented
    }
    
    var binaryOperationCalled = false
    
    var priorityCalled = false
    
    var associativityCalled = false
    
    // MARK: - BinaryOperatorProtocol conformance
    var binaryOperation: (Operand, Operand) throws -> Operand {
        self.binaryOperationCalled = true
        
        return { _, _ throws -> Operand in
            self.binaryOperationCalled = true
            throw Error.operationNotImplemented
        }
    }
    
    var priority: Int {
        self.priorityCalled = true
        return 10
    }
    
    var associativity: BinaryOperatorAssociativity {
        self.associativityCalled = true
        return .left
    }
    
}
