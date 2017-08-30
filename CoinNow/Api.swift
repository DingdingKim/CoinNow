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
    
    static func getCoinsStateBithum(arrSelectedCoins: [String], complete:@escaping (_ isSuccess: Bool, _ arrResult: [InfoCoin]) -> Void){
        
        //After get exchange rate then get price and exchange the price to base currency
        Api.getExchangeRate(from: .krw, complete: {isSuccess, exchangeRate in
            if(isSuccess){
                
                //Add empty coins that not tradable in this site.
                var arrResult = addEmptyCoin(arrSelectedCoins: arrSelectedCoins)
                
                Alamofire.request("https://api.bithumb.com/public/ticker/ALL", method: .get).responseJSON { (responseData) -> Void in
                    guard let resultValue = responseData.result.value else { return }
                    let resultValuseJson = (JSON(resultValue))
                    
                    if let statusCode = resultValuseJson["status"].string, statusCode == API_STATUS_CODE_SUCCESS_BITHUMB {
                        for coinName in arrSelectedCoins {
                            guard let currentPrice = resultValuseJson["data"][coinName]["closing_price"].string else {continue}
                            let exchangedPrice = (Double(currentPrice) ?? 0.0) * exchangeRate
                            
                            //debugPrint("getCoinsStateBithum >> \(currentPrice) / \(exchangeRate) : \(exchangedPrice)")
                            
                            let infoCoin = InfoCoin(coin: Coin.valueOf(name: coinName), currentPrice: exchangedPrice)
                            arrResult.append(infoCoin)
                        }
                        complete(true, arrResult)
                        
                    }
                    else {
                        complete(false, arrResult)
                    }
                    
                    
                }
            }
        })
    }
    
    static func getCoinsStateCoinone(arrSelectedCoins: [String], complete:@escaping (_ isSuccess: Bool, _ arrResult: [InfoCoin]) -> Void){
        
        Api.getExchangeRate(from: .krw, complete: {isSuccess, exchangeRate in
            if(isSuccess){
                
                var arrResult = addEmptyCoin(arrSelectedCoins: arrSelectedCoins)
                
                Alamofire.request("https://api.coinone.co.kr/ticker/?currency=all", method: .get).responseJSON { (responseData) -> Void in
                    guard let resultValue = responseData.result.value else { return }
                    let resultValuseJson = (JSON(resultValue))
                    
                    if let statusCode = resultValuseJson["errorCode"].string, statusCode == API_STATUS_CODE_SUCCESS_COINONE {
                        for coinName in arrSelectedCoins {
                            if(resultValuseJson[coinName.lowercased()].exists()) {
                                guard let currentPrice = resultValuseJson[coinName.lowercased()]["last"].string else {continue}
                                let exchangedPrice = (Double(currentPrice) ?? 0.0) * exchangeRate
                                
                                //debugPrint("getCoinsStateCoinone >> \(currentPrice) / \(exchangeRate) : \(exchangedPrice)")
                                
                                let infoCoin = InfoCoin(coin: Coin.valueOf(name: coinName), currentPrice: exchangedPrice)
                                arrResult.append(infoCoin)
                            }
                            else {
                                //Add empty coin
                                let infoCoin = InfoCoin(coin: Coin.valueOf(name: coinName), currentPrice: 0.0)
                                arrResult.append(infoCoin)
                            }
                        }
                        complete(true, arrResult)
                    
                    }
                    else {
                        complete(false, arrResult)
                    }
                }
            }
        })
    }
    
    static func getCoinsStatePoloniex(arrSelectedCoins: [String], complete:@escaping (_ isSuccess: Bool, _ arrResult: [InfoCoin]) -> Void) {
        
        Api.getExchangeRate(from: .usd, complete: {isSuccess, exchangeRate in
            if(isSuccess){
                var arrResult = addEmptyCoin(arrSelectedCoins: arrSelectedCoins)
                
                Alamofire.request("https://poloniex.com/public?command=returnTicker", method: .get).responseJSON { (responseData) -> Void in
                    guard let resultValue = responseData.result.value else { return }
                    let resultValuseJson = (JSON(resultValue))
                    
                    for coinName in arrSelectedCoins {
                        guard let currentPrice = resultValuseJson["USDT_\(coinName)"]["last"].string else {continue}
                        let exchangedPrice = (Double(currentPrice) ?? 0.0) * (exchangeRate)// * Const.USDT_RATE
                        
                        //debugPrint("getCoinsStatePoloniex >> \(currentPrice) / \(exchangeRate) : \(exchangedPrice)")
                        
                        let infoCoin = InfoCoin(coin: Coin.valueOf(name: coinName), currentPrice: exchangedPrice)
                        arrResult.append(infoCoin)
                    }
                    complete(true, arrResult)
                }
            }
        })
    }
    
    /*
    static func getCoinsStatePoloniexByCryptowatch(arrSelectedCoins: [String], complete:@escaping (_ isSuccess: Bool, _ arrResult: [InfoCoin]) -> Void){
        
        //After get exchange rate then get price and exchange the price to base currency
        Api.getExchangeRate(from: .usd, complete: {isSuccess, exchangeRate in
            if(isSuccess){
                //Add empty coins that not tradable in this site.
                var arrResult = addEmptyCoin(arrSelectedCoins: arrSelectedCoins)
                
                for coinName in arrSelectedCoins {
                    Alamofire.request("https://api.cryptowat.ch/markets/poloniex/\(coinName)usd/price", method: .get).responseJSON { (responseData) -> Void in
                        if((responseData.result.value) != nil) {
                            let swiftyJsonVar = JSON(responseData.result.value!)
                            
                            let currentPrice = swiftyJsonVar["result"]["price"].stringValue
                            let exchangedPrice = (Double(currentPrice) ?? 0.0) * exchangeRate
                            
                            //debugPrint("getCoinsStateOkcoin >> \(currentPrice) / \(exchangeRate) : \(exchangedPrice)")
                            
                            let infoCoin = InfoCoin(coin: Coin.valueOf(name: coinName), currentPrice: exchangedPrice)
                            arrResult.append(infoCoin)
                            
                            //callback when finish last item request
                            if(arrResult.count == Coin.allValues.count) {
                                //After all request is finished
                                complete(true, arrResult)
                            }
                        }
                    }
                }
            }
        })
    }
     */
    
    static func getCoinsStateOkcoin(arrSelectedCoins: [String], complete:@escaping (_ isSuccess: Bool, _ arrResult: [InfoCoin]) -> Void){
        
        Api.getExchangeRate(from: .cny, complete: {isSuccess, exchangeRate in
            if(isSuccess){
                var arrResult = addEmptyCoin(arrSelectedCoins: arrSelectedCoins)
                
                for coinName in arrSelectedCoins {
                    
                    //Okcoin offers only BTC, ETH, LTC
                    if(Site.okcoin.arrTradableCoin().contains(coinName)) {
                        
                        Alamofire.request("https://www.okcoin.cn/api/v1/ticker.do?symbol=\(coinName)_cny", method: .get).responseJSON { (responseData) -> Void in
                            guard let resultValue = responseData.result.value else { return }
                            guard let currentPrice = (JSON(resultValue))["ticker"]["last"].string else {return}
                            let exchangedPrice = (Double(currentPrice) ?? 0.0) * exchangeRate
                            
                            //debugPrint("getCoinsStateOkcoin >> \(currentPrice) / \(exchangeRate) : \(exchangedPrice)")
                            
                            let infoCoin = InfoCoin(coin: Coin.valueOf(name: coinName), currentPrice: exchangedPrice)
                            arrResult.append(infoCoin)
                            
                            //callback when finish last item request
                            if(arrResult.count == Coin.allValues.count) {
                                //After all request is finished
                                complete(true, arrResult)
                            }
                        }
                    }
                    else{
                        let infoCoin = InfoCoin(coin: Coin.valueOf(name: coinName), currentPrice: 0.0)
                        arrResult.append(infoCoin)
                    }
                }
            }
        })
    }
    
    static func getCoinsStateHuobiByCryptowatch(arrSelectedCoins: [String], complete:@escaping (_ isSuccess: Bool, _ arrResult: [InfoCoin]) -> Void){
        
        Api.getExchangeRate(from: .cny, complete: {isSuccess, exchangeRate in
            if(isSuccess){
                var arrResult = addEmptyCoin(arrSelectedCoins: arrSelectedCoins)
                
                for coinName in arrSelectedCoins {
                    
                    //Huobi offers only BTC, LTC
                    if(Site.okcoin.arrTradableCoin().contains(coinName)) {
                        Alamofire.request("https://api.cryptowat.ch/markets/huobi/\(coinName)cny/price", method: .get).responseJSON { (responseData) -> Void in
                            guard let resultValue = responseData.result.value else { return }
                            guard let currentPrice = (JSON(resultValue))["result"]["price"].double else {return}
                            let exchangedPrice = currentPrice * exchangeRate
                            
                            //debugPrint("getCoinsStateHuobiByCryptowatch >> \(currentPrice) / \(exchangeRate) : \(exchangedPrice)")

                            let infoCoin = InfoCoin(coin: Coin.valueOf(name: coinName), currentPrice: exchangedPrice)
                            arrResult.append(infoCoin)
                            
                            //callback when finish last item request
                            if(arrResult.count == Coin.allValues.count) {
                                //After all request is finished
                                complete(true, arrResult)
                            }
                        }
                    }
                    else{
                        let infoCoin = InfoCoin(coin: Coin.valueOf(name: coinName), currentPrice: 0.0)
                        arrResult.append(infoCoin)
                    }
                }
            }
        })
    }
    
    //From Dingding server api
    //Caching update time
    static var lastUpdateTimeOfExchangeRate: [String:Date] = ["KRWUSD": Date(), "KRWCNY": Date(), "USDKRW": Date(), "USDCNY": Date(), "CNYUSD": Date(), "CNYKRW": Date()]
    static var cachedexchangeRate: [String:Double] = ["KRWUSD": 0, "KRWCNY": 0, "USDKRW": 0, "USDCNY": 0, "CNYUSD": 0, "CNYKRW": 0]
    
    static func getExchangeRate(from: BaseCurrency, complete:@escaping (_ isSuccess: Bool, _ result: Double) -> Void){
        let pairOfCurrency = from.rawValue + MyValue.myBaseCurrency.rawValue
        
        //Same currency. return 1
        if(from.rawValue == MyValue.myBaseCurrency.rawValue) {
            complete(true, 1)
        }
            // NOT(caching data is valid(data is valid during 1 hour) || no cached data)
        else if((lastUpdateTimeOfExchangeRate[pairOfCurrency]!.isTimeToUpdateExchangeRate()) || cachedexchangeRate[pairOfCurrency] == 0) {
            //Yahoo exchange rate API ... bye ... 😭
            //The data is from Dingding server(The data is updated by Dingding. So not realtime).
            //*******************PLEASE Do not use this api ... I have no money for running large server. 🤑
            Alamofire.request("http://coinnow.herokuapp.com/coinnow/api/getExchangeRate?pair=\(pairOfCurrency)", method: .get).responseJSON { (responseData) -> Void in
                guard let resultValue = responseData.result.value else { return }
                guard let exchangeRate = (JSON(resultValue))["result"].double, (JSON(resultValue))["statusCode"].int == API_STATUS_CODE_SUCCESS_DING else {return}
                
                cachedexchangeRate[pairOfCurrency] = exchangeRate
                complete(true, exchangeRate)
            }
        }
            //valid cached exchange rate
        else {
            complete(true, cachedexchangeRate[pairOfCurrency] ?? 0)
        }
    }
    
    
    //Add empty object(Not selected coins)
    static func addEmptyCoin(arrSelectedCoins: [String]) -> [InfoCoin] {
        var arrResult = [InfoCoin]()
        
        for coinName in Coin.allValues {
            if(!arrSelectedCoins.contains(coinName)) {
                let infoCoin = InfoCoin(coin: Coin.valueOf(name: coinName), currentPrice: 0.0)
                arrResult.append(infoCoin)
            }
        }
        
        return arrResult
    }
}
