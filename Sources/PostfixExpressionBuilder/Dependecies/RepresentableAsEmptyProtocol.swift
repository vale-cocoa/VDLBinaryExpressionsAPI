//
//  RepresentableAsEmptyProtocol.swift
//  
//
//  Created by Valeriano Della Longa on 06/02/2020.
//

import Foundation
/// A protocol for representing a Type which has an empty value.
public protocol RepresentableAsEmptyProtocol {
    /// The empty value for this type.
    ///
    /// For example numeric types as `Int`, `Double` etc. would return the value `0`.
    /// `String` would return `""`. A concrete `Sequence` or `Collection` would
    /// return an empty instance (no elements contained in it).
    static func empty() -> Self
    
    /// Flags if the instance is empty or not.
    var isEmpty: Bool { get }
}
