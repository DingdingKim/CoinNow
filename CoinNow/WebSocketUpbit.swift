//
//  WebSocketUpbit.swift
//  CoinNow
//
//  Created by DingMac on 2017. 7. 13..
//  Copyright © 2017년 DingdingKim. All rights reserved.
//

import Foundation
import Cocoa
import SwiftyJSON

enum WebSocketUpbitChangeType: String, Codable {
    case rise = "RISE", event = "EVEN", fall = "FALL", unknown = "Unknown"
    
    var textColor: NSColor {
        switch self {
        case .rise:
            return .red
            
        case .fall:
            return .blue
            
        default:
            return .black
        }
    }
}

//TODO 굳이 얘가 필요한가? 고민해보기
struct WebSocketUpbit: Codable {
    var code: String
    var market_state: String // ACTIVE인것만 가지고 온다
    var trade_price: Double // 현재가
    var prev_closing_price: Double // 전일 종가
    var change: WebSocketUpbitChangeType //전일대비
    var stream_type: String
    
    //상태바에서 필요
    var displayCurrentPrice: String {
        return trade_price > 0 ? trade_price.withCommas() : ""
    }
    
    init(data: JSON) {
        self.code = data["code"].stringValue
        self.market_state = data["market_state"].stringValue
        self.trade_price = data["trade_price"].doubleValue
        self.prev_closing_price = data["prev_closing_price"].doubleValue
        self.change = WebSocketUpbitChangeType(rawValue: data["change"].stringValue) ?? .unknown
        self.stream_type = data["stream_type"].stringValue
    }
}
//Optional(["market_state": ACTIVE, "prev_closing_price": 1890, "acc_trade_price": 11043395008.2412214, "signed_change_rate": 0.0052910053, "delisting_date": <null>, "code": KRW-MTL, "lowest_52_week_price": 1025, "type": ticker, "timestamp": 1656049455936, "ask_bid": BID, "lowest_52_week_date": 2022-05-12, "trade_time": 054415, "trade_date": 20220624, "change": RISE, "acc_bid_volume": 2457747.94121262, "trade_price": 1900, "acc_trade_price_24h": 47368042431.48254155, "high_price": 1910, "market_warning": NONE, "is_trading_suspended": 0, "low_price": 1830, "acc_trade_volume_24h": 25042665.57172318, "opening_price": 1890, "change_rate": 0.0052910053, "highest_52_week_date": 2021-08-31, "trade_timestamp": 1656049455000, "change_price": 10, "stream_type": REALTIME, "signed_change_price": 10, "acc_ask_volume": 3420633.98908167, "highest_52_week_price": 6400, "trade_volume": 2.77263157, "acc_trade_volume": 5878381.93029429])
