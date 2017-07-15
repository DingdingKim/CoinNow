//
//  Coin.swift
//  CoinNow
//
//  Created by DingMac on 2017. 7. 13..
//  Copyright © 2017년 DingdingKim. All rights reserved.
//

import Foundation
import Cocoa

enum Coin: String {
    case btc = "BTC", eth = "ETH", dash = "DASH", ltc = "LTC", etc = "ETC", xrp = "XRP"
    static let allValues = ["BTC", "ETH", "DASH", "LTC", "ETC", "XRP"]
    
    func getIndex() -> Int {
        switch self {
        case .btc:
            return 0
        case .eth:
            return 1
        case .dash:
            return 2
        case .ltc:
            return 3
        case .etc:
            return 4
        case .xrp:
            return 5
        }
    }

    static func valueOf(name: String) -> Coin {
        switch name {
        case btc.rawValue:
            return .btc
        case eth.rawValue:
            return .eth
        case dash.rawValue:
            return .dash
        case ltc.rawValue:
            return .ltc
        case etc.rawValue:
            return .etc
        case xrp.rawValue:
            return .xrp
        default:
            return .btc
        }
    }
}
