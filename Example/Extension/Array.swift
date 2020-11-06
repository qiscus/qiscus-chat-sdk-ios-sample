//
//  Array.swift
//  Example
//
//  Created by Qiscus on 04/11/20.
//  Copyright © 2020 Qiscus. All rights reserved.
//

import Foundation

extension Array {
    func chunked(by distance: Int) -> [[Element]] {
        precondition(distance > 0, "distance must be greater than 0") // prevents infinite loop

        if self.count <= distance {
            return [self]
        } else {
            let head = [Array(self[0 ..< distance])]
            let tail = Array(self[distance ..< self.count])
            return head + tail.chunked(by: distance)
        }
    }

}
