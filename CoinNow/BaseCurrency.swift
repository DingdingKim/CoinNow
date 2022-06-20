//
//  BaseCurrency.swift
//  CoinNow
//
//  Created by DingMac on 2017. 7. 13..
//  Copyright © 2017년 DingdingKim. All rights reserved.
//

import Foundation

enum BaseCurrency: String {
    case krw = "KRW", usdt = "USDT", btc = "BTC"
    
    static let allValues = ["KRW", "USDT", "BTC"]
    
    static func valueOf(name: String) -> BaseCurrency {
        switch name {
        case krw.rawValue:
            return .krw
        case usdt.rawValue:
            return .usdt
        case btc.rawValue:
            return .btc
        default:
            return .krw
        }
    }
}
