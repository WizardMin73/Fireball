//
//  FireballNoError.Swift
//  Fireball
//
//  Created by M1N on 2017/10/31.
//  Copyright © 2017年 M1N. All rights reserved.
//

/// An error that is impossible to construct.

public enum FireballNoError: Swift.Error, Equatable {
    public static func ==(lhs: FireballNoError, rhs: FireballNoError) -> Bool {
        return true
    }
}
