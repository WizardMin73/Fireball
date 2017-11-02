//
//  FireballProtocol.swift
//  Fireball
//
//  Created by M1N on 2017/10/31.
//  Copyright © 2017年 M1N. All rights reserved.
//
public protocol FireballProtocol {
    associatedtype Value
    associatedtype Error: Swift.Error
    
    init(value: Value)
    init(error: Error)
    
    var fireBall: Fireball<Value, Error> { get }
}

public extension Fireball {
    /// Returns the value if self represents a success, nil otherwise.
    public var value: Value? {
        switch self {
        case let .success(value):
            return value
        case .failure:
            return nil
        }
    }
    
    /// Returns the error if self represents a failure, nil otherwise
    public var error: Error? {
        switch self {
        case .success:
            return nil
        case let .failure(error):
            return error
        }
    }
    
    /// Returns a new Fireball by mapping `Success`es’ values using `transform`, or re-wrapping `Failure`s’ errors.
    public func map<U>(_ transform: (Value) -> U) -> Fireball<U, Error> {
        return flatMap { .success(transform($0)) }
    }
    
    /// Returns the Fireball of applying `transform` to `Success`es’ values, or re-wrapping `Failure`’s errors.
    public func flatMap<U>(_ transform: (Value) -> Fireball<U, Error>) -> Fireball<U, Error> {
        switch self {
        case let .success(value): return transform(value)
        case let .failure(error): return .failure(error)
        }
    }
    
    /// Returns a Fireball with a tuple of the receiver and `other` values if both
    /// are `Success`es, or re-wrapping the error of the earlier `Failure`.
    public func fanout<U>(_ other: @autoclosure () -> Fireball<U, Error>) -> Fireball<(Value, U), Error> {
        return self.flatMap { left in other().map { right in (left, right) } }
    }
    
    /// Returns a new Fireball by mapping `Failure`'s values using `transform`, or re-wrapping `Success`es’ values.
    public func mapError<Error2>(_ transform: (Error) -> Error2) -> Fireball<Value, Error2> {
        return flatMapError { .failure(transform($0)) }
    }
    
    /// Returns the Fireball of applying `transform` to `Failure`’s errors, or re-wrapping `Success`es’ values.
    public func flatMapError<Error2>(_ transform: (Error) -> Fireball<Value, Error2>) -> Fireball<Value, Error2> {
        switch self {
        case let .success(value): return .success(value)
        case let .failure(error): return transform(error)
        }
    }
    
    /// Returns a new Fireball by mapping `Success`es’ values using `success`, and by mapping `Failure`'s values using `failure`.
    public func bimap<U, Error2>(success: (Value) -> U, failure: (Error) -> Error2) -> Fireball<U, Error2> {
        switch self {
        case let .success(value): return .success(success(value))
        case let .failure(error): return .failure(failure(error))
        }
    }
}

public extension Fireball {
    
    // MARK: Higher-order functions
    
    /// Returns `self.value` if this fireball is a .Success, or the given value otherwise. Equivalent with `??`
    public func recover(_ value: @autoclosure () -> Value) -> Value {
        return self.value ?? value()
    }
    
    /// Returns this fireball if it is a .Success, or the given fireball otherwise. Equivalent with `??`
    public func recover(with fireball: @autoclosure () -> Fireball<Value, Error>) -> Fireball<Value, Error> {
        switch self {
        case .success: return self
        case .failure: return fireball()
        }
    }
}

/// Protocol used to constrain `tryMap` to `Fireball`s with compatible `Error`s.
public protocol ErrorConvertible: Swift.Error {
    static func error(from error: Swift.Error) -> Self
}

public extension Fireball where Error: ErrorConvertible {
    
    /// Returns the fireball of applying `transform` to `Success`es’ values, or wrapping thrown errors.
    public func tryMap<U>(_ transform: (Value) throws -> U) -> Fireball<U, Error> {
        return flatMap { value in
            do {
                return .success(try transform(value))
            }
            catch {
                let convertedError = Error.error(from: error)
                return .failure(convertedError)
            }
        }
    }
}

// MARK: - Operators

extension Fireball where Value: Equatable, Error: Equatable {
    /// Returns `true` if `left` and `right` are both `Success`es and their values are equal, or if `left` and `right` are both `Failure`s and their errors are equal.
    public static func ==(left: Fireball<Value, Error>, right: Fireball<Value, Error>) -> Bool {
        if let left = left.value, let right = right.value {
            return left == right
        } else if let left = left.error, let right = right.error {
            return left == right
        }
        return false
    }
    
    /// Returns `true` if `left` and `right` represent different cases, or if they represent the same case but different values.
    public static func !=(left: Fireball<Value, Error>, right: Fireball<Value, Error>) -> Bool {
        return !(left == right)
    }
}

extension Fireball {
    /// Returns the value of `left` if it is a `Success`, or `right` otherwise. Short-circuits.
    public static func ??(left: Fireball<Value, Error>, right: @autoclosure () -> Value) -> Value {
        return left.recover(right())
    }
    
    /// Returns `left` if it is a `Success`es, or `right` otherwise. Short-circuits.
    public static func ??(left: Fireball<Value, Error>, right: @autoclosure () -> Fireball<Value, Error>) -> Fireball<Value, Error> {
        return left.recover(with: right())
    }
}

