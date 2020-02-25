//
//  VDLBinaryExpressionsAPI
//  BinaryExpressionError.swift
//  
//
//  Created by Valeriano Della Longa on 18/02/2020.
//  Copyright (c) 2020 Valeriano Della Longa
//

import Foundation
/// Error thrown by  `VDLBinaryExpressionsAPI` functions when validating
/// and/or evaluating binary operation expressions in either postfix or infix notation.
public enum BinaryExpressionError: Error {
    /// Expression is not valid.
    case notValid
}
