//
//  Tick.swift
//  DDCurrentCoinState
//
//  Created by DingMac on 2017. 6. 29..
//  Copyright © 2017년 DingdingKim. All rights reserved.
//

import Foundation

struct Tick {
    var coin: Coin
    var currentPrice: Double
    
    init(coin: Coin, currentPrice: Double) {
        self.coin = coin
        self.currentPrice = currentPrice
    }
}
