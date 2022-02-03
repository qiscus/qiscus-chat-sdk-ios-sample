//
//  Double.swift
//  Example
//
//  Created by arief nur putranto on 03/01/22.
//  Copyright © 2022 Qiscus. All rights reserved.
//

import Foundation
extension Double {
  static func equal(_ lhs: Double, _ rhs: Double, precise value: Int? = nil) -> Bool {
    guard let value = value else {
      return lhs == rhs
    }
        
    return lhs.precised(value) == rhs.precised(value)
  }

  func precised(_ value: Int = 1) -> Double {
    let offset = pow(10, Double(value))
    return (self * offset).rounded() / offset
  }
}
