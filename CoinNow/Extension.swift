//
//  Extension.swift
//  DDCurrentCoinState
//
//  Created by DingMac on 2017. 6. 25..
//  Copyright © 2017년 DingdingKim. All rights reserved.
//

import Foundation
import Cocoa

extension NSNumber {
    func withCommas() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        
        return numberFormatter.string(from: self)!
    }
}

extension Double {
    func withCommas() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        
        //large price(>100) no need to show floating point.
        if(self > 100){
            return numberFormatter.string(from: NSNumber(value:self.roundTo(places: 0)))!
        }
        else{
            return numberFormatter.string(from: NSNumber(value:self.roundTo(places: 2)))!
        }
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

extension NSView {
    func rotate360Degrees(duration: CFTimeInterval = 1.0, completionDelegate: AnyObject? = nil) {
        self.layer?.anchorPoint = CGPoint(x: 1, y: 1)
        
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(Double.pi)
        rotateAnimation.duration = duration
        
//        if let delegate: AnyObject = completionDelegate {
//            rotateAnimation.delegate = delegate as! CAAnimationDelegate
//        }
        self.layer?.add(rotateAnimation, forKey: nil)
    }
}
