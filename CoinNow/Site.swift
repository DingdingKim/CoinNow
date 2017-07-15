//
//  Site.swift
//  CoinNow
//
//  Created by DingMac on 2017. 7. 13..
//  Copyright © 2017년 DingdingKim. All rights reserved.
//

import Foundation

enum Site: String {
    case bithumb = "Bithumb", coinone = "Coinone", poloniex = "Poloniex", okcoin = "OKCoin CNY"
    
    static let allValues = ["Bithumb", "Coinone", "Poloniex", "OKCoin CNY"]
    
    func baseCurrency() -> BaseCurrency {
        switch self {
        case .bithumb:
            return .krw
        case .coinone:
            return .krw
        case .poloniex:
            return .usd
        case .okcoin:
            return .cny
        }
    }
    
    func arrTradableCoin() -> [String] {
        switch self {
        case .bithumb:
            return ["BTC", "ETH", "DASH", "LTC", "ETC", "XRP"]
        case .coinone:
            return ["BTC", "ETH", "ETC", "XRP"]
        case .poloniex:
            return ["BTC", "ETH", "DASH", "LTC", "ETC", "XRP"]
        case .okcoin:
            return ["BTC", "ETH", "LTC"]
        }
    }
    
    
    static func valueOf(name: String) -> Site {
        switch name {
        case bithumb.rawValue:
            return .bithumb
        case coinone.rawValue:
            return .coinone
        case poloniex.rawValue:
            return .poloniex
        case okcoin.rawValue:
            return .okcoin
        default:
            return .bithumb
        }
    }
}
