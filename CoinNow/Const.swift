//
//  CoinState.swift
//  DDCurrentCoinState
//
//  Created by DingMac on 2017. 6. 25..
//  Copyright © 2017년 DingdingKim. All rights reserved.
//

import Foundation

class Const {
    static var arrCoinName = ["BTC", "ETH", "DASH", "LTC", "ETC", "XRP"]
    static var arrUpdatePerString = ["10sec", "20sec", "30sec", "1min", "5min", "10min", "20min", "30min", "40min", "50min", "1hour"]
    static var arrUpdatePerInt: [Double] = [10, 20, 30, 60, 300, 600, 1200, 1800, 2400, 3000, 3600]
    
    struct UserDefaultKey {
        //Coin that show in status bar
        static let MY_COIN="MY_COIN"
        //Trading site that show in status bar
        static let MY_SITE="MY_SITE"
        static let UPDATE_PER="UPDATE_PER"
    }
    
    struct Coin {
        static let BTC = "BTC"
        static let ETH = "ETH"
        static let DASH = "DASH"
        static let LTC = "LTC"
        static let ETC = "ETC"
        static let XRP = "XRP"
    }
    
    struct CoinIndex {
        static let BTC = 0
        static let ETH = 1
        static let DASH = 2
        static let LTC = 3
        static let ETC = 4
        static let XRP = 5
    }
}
