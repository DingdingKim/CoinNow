//
//  CoinState.swift
//  DDCurrentCoinState
//
//  Created by DingMac on 2017. 6. 25..
//  Copyright © 2017년 DingdingKim. All rights reserved.
//

import Foundation

enum UpdatePer: String, CaseIterable {
    case realTime = "RealTime", sec5 = "5 sec", sec15 = "15 sec", sec30 = "30 sec", min1 = "1 min", min5 = "5 min", min15 = "15 min", min30 = "30 min", min60 = "1 hour"
    
    var sec: Double {
        switch self {
        case .realTime: return 0
        case .sec5: return 5
        case .sec15: return 15
        case .sec30: return 30
        case .min1: return 60
        case .min5: return 300
        case .min15: return 900
        case .min30: return 1800
        case .min60: return 3600
        }
    }
}

struct Const {
    //Default values
    static let DEFAULT_UPDATE_PER: UpdatePer = .realTime
    static let DEFAULT_MY_COIN = "KRW-BTC"// TODO Coin.btc.rawValue
    static let DEFAULT_MY_SITE = SiteType.upbit.rawValue
    static let DEFAULT_SITE_TYPE: SiteType = .upbit
    static let DEFAULT_LOADING_TEXT = "Loading.."
    
    static let REST_UPBIT = "https://api.upbit.com"
    static let REST_BINANCE = "https://api.binance.com"
    static let REST_BINANCE_F = "https://fapi.binance.com"

    static let WEBSOCKET_UPBIT = "wss://api.upbit.com/websocket/v1"
    static let WEBSOCKET_BINANCE = "wss://stream.binance.com:9443/ws"
    static let WEBSOCKET_BINANCE_F = "wss://fstream.binance.com/ws"
    
    struct UserDefaultKey {
        static let MY_COIN = "MY_COIN" //Coin that show in status bar
        static let MY_SITE = "MY_SITE" //Trading site that show in status bar
        static let UPDATE_PER = "UPDATE_PER" //type is String(keys of dicUpdatePerSec)
        static let IS_SHOW_ICON = "IS_SHOW_ICON" //Show icon in statusbar
        static let IS_SHOW_MARKET = "IS_SHOW_MARKET" //Show market code in statusbar
        
        //will update by selected coin
        static let SELECTED_COINS = "SELECTED_COINS"
        static let IS_SIMPLE_MODE = "IS_SIMPLE_MODE"
    }
}
