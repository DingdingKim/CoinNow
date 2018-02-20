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
    case bithumb = "Bithumb", coinone = "Coinone", poloniex = "Poloniex", bitfinex = "Bitfinex", bittrex = "Bittrex", upbit = "Upbit"
    static let allValues = ["Bithumb", "Coinone", "Poloniex", "Bitfinex", "Bittrex", "Upbit"]
    static let defaultSelectedValues = ["Bithumb", "Poloniex", "Bittrex", "Upbit"]
    
    func baseCurrency() -> BaseCurrency {
        switch self {
        case .bithumb:
            return .krw
        case .coinone:
            return .krw
        case .poloniex:
            return .usd
        case .bitfinex:
            return .usd
        case .bittrex:
            return .usd
        case .upbit:
            return .krw
        }
    }
    
    func arrTradableCoin() -> [String] {
        switch self {
        case .bithumb:
            return ["BTC", "ETH", "DASH", "LTC", "ETC", "XRP", "BCH", "XMR", "QTUM", "ZEC", "BTG", "EOS"]
        case .coinone:
            return ["BTC", "ETH", "ETC", "XRP", "BCH", "QTUM", "IOTA", "LTC", "BTG"]
        case .poloniex:
            return ["BTC", "ETH", "DASH", "LTC", "ETC", "XRP", "BCH", "XMR", "ZEC"]
        case .bitfinex:
            return ["BTC", "ETH", "DASH", "LTC", "ETC", "XRP", "BCH", "XMR", "QTUM", "ZEC", "BTG", "IOTA", "SNT", "NEO", "OMG"]
        case .bittrex:
            return ["BTC", "ETH", "DASH", "LTC", "ETC", "XRP", "BCH", "XMR", "ZEC", "BTG", "ADA", "NEO", "OMG"]//비트렉스는 비캐를 BCC라고 부름.호출하는데서 BCH를 BCC로 바꿔주겠음
        case .upbit:
            return ["BTC", "ETH", "DASH", "LTC", "ETC", "XRP", "BCH", "XMR", "QTUM", "ZEC", "BTG", "EMC2", "ADA", "SNT", "NEO", "XLM", "XEM", "STRAT", "POWR", "TIX", "STEEM", "MER", "MTL", "SBD", "OMG", "STORJ", "KMD", "ARK", "LSK", "GRS", "PIVX", "WAVES", "VTC", "ARDR"]
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
        case bitfinex.rawValue:
            return .bitfinex
        case bittrex.rawValue:
            return .bittrex
        case upbit.rawValue:
            return .upbit
        default:
            return .bithumb
        }
    }
}
