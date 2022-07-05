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
    
    var currentPrice: Double//현재가격: -1이면 값을 못가지고 온 상태
    var changeState: WebSocketPriceChangeType//전일 종가 대비 업/다운
    //var isActive: Bool//거래가능 상태인가
    
    //원화: 소수점 둘째자리, BTC: 8째자리(다 1이하),  USDT: 3째자리
    var displayCurrentPrice: String {
//        if coin.market == "KRW" {
//            return currentPrice = String(format: "%.2f", 145.332)
//        }
        return currentPrice > 1 ? currentPrice.withCommas() : String(currentPrice)
    }
    
    init(coin: Coin, currentPrice: Double, changeState: WebSocketPriceChangeType = .unknown) {
        self.coin = coin
        self.currentPrice = currentPrice
        self.changeState = changeState
    }
}
