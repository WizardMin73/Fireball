//
//  Fireball.swift
//  Fireball
//
//  Created by M1N on 2017/10/31.
//  Copyright © 2017年 M1N. All rights reserved.
//

public enum Fireball<Value, Error: Swift.Error>: FireballProtocol, CustomStringConvertible, CustomDebugStringConvertible  {
    case success(Value)
    case failure(Error)
    
    //MARK: - Constructors
    
    /// Constructs a success wrapping a `value`.
    public init(value: Value) {
        self = .success(value)
    }
    
    /// Constructs a failure wrapping an `error`.
    public init(error: Error) {
        self = .failure(error)
    }
    
    /// Constructs a fireball from an `Optional`, failing with `Error` if `nil`.
    public init(_ value: Value?, failWith: @autoclosure () -> Error) {
        self = value.map(Fireball.success) ?? .failure(failWith())
    }
    
    /// Constructs a fireball from a function that uses `throw`, failing with `Error` if throws.
    public init(_ f: @autoclosure () throws -> Value) {
        self.init(attempt: f)
    }
    
    /// Constructs a fireball from a function that uses `throw`, failing with `Error` if throws.
    public init(attempt f: () throws -> Value) {
        do {
            self = .success(try f())
        } catch var error {
            if Error.self == FireballAnyError.self {
                error = FireballAnyError(error)
            }
            self = .failure(error as! Error)
        }
    }

    //MARK: - Deconstruction
    
    /// Resturns the value from success Fireballs or throws the error
    public func dematerialize() throws -> Value {
        switch self {
        case let .success(value):
            return value
        case let .failure(error):
            throw error
        }
    }
    
    /// Case analysis for Fireball
    ///
    /// Returns the value produced by applying 'ifFailure' to 'failure' Fireballs, or 'ifSuccess' to 'success' Fireballs
    public func analysis<FireBall>(ifSuccess: (Value) -> FireBall, ifFailure: (Error) -> FireBall) -> FireBall {
        switch self {
        case let .success(value):
            return ifSuccess(value)
        case let .failure(error):
            return ifFailure(error)
        }
    }
    
    // MARK: Errors
    
    /// The domain for errors constructed by Result.
    public static var errorDomain: String { return "com.antitypical.Result" }
    
    /// The userInfo key for source functions in errors constructed by Result.
    public static var functionKey: String { return "\(errorDomain).function" }
    
    /// The userInfo key for source file paths in errors constructed by Result.
    public static var fileKey: String { return "\(errorDomain).file" }
    
    /// The userInfo key for source file line numbers in errors constructed by Result.
    public static var lineKey: String { return "\(errorDomain).line" }
    
    /// Constructs an error.
    public static func error(_ message: String? = nil, function: String = #function, file: String = #file, line: Int = #line) -> NSError {
        var userInfo: [String: Any] = [
            functionKey: function,
            fileKey: file,
            lineKey: line,
            ]
        
        if let message = message {
            userInfo[NSLocalizedDescriptionKey] = message
        }
        
        return NSError(domain: errorDomain, code: 0, userInfo: userInfo)
    }
    
    
    // MARK: CustomStringConvertible
    
    public var description: String {
        switch self {
        case let .success(value): return ".success(\(value))"
        case let .failure(error): return ".failure(\(error))"
        }
    }
    
    
    // MARK: CustomDebugStringConvertible
    
    public var debugDescription: String {
        return description
    }
    
    // MARK: FireballProtocol
    public var fireBall: Fireball<Value, Error> {
        return self
    }
}

extension Fireball where Error == FireballAnyError {
    /// Constructs a fireball from an expression that uses throw, failing with FireballAnyError if throws.
    public init(_ f: @autoclosure () throws -> Value) {
        self.init(attempt: f)
    }
    
    /// Constructs a fireball from a closure that uses `throw`, failing with `FireballAnyError` if throws.
    public init(attempt f: () throws -> Value) {
        do {
            self = .success(try f())
        } catch {
            self = .failure(FireballAnyError(error))
        }
    }
}

// MARK: - ErrorConvertible conformance

extension NSError: ErrorConvertible {
    public static func error(from error: Swift.Error) -> Self {
        func cast<T: NSError>(_ error: Swift.Error) -> T {
            return error as! T
        }
        
        return cast(error)
    }
}

import Foundation
