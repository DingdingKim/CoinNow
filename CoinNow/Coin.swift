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
    case btc = "BTC", eth = "ETH", dash = "DASH", ltc = "LTC", etc = "ETC", xrp = "XRP", bch = "BCH"
    static let allValues = ["BTC", "ETH", "DASH", "LTC", "ETC", "XRP", "BCH"]
    
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
        case .bch:
            return 6
        }
    }
    
    static func donateAddress(index: Int) -> String {
        switch index {
        case btc.getIndex():
            return "1JbmDy892gKGYMaWU5D9V11Qd9zsTXijZg"
        case eth.getIndex():
            return "0x8c38c68ccd6a0f9c8e4f9996da53cba61016b4ed"
        case dash.getIndex():
            return "XcZVkpJ3AWP5PeVhd78d85w8TGbsfWfjsk"
        case ltc.getIndex():
            return "LbknpNGdpnDW6NRc4sbkFeu8yhvoFdo4yn"
        case etc.getIndex():
            return "0x68d3e549bfe631ec4f4916070d8fdb6c9bed669c"
        case xrp.getIndex():
            return "rsG1sNifXJxGS2nDQ9zHyoe1S5APrtwpjV (DT 1000581537)"
        case bch.getIndex():
            return "16QPpstvKgGAY6Gfcfao2DeFfSyWLWtM5L"
        default:
            return "1JbmDy892gKGYMaWU5D9V11Qd9zsTXijZg"
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
        case bch.rawValue:
            return .bch
        default:
            return .btc
        }
    }
}
