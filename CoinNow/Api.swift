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
    static let API_STATUS_CODE_SUCCESS_BITHUMB = "0000"
    static let API_STATUS_CODE_SUCCESS_COINONE = "0"
    static let API_STATUS_CODE_SUCCESS_DING = 200
    
    static func getCoinsStateBithumb(arrSelectedCoins: [String], complete: @escaping (_ isSuccess: Bool, _ arrResult: [InfoCoin]) -> Void) {
        var arrResult = addEmptyCoin(arrSelectedCoins: arrSelectedCoins, arrTradableCoins: Market.bithumb.arrTradableCoin())
        
        Alamofire.request("https://api.bithumb.com/public/ticker/ALL", method: .get).responseJSON { (responseData) -> Void in
            guard let resultValue = responseData.result.value else { complete(false, makeResultArrayOfFail()); return }
            let resultValuseJson = (JSON(resultValue))
            
            guard resultValuseJson["status"].stringValue == API_STATUS_CODE_SUCCESS_BITHUMB else { complete(false, makeResultArrayOfFail()); return }
            
            for coinName in arrSelectedCoins {
                //Add only tradable coins
                guard Market.bithumb.arrTradableCoin().contains(coinName) else { complete(false, makeResultArrayOfFail()); continue}
                
                guard let currentPrice = resultValuseJson["data"][coinName]["closing_price"].string else { complete(false, makeResultArrayOfFail()); continue }
                
                let infoCoin = InfoCoin(coin: Coin.valueOf(name: coinName), currentPrice: (Double(currentPrice) ?? CoinPrice.fail.rawValue))
                arrResult.append(infoCoin)
            }
            complete(true, arrResult)
        }
    }
    
    static func getCoinsStateCoinone(arrSelectedCoins: [String], complete: @escaping (_ isSuccess: Bool, _ arrResult: [InfoCoin]) -> Void){
        var arrResult = addEmptyCoin(arrSelectedCoins: arrSelectedCoins, arrTradableCoins: Market.coinone.arrTradableCoin())
        
        Alamofire.request("https://api.coinone.co.kr/ticker/?currency=all", method: .get).responseJSON { (responseData) -> Void in
            guard let resultValue = responseData.result.value else { complete(false, makeResultArrayOfFail()); return }
            let resultValuseJson = (JSON(resultValue))
            
            guard resultValuseJson["errorCode"].stringValue == API_STATUS_CODE_SUCCESS_COINONE else { complete(false, makeResultArrayOfFail()); return }
            
            for coinName in arrSelectedCoins {
                guard Market.coinone.arrTradableCoin().contains(coinName) else { complete(false, makeResultArrayOfFail()); continue}
                
                guard let currentPrice = resultValuseJson[coinName.lowercased()]["last"].string else { complete(false, makeResultArrayOfFail()); continue}
                
                let infoCoin = InfoCoin(coin: Coin.valueOf(name: coinName), currentPrice: (Double(currentPrice) ?? CoinPrice.fail.rawValue))
                arrResult.append(infoCoin)
            }
            complete(true, arrResult)
        }
    }
    
    //Upbit 다이쪄
    static func getCoinsStateUpbit(arrSelectedCoins: [String], complete: @escaping (_ isSuccess: Bool, _ arrResult: [InfoCoin]) -> Void){
        var arrResult = addEmptyCoin(arrSelectedCoins: arrSelectedCoins, arrTradableCoins: Market.upbit.arrTradableCoin())

        for coinName in arrSelectedCoins {
            guard Market.upbit.arrTradableCoin().contains(coinName) else { complete(false, makeResultArrayOfFail()); continue}
            
            Alamofire.request("https://api.upbit.com/v1/ticker?markets=KRW-\(coinName == "BCH" ? "BCC" : coinName)", method: .get).responseJSON { (responseData) -> Void in
                guard let resultValue = responseData.result.value else { complete(false, makeResultArrayOfFail()); return}
                guard let jsonArrayTick = (JSON(resultValue)).array else { complete(false, makeResultArrayOfFail()); return}
                guard let currentPrice = jsonArrayTick[0]["trade_price"].double else { complete(false, makeResultArrayOfFail()); return}
                
                let infoCoin = InfoCoin(coin: Coin.valueOf(name: coinName), currentPrice: currentPrice)
                arrResult.append(infoCoin)
                
                //callback when finish last item request
                if(arrResult.count == Coin.allValues.count) {
                    //After all request is finished
                    complete(true, arrResult)
                }
            }
        }
    }
    
    //Add empty object(Not selected coins and Not tradable coins in that market)
    static func addEmptyCoin(arrSelectedCoins: [String], arrTradableCoins: [String]) -> [InfoCoin] {
        var arrResult = [InfoCoin]()
        
        for coinName in Coin.allValues {
            if(!arrSelectedCoins.contains(coinName) || !arrTradableCoins.contains(coinName)) {
                let infoCoin = InfoCoin(coin: Coin.valueOf(name: coinName), currentPrice: CoinPrice.noValue.rawValue)
                arrResult.append(infoCoin)
            }
        }
        
        return arrResult
    }
    
    //currentPrice == -1 is Fail
    static func makeResultArrayOfFail() -> [InfoCoin] {
        var arrResult = [InfoCoin]()
        
        for coinName in Coin.allValues {
            let infoCoin = InfoCoin(coin: Coin.valueOf(name: coinName), currentPrice: CoinPrice.fail.rawValue)
            arrResult.append(infoCoin)
        }
        
        return arrResult
    }
}
