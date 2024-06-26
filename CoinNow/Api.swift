//
//  Api.swift
//  DDCurrentCoinState
//
//  Created by DingMac on 2017. 6. 25..
//  Copyright © 2017년 DingdingKim. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class Api {
    //내 코인 가격
    //marketAndCode: KRW-BTC
    static func getMyCoinTick(marketAndCode: String, complete: @escaping (_ isSuccess: Bool, _ results: String?) -> Void) {
        print("getMyCoinTick: \(MyValue.mySiteType)")
        
        if MyValue.mySiteType == .upbit {
            Alamofire.request("\(Const.REST_UPBIT)/v1/ticker?markets=\(marketAndCode)", method: .get).responseJSON { (responseData) -> Void in
                guard let resultValue = responseData.result.value else { complete(false, nil); return }
                guard let resultTicks = (JSON(resultValue)).array, resultTicks.count > 0 else { complete(false, nil); return }
                guard let currentPrice = resultTicks[0]["trade_price"].double else { complete(false, nil); return }
                
                complete(true, currentPrice.withCommas())
            }
        }
        else if MyValue.mySiteType == .binance {
            //바낸은 이게 뒤집어져있네ㅠ
            //업빗: 마켓-코인
            //바낸: 코인마켓
            let splited = marketAndCode.split(separator: "-")
            
            guard splited.count > 0 else { complete(false, nil); return }
            
            Alamofire.request("\(Const.REST_BINANCE)/api/v3/ticker/price?symbol=\(splited[1])\(splited[0])", method: .get).responseJSON { (responseData) -> Void in
                guard let resultValue = responseData.result.value else { complete(false, nil); return }
                guard let resultTick = JSON(resultValue).dictionaryObject else { complete(false, nil); return }
                guard let currentPrice = resultTick["price"] as? String else { complete(false, nil); return }
                
                complete(true, currentPrice)
            }
        }
    }
    
    //Upbit 현재 가격. 안씀
    static func getUpbitTicks(selectedCoins: [Coin], complete: @escaping (_ isSuccess: Bool, _ results: [Tick]) -> Void){
        var ticks = [Tick]()
        
        let marketAndCodeList = selectedCoins.filter { $0.site == .upbit }
                                                .map { $0.marketAndCode }.joined(separator: ",")

        Alamofire.request("\(Const.REST_UPBIT)/v1/ticker?markets=\(marketAndCodeList)", method: .get).responseJSON { (responseData) -> Void in
            guard let resultValue = responseData.result.value else { complete(false, []); return }
            guard let resultTicks = (JSON(resultValue)).array else { complete(false, []); return }
            
            for coin in selectedCoins {
                for tick in resultTicks {
                    if tick["market"].stringValue == coin.marketAndCode {
                        ticks.append(Tick(coin: coin, currentPrice: tick["trade_price"].doubleValue, updateTime: 0))
                    }
                }
            }
            
            complete(true, ticks)
        }
    }
    
    //바낸 현재 가격. 안씀
    static func getBinanceTicks(selectedCoins: [Coin], complete: @escaping (_ isSuccess: Bool, _ results: [Tick]) -> Void){
        var ticks = [Tick]()
        
        let marketAndCodeList = selectedCoins.filter { $0.site == .upbit }
                                                .map { $0.marketAndCode }.joined(separator: ",")

        Alamofire.request("\(Const.REST_BINANCE)/api/v3/ticker/price?symbols=\(marketAndCodeList)", method: .get).responseJSON { (responseData) -> Void in
            guard let resultValue = responseData.result.value else { complete(false, []); return }
            //1개면 오브젝트로 리턴. 여러개면 배열
            guard let resultTick = JSON(resultValue).dictionaryObject else { complete(false, []); return }
            //guard let resultTicks = (JSON(resultValue)).array else { complete(false, []); return }
            
            for coin in selectedCoins {
                if let symbol = resultTick["symbol"] as? String, symbol == coin.marketAndCode,
                    let price = resultTick["price"] as? Double {
                    ticks.append(Tick(coin: coin, currentPrice: price, updateTime: 0))
                }
            }
            
            complete(true, ticks)
        }
    }
    
    //Upbit 코인 다 가져오기
    static func getUpbitCoins(complete: @escaping (_ isSuccess: Bool, _ results: [Coin]) -> Void) {
        var coins = [Coin]()
        
        Alamofire.request("\(Const.REST_UPBIT)/v1/market/all", method: .get).responseJSON { (responseData) -> Void in
            guard let resultValue = responseData.result.value else { complete(false, []); return }
            guard let resultCoins = (JSON(resultValue)).array else { complete(false, []); return }
            
            for coin in resultCoins {
                coins.append(Coin(from: .upbit, data: coin))
            }
            
            complete(true, coins)
        }
    }
    
    //바낸 코인 다 가져오기
    static func getBinanceCoins(complete: @escaping (_ isSuccess: Bool, _ results: [Coin]) -> Void) {
        var coins = [Coin]()
        
        Alamofire.request("\(Const.REST_BINANCE)/api/v3/exchangeInfo", method: .get).responseJSON { (responseData) -> Void in
            guard let resultValue = responseData.result.value else { complete(false, []); return }
            guard let resultCoins = JSON(resultValue)["symbols"].array else { complete(false, []); return }
            
            //거래 가능만 들고온다
            let availableCoins = resultCoins.filter { $0["isSpotTradingAllowed"].boolValue &&
                                                        $0["status"].stringValue == "TRADING" &&
                                                        SiteType.binance.markets.contains($0["quoteAsset"].stringValue)}
            
            for coin in availableCoins {
                coins.append(Coin(from: .binance, data: coin))
            }
            
            complete(true, coins)
        }
    }
    
    //바낸 선물 코인 다 가져오기
    static func getBinanceFutureCoins(complete: @escaping (_ isSuccess: Bool, _ results: [Coin]) -> Void) {
        var coins = [Coin]()
        
        Alamofire.request("\(Const.REST_BINANCE_F)/fapi/v1/exchangeInfo", method: .get).responseJSON { (responseData) -> Void in
            guard let resultValue = responseData.result.value else { complete(false, []); return }
            guard let resultCoins = JSON(resultValue)["symbols"].array else { complete(false, []); return }
            
            //거래 가능만 && delivery(만기일 있는거) 제외 들고온다
            let availableCoins = resultCoins.filter { $0["status"].stringValue == "TRADING" &&
                                                    $0["contractType"].stringValue == "PERPETUAL" &&
                                                        SiteType.binance.markets.contains($0["quoteAsset"].stringValue)}
            
            for coin in availableCoins {
                coins.append(Coin(from: .binanceF, data: coin))
            }
            
            complete(true, coins)
        }
    }
}
