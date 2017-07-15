//
//  BaseCurrency.swift
//  CoinNow
//
//  Created by DingMac on 2017. 7. 13..
//  Copyright © 2017년 DingdingKim. All rights reserved.
//

import Foundation

enum BaseCurrency: String {
    case krw = "KRW", usd = "USD", cny = "CNY"
    
    static let allValues = ["KRW", "USD", "CNY"]
    
    static func valueOf(name: String) -> BaseCurrency {
        switch name {
        case krw.rawValue:
            return .krw
        case usd.rawValue:
            return .usd
        case cny.rawValue:
            return .cny
        default:
            return .krw
        }
    }
}
