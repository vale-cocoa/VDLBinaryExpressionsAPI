//
//  VDLBinaryExpressionsAPI
//  AnyBinaryOperator.swift
//  
//
//  Created by Valeriano Della Longa on 16/02/2020.
//  Copyright (c) 2020 Valeriano Della Longa
//

import Foundation

/// A type-erased wrapper over any binary operator.
///
/// An `AnyBinaryOperator` instance forwards its operations to a base binary operator having
/// the same `Operand` type, hiding the specifics of the underlying binary operator.
public struct AnyBinaryOperator<Operand>: BinaryOperatorProtocol {
    fileprivate let _box: _Base<Operand>
    
    /// Creates a type-erased binary operator that wraps the given concrete one.
    ///
    /// - Parameter base: The concrete binary operator to wrap.
    ///
    /// - Complexity: O(1).
    public init<Concrete: BinaryOperatorProtocol>(_ concrete: Concrete) where Concrete.Operand == Operand {
        _box = _Box(concrete)
    }
    
    // MARK: - BinaryOperatorProtocol conformance
    public var binaryOperation: (Operand, Operand) throws -> Operand {
        return _box.binaryOperation
    }
    
    public var priority: Int { return _box.priority }
    
    public var associativity: BinaryOperatorAssociativity { return _box.associativity }
    
    // MARK: - Type erasure Base class
    fileprivate class _Base<Operand>: BinaryOperatorProtocol {
        init() {
            guard type(of: self) != _Base.self else {
                fatalError("Can't create instances of AnyBinaryOperator._Base; create a subclass instance instead")
            }
        }
        
        var binaryOperation: (Operand, Operand) throws -> Operand {
            fatalError("Must override")
        }
        
        var priority: Int { fatalError("Must override") }
        
        var associativity: BinaryOperatorAssociativity { fatalError("Must override") }
        
    }
    
    // MARK: - Type erasure Box class
    private final class _Box<Concrete: BinaryOperatorProtocol>: _Base<Concrete.Operand> {
        private let _concrete: Concrete
        
        init(_ concrete: Concrete) {
            self._concrete = concrete
        }
        
        override var binaryOperation: (Concrete.Operand, Concrete.Operand) throws -> Concrete.Operand {
            return self._concrete.binaryOperation
        }
        
        override var priority: Int { return self._concrete.priority }
        
        override var associativity: BinaryOperatorAssociativity { return self._concrete.associativity }
        
    }
    
}

// MARK: - Closure based AnyBinaryOperator
extension AnyBinaryOperator {
    /// Creates a type-erased binary operator from given parameters.
    ///
    /// - Parameter ofPriority: The priority value. Defaults to `30`.
    ///
    /// - Parameter ofAssociativity: The associativity value. Defaults to`.left`.
    ///
    /// - Parameter byOperation: The represented binary operation.
    ///
    /// - Complexity: O(1).
    public init(
        ofPriority: Int = 30,
        ofAssociativity: BinaryOperatorAssociativity = .left,
        byOperation: @escaping (Operand, Operand) throws -> Operand
    ) {
        _box = _BoxClosureBased(associativity: ofAssociativity, priority: ofPriority, operation: byOperation)
    }
    
    private final class _BoxClosureBased: _Base<Operand> {
        private let _operationClosure: (Operand, Operand) throws -> Operand
        
        private let _associativity: BinaryOperatorAssociativity
        
        private let _priority: Int
        
        init(associativity: BinaryOperatorAssociativity, priority: Int, operation: @escaping (Operand, Operand) throws -> Operand) {
            self._associativity = associativity
            self._priority = priority
            self._operationClosure = operation
            
        }
        
        override var binaryOperation: (Operand, Operand) throws -> Operand { return self._operationClosure }
        
        override var associativity: BinaryOperatorAssociativity {
            return self._associativity
        }
        
        override var priority: Int { return self._priority }
    }
    
}
