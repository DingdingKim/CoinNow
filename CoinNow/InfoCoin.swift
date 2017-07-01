//
//  InfoCoin.swift
//  DDCurrentCoinState
//
//  Created by DingMac on 2017. 6. 29..
//  Copyright © 2017년 DingdingKim. All rights reserved.
//

import Foundation

struct InfoCoin {
    var coinName: String? //코인 이름
    var current_price: Double? //현재 가격
    var date: String? //현재 시간 Timestamp
    
    init(coinName: String, current_price:Double, date:String) {
        self.coinName = coinName
        self.current_price = current_price
        self.date = date
    }
}
