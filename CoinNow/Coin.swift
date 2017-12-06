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
    case btc = "BTC", eth = "ETH", dash = "DASH", ltc = "LTC", etc = "ETC", xrp = "XRP", bch = "BCH", xmr = "XMR", qtum = "QTUM", zec = "ZEC", btg = "BTG", iota = "IOTA"
    static let allValues = ["BTC", "ETH", "DASH", "LTC", "ETC", "XRP", "BCH", "XMR", "QTUM", "ZEC", "BTG", "IOTA"]
    
    func index() -> Int {
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
        case .xmr:
            return 7
        case .qtum:
            return 8
        case .zec:
            return 9
        case .btg:
            return 10
        case .iota:
            return 11
        }
    }
    
    static func donateAddress(index: Int) -> String {
        switch index {
        case btc.index():
            return "1JbmDy892gKGYMaWU5D9V11Qd9zsTXijZg"
        case eth.index():
            return "0x8c38c68ccd6a0f9c8e4f9996da53cba61016b4ed"
        case dash.index():
            return "XcZVkpJ3AWP5PeVhd78d85w8TGbsfWfjsk"
        case ltc.index():
            return "LbknpNGdpnDW6NRc4sbkFeu8yhvoFdo4yn"
        case etc.index():
            return "0x68d3e549bfe631ec4f4916070d8fdb6c9bed669c"
        case xrp.index():
            return "rsG1sNifXJxGS2nDQ9zHyoe1S5APrtwpjV (DT 1000581537)"
        case bch.index():
            return "16QPpstvKgGAY6Gfcfao2DeFfSyWLWtM5L"
        case xmr.index():
            return "4L7DhwADX9Y6wN7BfFBaEfF3Fw8uc3LiV8NUpTXgNDk8EeP732b1yRxJGuNLwr4nowbn7g6kocN5LgVGVqsXuSseHCHdW89LLsZCUNaubp"
        default:
            return "I have no address of QTUM"
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
        case xmr.rawValue:
            return .xmr
        case qtum.rawValue:
            return .qtum
        case zec.rawValue:
            return .zec
        case btg.rawValue:
            return .btg
        case iota.rawValue:
            return .iota
        default:
            return .btc
        }
    }
}
