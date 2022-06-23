//
//  CoinState.swift
//  DDCurrentCoinState
//
//  Created by DingMac on 2017. 6. 25..
//  Copyright © 2017년 DingdingKim. All rights reserved.
//

import Foundation

struct Const {
    static var dicUpdatePerSec: [String : Double] = ["10sec": 10, "20sec": 20, "30sec": 30, "1min": 60, "5min": 300, "10min": 600, "20min": 1200, "30min": 1800, "40min": 2400, "50min": 3000, "1hour": 3600]
    
//    static let HOST_CRYPTOWATCH = "https://api.cryptowat.ch"
    
//    static let COIN_PRICE_LOAD_FAIL = -1.0 //When server does not receive a value
//    static let COIN_PRICE_NO_VALUE = 0.0 //When there is no value to display. This is not fail. (Conin that can not be traded on the site.)
    
    //Default values
    static let DEFAULT_UPDATE_PER: (stirng: String, double: Double) = ("1min", 60)
    static let DEFAULT_MY_COIN = "KRW-BTC"// TODO Coin.btc.rawValue
    static let DEFAULT_MY_SITE = SiteType.upbit.rawValue
    static let DEFAULT_SITE_TYPE: SiteType = .upbit
    static let DEFAULT_LOADING_TEXT = "Loading.."
    
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
