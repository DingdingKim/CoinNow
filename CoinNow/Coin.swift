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
    case btc = "BTC", eth = "ETH", dash = "DASH", ltc = "LTC", etc = "ETC", xrp = "XRP", bch = "BCH", xmr = "XMR", qtum = "QTUM", zec = "ZEC", btg = "BTG", iota = "IOTA", emc2 = "EMC2", eos = "EOS", ada = "ADA", snt = "SNT", neo = "NEO", xlm = "XLM", xem = "XEM", strat = "STRAT", powr = "POWR", tix = "TIX", steem = "STEEM", mer = "MER", mtl = "MTL", sbd = "SBD", omg = "OMG", storj = "STORJ", kmd = "KMD", ark = "ARK", lsk = "LSK", grs = "GRS", pivx = "PIVX", waves = "WAVES", vtc = "VTC", ardr = "ARDR";
    static let allValues = ["BTC", "ETH", "DASH", "LTC", "ETC", "XRP", "BCH", "XMR", "QTUM", "ZEC", "BTG", "IOTA", "EMC2", "EOS", "ADA", "SNT", "NEO", "XLM", "XEM", "STRAT", "POWR", "TIX", "STEEM", "MER", "MTL", "SBD", "OMG", "STORJ", "KMD", "ARK", "LSK", "GRS", "PIVX", "WAVES", "VTC", "ARDR"]
    static let defaultSelectedValues = ["BTC", "ETH", "DASH", "LTC", "ETC", "XRP", "BCH", "XMR"]
    
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
        case .emc2:
            return 12
        case .eos:
            return 13
        case .ada:
            return 14
        case .snt:
            return 15
        case .neo:
            return 16
        case .xlm:
            return 17
        case .xem:
            return 18
        case .strat:
            return 19
        case .powr:
            return 20
        case .tix:
            return 21
        case .steem:
            return 22
        case .mer:
            return 23
        case .mtl:
            return 24
        case .sbd:
            return 25
        case .omg:
            return 26
        case .storj:
            return 27
        case .kmd:
            return 28
        case .ark:
            return 29
        case .lsk:
            return 30
        case .grs:
            return 31
        case .pivx:
            return 32
        case .waves:
            return 33
        case .vtc:
            return 34
        case .ardr:
            return 35
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
        case emc2.rawValue:
            return .emc2
        case eos.rawValue:
            return .eos
        case ada.rawValue:
            return .ada
        case snt.rawValue:
            return .snt
        case neo.rawValue:
            return .neo
        case xlm.rawValue:
            return .xlm
        case xem.rawValue:
            return .xem
        case strat.rawValue:
            return .strat
        case powr.rawValue:
            return .powr
        case tix.rawValue:
            return .tix
        case steem.rawValue:
            return .steem
        case mer.rawValue:
            return .mer
        case mtl.rawValue:
            return .mtl
        case sbd.rawValue:
            return .sbd
        case omg.rawValue:
            return .omg
        case storj.rawValue:
            return .storj
        case kmd.rawValue:
            return .kmd
        case ark.rawValue:
            return .ark
        case lsk.rawValue:
            return .lsk
        case grs.rawValue:
            return .grs
        case pivx.rawValue:
            return .pivx
        case waves.rawValue:
            return .waves
        case vtc.rawValue:
            return .vtc
        case ardr.rawValue:
            return .ardr
        default:
            return .btc
        }
    }
}
