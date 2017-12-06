//
//  Site.swift
//  CoinNow
//
//  Created by DingMac on 2017. 7. 13..
//  Copyright © 2017년 DingdingKim. All rights reserved.
//

import Foundation

enum Site: String {
    //휴오비가 데이터를 제대로 못 가져와서 일단 막아놓음
    //case bithumb = "Bithumb", coinone = "Coinone", poloniex = "Poloniex", okcoin = "OKCoin", huobi = "Huobi", bitfinex = "Bitfinex", bittrex = "Bittrex"
    case bithumb = "Bithumb", coinone = "Coinone", poloniex = "Poloniex", okcoin = "OKCoin", bitfinex = "Bitfinex", bittrex = "Bittrex"
    static let allValues = ["Bithumb", "Coinone", "Poloniex", "OKCoin", "Bitfinex", "Bittrex"]
    
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
//        case .huobi:
//            return .cny
        case .bitfinex:
            return .usd
        case .bittrex:
            return .usd
        }
    }
    
    func arrTradableCoin() -> [String] {
        switch self {
        case .bithumb:
            return ["BTC", "ETH", "DASH", "LTC", "ETC", "XRP", "BCH", "XMR", "QTUM", "ZEC", "BTG"]
        case .coinone:
            return ["BTC", "ETH", "ETC", "XRP", "BCH", "QTUM", "IOTA"]
        case .poloniex:
            return ["BTC", "ETH", "DASH", "LTC", "ETC", "XRP", "BCH", "XMR", "ZEC"]
        case .okcoin:
            return ["BTC", "ETH", "LTC"]
//        case .huobi:
//            return ["BTC", "LTC"]
        case .bitfinex:
            return ["BTC", "ETH", "DASH", "LTC", "ETC", "XRP", "BCH", "XMR", "QTUM", "ZEC", "BTG", "IOTA"]
        case .bittrex:
            return ["BTC", "ETH", "DASH", "LTC", "ETC", "XRP", "BCH", "XMR", "ZEC", "BTG"]//비트렉스는 비캐를 BCC라고 부름.호출하는데서 BCH를 BCC로 바꿔주겠음
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
//        case huobi.rawValue:
//            return .huobi
        case bitfinex.rawValue:
            return .bitfinex
        case bittrex.rawValue:
            return .bittrex
        default:
            return .bithumb
        }
    }
}
