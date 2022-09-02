//
//  WebSocket.swift
//  CoinNow
//
//  Created by DingMac on 2017. 7. 13..
//  Copyright © 2017년 DingdingKim. All rights reserved.
//

import Foundation
import Cocoa
import SwiftyJSON

enum WebSocketPriceChangeType: String, Codable {
    case rise = "RISE", even = "EVEN", fall = "FALL", unknown = "Unknown"
    
    var textColor: NSColor {
        switch self {
        case .rise:
            return .systemRed
            
        case .fall:
            return .systemBlue
            
        default:
            return .black
        }
    }
}

//스타스크림에 웹소켓이라는 이름이 있어서 WSocket로 함ㅠ
struct WSocket: Codable {
    var siteType: SiteType
    var code: String = ""
    var market: String = ""
    var marketAndCode: String {
        return market + "-" + code
    }
    var trade_price: Double // 현재가
    var changeState: WebSocketPriceChangeType //전일대비 업다운
    var timestamp: Double // trade_timestamp 최근 거래 일시(UTC) 포맷: Unix Timestamp
    
    //상태바에서 필요
    var displayCurrentPrice: String {
        return trade_price > 0 ? trade_price.withCommas() : ""
    }
    
    init(from: SiteType, data: JSON) {
        self.siteType = from
        
        switch from {
        case .upbit:
            self.code = String(data["code"].stringValue.split(separator: "-")[1])
            self.market = String(data["code"].stringValue.split(separator: "-")[0])
            self.trade_price = data["trade_price"].doubleValue
            self.changeState = WebSocketPriceChangeType(rawValue: data["change"].stringValue) ?? .unknown
            self.timestamp = data["trade_timestamp"].doubleValue
            
        case .binance, .binanceF:
            let market = String(MyValue.myCoin.split(separator: "-")[0])
            let coin = String(MyValue.myCoin.split(separator: "-")[1])
            
            if (coin + market) == data["s"].stringValue {
                self.code = coin
                self.market = market
            }
            
            //바이낸스는 마켓심볼이 딱 붙어서오기 때문에 구분을 할수가 없다...
            //내 코인들을 다 뒤집어서 가지고있을 수 밖에 ...
            let binanceCoins = MyValue.selectedCoins.filter({ $0.site == from })
            
            for coin in binanceCoins {
                if (coin.code + coin.market) == data["s"].stringValue {
                    self.code = coin.code
                    self.market = coin.market
                    break
                }
            }
            
            self.trade_price = Double(data["c"].stringValue) ?? 0
            
            if let changePrice = Double(data["P"].stringValue) {
                if changePrice == 0 {
                    self.changeState = .even
                }
                else {
                    self.changeState = changePrice > 0 ? .rise : .fall
                }
            }
            else {
                self.changeState = .even
            }
            
            self.timestamp = Double(data["E"].doubleValue) //Event time
        }
    }
}
//업비트
//Optional(["market_state": ACTIVE, "prev_closing_price": 1890, "acc_trade_price": 11043395008.2412214, "signed_change_rate": 0.0052910053, "delisting_date": <null>, "code": KRW-MTL, "lowest_52_week_price": 1025, "type": ticker, "timestamp": 1656049455936, "ask_bid": BID, "lowest_52_week_date": 2022-05-12, "trade_time": 054415, "trade_date": 20220624, "change": RISE, "acc_bid_volume": 2457747.94121262, "trade_price": 1900, "acc_trade_price_24h": 47368042431.48254155, "high_price": 1910, "market_warning": NONE, "is_trading_suspended": 0, "low_price": 1830, "acc_trade_volume_24h": 25042665.57172318, "opening_price": 1890, "change_rate": 0.0052910053, "highest_52_week_date": 2021-08-31, "trade_timestamp": 1656049455000, "change_price": 10, "stream_type": REALTIME, "signed_change_price": 10, "acc_ask_volume": 3420633.98908167, "highest_52_week_price": 6400, "trade_volume": 2.77263157, "acc_trade_volume": 5878381.93029429])

//바낸
//{"e":"24hrTicker","E":1656326918297,"s":"BTCUSDT","p":"51.85000000","P":"0.242","w":"21319.84307967","x":"21391.03000000","c":"21442.89000000","Q":"0.01213000","b":"21442.88000000","B":"3.52375000","a":"21442.89000000","A":"1.61501000","o":"21391.04000000","h":"21888.00000000","l":"20926.01000000","v":"61782.53002000","q":"1317193845.09131810","O":1656240518281,"C":1656326918281,"F":1425622555,"L":1426575555,"n":953001}
