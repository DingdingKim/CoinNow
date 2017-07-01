//
//  InfoCoinBithum.swift
//  DDCurrentCoinState
//
//  Created by DingMac on 2017. 6. 25..
//  Copyright © 2017년 DingdingKim. All rights reserved.
//

import Foundation

struct InfoCoinBithum {
    var coinName: String? //코인 이름
    var opening_price: String? //최근 24시간 내 시작 거래금액
    var closing_price: Int? //최근 24시간 내 마지막 거래금액
    var min_price: String? //최근 24시간 내 최저 거래금액
    var max_price: String? //최근 24시간 내 최고 거래금액
    var average_price: String? //최근 24시간 내 평균 거래금액
    var units_traded: String? //최근 24시간 내 Currency 거래량
    var volume_1day: String? //최근 1일간 Currency 거래량
    var volume_7day: String? //최근 7일간 Currency 거래량
    var buy_price: String? //거래 대기건 최고 구매가
    var sell_price: String? //거래 대기건 최소 판매가
    var date: String? //현재 시간 Timestamp
    
    init(coinName: String, opening_price:String, closing_price:Int, min_price:String, max_price:String, average_price:String, units_traded:String, volume_1day:String, volume_7day:String, buy_price:String, sell_price:String, date:String) {
        self.coinName = coinName
        self.opening_price = opening_price
        self.closing_price = closing_price
        self.min_price = min_price
        self.max_price = max_price
        self.average_price = average_price
        self.units_traded = units_traded
        self.volume_1day = volume_1day
        self.volume_7day = volume_7day
        self.buy_price = buy_price
        self.sell_price = sell_price
        self.date = date
    }
    
    init(coinName: String, closing_price:Int, date:String) {
        self.coinName = coinName
        self.opening_price = ""
        self.closing_price = closing_price
        self.min_price = ""
        self.max_price = ""
        self.average_price = ""
        self.units_traded = ""
        self.volume_1day = ""
        self.volume_7day = ""
        self.buy_price = ""
        self.sell_price = ""
        self.date = date
    }
}
