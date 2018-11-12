//
//  Date.swift
//  Example
//
//  Created by Qiscus on 12/11/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import Foundation

extension Date {
    var isToday:Bool{
        get{
            if Calendar.current.isDateInToday(self){
                return true
            }
            return false
        }
    }
    var isYesterday:Bool{
        get{
            if Calendar.current.isDateInYesterday(self){
                return true
            }
            return false
        }
    }
    func offsetFromInSecond(date:Date) -> Int{
        let differerence = Calendar.current.dateComponents([.second], from: date, to: self)
        if let secondDiff = differerence.second{
            return secondDiff
        }else{
            return 0
        }
    }
    func offsetFromInMinutes(date:Date) -> Int{
        let differerence = Calendar.current.dateComponents([.minute], from: date, to: self)
        if let minuteDiff = differerence.minute{
            return minuteDiff
        }else{
            return 0
        }
    }
    
    func offsetFromInDay(date:Date)->Int{
        let differerence = Calendar.current.dateComponents([.day], from: self, to: date)
        if let dayDiff = differerence.day{
            return dayDiff
        }else{
            return 0
        }
    }
}
