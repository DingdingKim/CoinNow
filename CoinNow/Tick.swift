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
    
    /// 현재가격: -1이면 값을 못가지고 온 상태
    var currentPrice: Double
    /// 전일 종가 대비 업/다운
    var changeState: WebSocketPriceChangeType
    var updateTime: Double
    
    /// 원화: 소수점 둘째자리, BTC: 8째자리(다 1이하), USDT: 3째자리
    var displayCurrentPrice: String {
        if currentPrice < 0 { return "-" }
        else { return currentPrice.withCommas() } //currentPrice > 1 ? currentPrice.withCommas() : String(currentPrice)
    }
    
    var displayUpdateTime: String {
        return updateTime.getDateString(format: "yy.M.d HH:mm:ss")
    }
    
    init(coin: Coin, currentPrice: Double, updateTime: Double, changeState: WebSocketPriceChangeType = .unknown) {
        self.coin = coin
        self.currentPrice = currentPrice
        self.updateTime = updateTime
        self.changeState = changeState
    }
}
