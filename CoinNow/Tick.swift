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
    var changeState: WebSocketUpbitChangeType//전일 종가 대비 업/다운
    //var isActive: Bool//거래가능 상태인가
    
    var displayCurrentPrice: String {
        return currentPrice > 0 ? currentPrice.withCommas() : ""
    }
    
    init(coin: Coin, currentPrice: Double, changeState: WebSocketUpbitChangeType = .unknown) {
        self.coin = coin
        self.currentPrice = currentPrice
        self.changeState = changeState
    }
}
