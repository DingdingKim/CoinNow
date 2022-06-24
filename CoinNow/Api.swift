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
        if MyValue.mySiteType == .upbit {
            Alamofire.request("https://api.upbit.com/v1/ticker?markets=\(marketAndCode)", method: .get).responseJSON { (responseData) -> Void in
                guard let resultValue = responseData.result.value else { complete(false, nil); return}
                guard let resultTicks = (JSON(resultValue)).array, resultTicks.count > 0 else { complete(false, nil); return}
                guard let currentPrice = resultTicks[0]["trade_price"].double else { complete(false, nil); return}
                
                complete(true, currentPrice.withCommas())
            }
        }
        else if MyValue.mySiteType == .binance {
            // TODO 바낸 구현
            
            complete(false, "-")
        }
    }
    
    //Upbit 현재 가격
    static func getUpbitTicks(selectedCoins: [Coin], complete: @escaping (_ isSuccess: Bool, _ results: [Tick]) -> Void){
        var ticks = [Tick]()
        
        let marketAndCodeList = selectedCoins.filter { $0.site == .upbit }
                                                .map { $0.marketAndCode }.joined(separator: ",")

        Alamofire.request("https://api.upbit.com/v1/ticker?markets=\(marketAndCodeList)", method: .get).responseJSON { (responseData) -> Void in
            guard let resultValue = responseData.result.value else { complete(false, []); return}
            guard let resultTicks = (JSON(resultValue)).array else { complete(false, []); return}
            
            for coin in selectedCoins {
                for tick in resultTicks {
                    if tick["market"].stringValue == coin.marketAndCode {
                        ticks.append(Tick(coin: coin, currentPrice: tick["trade_price"].doubleValue))
                    }
                }
            }
            
            complete(true, ticks)
        }
    }
    
    //Upbit 코인 다 가져오기
    static func getUpbitCoins(complete: @escaping (_ isSuccess: Bool, _ results: [Coin]) -> Void) {
        var coins = [Coin]()
        
        Alamofire.request("https://api.upbit.com/v1/market/all", method: .get).responseJSON { (responseData) -> Void in
            guard let resultValue = responseData.result.value else { complete(false, []); return}
            guard let resultCoins = (JSON(resultValue)).array else { complete(false, []); return}
            
            for coin in resultCoins {
                coins.append(Coin(from: .upbit, data: coin))
            }
            
            complete(true, coins)
        }
    }
}
