//
//  Extension.swift
//  DDCurrentCoinState
//
//  Created by DingMac on 2017. 6. 25..
//  Copyright © 2017년 DingdingKim. All rights reserved.
//

import Foundation
import Cocoa

extension Double {
    func withCommas() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        return numberFormatter.string(from: NSNumber(value:self.roundTo(places: 2)))!
    }
    //Get https://stackoverflow.com/questions/27338573/rounding-a-double-value-to-x-number-of-decimal-places-in-swift
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension Int {
    func withCommas() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        return numberFormatter.string(from: NSNumber(value:self))!
    }
}

extension Date {
    func todayString(format:String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let dateString = dateFormatter.string(from: self)
        
        return dateString
    }
    
    func isTimeToUpdateExchangeRate() -> Bool {
        let timeInterval:Int = abs(Int(self.timeIntervalSinceNow))
        
        //return timeInterval / (60 * 60) > 1 ? true : false
        return timeInterval / (30) >= 1 ? true : false
    }
}

extension Dictionary where Value: Equatable {
    func allKeys(forValue val: Value) -> [Key] {
        return self.filter { $1 == val }.map { $0.0 }
    }
}

extension NSViewController {
    func isDarkMode() -> Bool{
        return UserDefaults.standard.string(forKey: "AppleInterfaceStyle") ?? "Light" == "Dark"
    }
}
