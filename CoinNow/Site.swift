//
//  Site.swift
//  CoinNow
//
//  Created by DingMac on 2017. 7. 13..
//  Copyright © 2017년 DingdingKim. All rights reserved.
//

import Foundation

enum Site: String {
    case bithumb = "Bithumb", coinone = "Coinone", poloniex = "Poloniex", okcoin = "OKCoin", huobi = "Huobi", bitfinex = "Bitfinex"
    
    static let allValues = ["Bithumb", "Coinone", "Poloniex", "OKCoin", "Huobi", "Bitfinex"]
    
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
        case .huobi:
            return .cny
        case .bitfinex:
            return .usd
        }
    }
    
    func arrTradableCoin() -> [String] {
        switch self {
        case .bithumb:
            return ["BTC", "ETH", "DASH", "LTC", "ETC", "XRP", "BCH", "XMR"]
        case .coinone:
            return ["BTC", "ETH", "ETC", "XRP", "BCH", "QTUM"]
        case .poloniex:
            return ["BTC", "ETH", "DASH", "LTC", "ETC", "XRP", "BCH", "XMR"]
        case .okcoin:
            return ["BTC", "ETH", "LTC"]
        case .huobi:
            return ["BTC", "LTC"]
        case .bitfinex:
            return ["BTC", "ETH", "DASH", "LTC", "ETC", "XRP", "BCH", "XMR"]
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
        case huobi.rawValue:
            return .huobi
        case bitfinex.rawValue:
            return .bitfinex
        default:
            return .bithumb
        }
    }
}
