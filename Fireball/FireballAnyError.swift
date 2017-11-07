//
//  FireballAnyError.swift
//  Fireball
//
//  Created by M1N on 2017/10/31.
//  Copyright © 2017年 M1N. All rights reserved.
//

import Foundation

/// A type-erased error which wraps an arbitrary error instace. This should be
/// useful for generic contexts.
public struct FireballAnyError: Swift.Error {
    
    public let error: Swift.Error
    
    public init(_ error: Swift.Error) {
        if let anyError = error as? FireballAnyError {
            self = anyError
        } else {
            self.error = error
        }
    }
}

extension FireballAnyError: CustomStringConvertible {
    public var description: String {
        return String(describing: error)
    }
}

extension FireballAnyError: LocalizedError {
    public var errorDescription: String? {
        return error.localizedDescription
    }
    
    public var failureReason: String? {
        return (error as? LocalizedError)?.failureReason
    }
    
    public var helpAnchor: String? {
        return (error as? LocalizedError)?.helpAnchor
    }
    
    public var recoverySuggestion: String? {
        return (error as? LocalizedError)?.recoverySuggestion
    }
}
