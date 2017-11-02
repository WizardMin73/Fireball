//
//  NoError.swift
//  Fireball
//
//  Created by M1N on 2017/10/31.
//  Copyright © 2017年 M1N. All rights reserved.
//

/// An error that is impossible to construct.
///
/// This can be used to describe Result's where failures will never
/// be genrated. For example, Result<Int, NoError> describes a result that
/// contains an Int and is guranteed never to be a failure
public enum NoError: Swift.Error, Equatable {
    public static func ==(lhs: NoError, rhs: NoError) -> Bool {
        return true
    }
}
