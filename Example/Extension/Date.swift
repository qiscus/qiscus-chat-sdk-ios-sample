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
    
    func reduceToMonthDayYear() -> Date {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: self)
        let day = calendar.component(.day, from: self)
        let year = calendar.component(.year, from: self)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        return dateFormatter.date(from: "\(month)/\(day)/\(year)") ?? Date()
    }
    
    func timeAgoSinceDate(numericDates:Bool) -> String {
        let calendar = Calendar.current
        let now = Date()
        let earliest = self < now ? self : now
        let latest =  self > now ? self : now
        
        let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfMonth, .month, .year, .second]
        let components: DateComponents = calendar.dateComponents(unitFlags, from: earliest, to: latest)
        
        if let year = components.year {
            if (year >= 2) {
                return "last seen \(year) years ago"
            } else if (year >= 1) {
                return stringToReturn(flag: numericDates, strings: ("1 year ago", "Last year"))
            }
        }
        
        if let month = components.month {
            if (month >= 2) {
                return "last seen \(month) months ago"
            } else if (month >= 2) {
                return stringToReturn(flag: numericDates, strings: ("1 month ago", "Last month"))
            }
        }
        
        if let weekOfYear = components.weekOfYear {
            if (weekOfYear >= 2) {
                return "last seen \(weekOfYear) months ago"
            } else if (weekOfYear >= 2) {
                return stringToReturn(flag: numericDates, strings: ("1 week ago", "Last week"))
            }
        }
        
        if let day = components.day {
            if (day >= 2) {
                return "last seen \(day) days ago"
            } else if (day >= 2) {
                return stringToReturn(flag: numericDates, strings: ("1 day ago", "Yesterday"))
            }
        }
        
        if let hour = components.hour {
            if (hour >= 2) {
                return "last seen \(hour) hours ago"
            } else if (hour >= 2) {
                return stringToReturn(flag: numericDates, strings: ("1 hour ago", "An hour ago"))
            }
        }
        
        if let minute = components.minute {
            if (minute >= 2) {
                return "last seen \(minute) minutes ago"
            } else if (minute >= 2) {
                return stringToReturn(flag: numericDates, strings: ("1 minute ago", "A minute ago"))
            }
        }
        
        if let second = components.second {
            if (second >= 3) {
                return "a few seconds ago"
            }else{
                return "Online"
            }
        }
        
        
        
        return ""
    }
    
    func differentTime() -> Int {
        let calendar = Calendar.current
        let now = Date()
        let earliest = self < now ? self : now
        let latest =  self > now ? self : now
        
        let currentDate = Date()
        let diffComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: earliest, to: latest)
        let hours = diffComponents.hour ?? 0
        let minutes = diffComponents.minute ?? 0
        let seconds = diffComponents.second ?? 0
        
        return hours
        
    }
    
    func differentTimeSeconds() -> Int {
        let calendar = Calendar.current
        let now = Date()
        let earliest = self < now ? self : now
        let latest =  self > now ? self : now
        
        let currentDate = Date()
        let diffComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: earliest, to: latest)
        let hours = diffComponents.hour ?? 0
        let minutes = diffComponents.minute ?? 0
        let seconds = diffComponents.second ?? 0
        
        return seconds
        
    }
    
    private func stringToReturn(flag:Bool, strings: (String, String)) -> String {
        if (flag){
            return "last seen \(strings.0)"
        } else {
            return "last seen \(strings.0)"
        }
    }
}
