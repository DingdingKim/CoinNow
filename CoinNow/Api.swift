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
    
    static func getCoinsStateBithum(arrSelectedCoins: [String], complete:@escaping (_ isSuccess: Bool, _ arrResult: [InfoCoin]) -> Void){
        
        //After get exchange rate then get price and exchange the price to base currency
        Api.getExchangeRate(from: .krw, complete: {isSuccess, exchangeRate in
            if(isSuccess){
                
                print("환율가져온거 Bithum : \(exchangeRate)")
                Alamofire.request("https://api.bithumb.com/public/ticker/ALL", method: .get).responseJSON { (responseData) -> Void in
                    if((responseData.result.value) != nil) {
                        let swiftyJsonVar = JSON(responseData.result.value!)
                        
                        let status_code = swiftyJsonVar["status"].stringValue
                        
                        var arrResult = addEmptyCoin(arrSelectedCoins: arrSelectedCoins)
                        
                        if(status_code == API_STATUS_CODE_SUCCESS_BITHUMB){
                            
                            for coinName in arrSelectedCoins {
                                let dataCurrency = swiftyJsonVar["data"][coinName]
                                let currentPrice = dataCurrency["closing_price"].stringValue
                                let exchangedPrice = (Double(currentPrice) ?? 0.0) * exchangeRate
                                
                                //debugPrint("getCoinsStateBithum >> \(currentPrice) / \(exchangeRate) : \(exchangedPrice)")
                                
                                let infoCoin = InfoCoin(coin: Coin.valueOf(name: coinName), currentPrice: exchangedPrice)
                                
                                arrResult.append(infoCoin)
                            }
                            complete(true, arrResult)
                        }
                        else{
                            complete(false, arrResult)
                        }
                    }
                }
            }
        })
    }
    
    static func getCoinsStateCoinone(arrSelectedCoins: [String], complete:@escaping (_ isSuccess: Bool, _ arrResult: [InfoCoin]) -> Void){
        
        //After get exchange rate then get price and exchange the price to base currency
        Api.getExchangeRate(from: .krw, complete: {isSuccess, exchangeRate in
            if(isSuccess){
                print("환율가져온거 Coinone : \(exchangeRate)")
                
                Alamofire.request("https://api.coinone.co.kr/ticker/?currency=all", method: .get).responseJSON { (responseData) -> Void in
                    if((responseData.result.value) != nil) {
                        let swiftyJsonVar = JSON(responseData.result.value!)
                        
                        let status_code = swiftyJsonVar["errorCode"].stringValue
                        
                        var arrResult = addEmptyCoin(arrSelectedCoins: arrSelectedCoins)
                        
                        if(status_code == API_STATUS_CODE_SUCCESS_COINONE){
                            
                            for coinName in arrSelectedCoins {
                                if(swiftyJsonVar[coinName.lowercased()].exists()) {
                                    let dataCurrency = swiftyJsonVar[coinName.lowercased()]
                                    let currentPrice = dataCurrency["last"].stringValue
                                    let exchangedPrice = (Double(currentPrice) ?? 0.0) * exchangeRate
                                    
                                    //debugPrint("getCoinsStateCoinone >> \(currentPrice) / \(exchangeRate) : \(exchangedPrice)")
                                    
                                    let infoCoin = InfoCoin(coin: Coin.valueOf(name: coinName), currentPrice: exchangedPrice)
                                    arrResult.append(infoCoin)
                                }
                                else {
                                    //Add empty object
                                    let infoCoin = InfoCoin(coin: Coin.valueOf(name: coinName), currentPrice: 0.0)
                                    arrResult.append(infoCoin)
                                }
                            }
                            complete(true, arrResult)
                        }
                        else{
                            complete(false, arrResult)
                        }
                    }
                }
            }
        })
    }
    
    static func getCoinsStatePoloniex(arrSelectedCoins: [String], complete:@escaping (_ isSuccess: Bool, _ arrResult: [InfoCoin]) -> Void){
        
        //After get exchange rate then get price and exchange the price to base currency
        Api.getExchangeRate(from: .usd, complete: {isSuccess, exchangeRate in
            if(isSuccess){
                print("환율가져온거 Poloniex : \(exchangeRate)")
                
                Alamofire.request("https://poloniex.com/public?command=returnTicker", method: .get).responseJSON { (responseData) -> Void in
                    if((responseData.result.value) != nil) {
                        let swiftyJsonVar = JSON(responseData.result.value!)
                        
                        var arrResult = addEmptyCoin(arrSelectedCoins: arrSelectedCoins)
                        
                        for coinName in arrSelectedCoins {
                            let dataCurrency = swiftyJsonVar["USDT_\(coinName)"]
                            let currentPrice = dataCurrency["last"].stringValue
                            let exchangedPrice = (Double(currentPrice) ?? 0.0) * (exchangeRate)// * Const.USDT_RATE
                            
                            //debugPrint("getCoinsStatePoloniex >> \(currentPrice) / \(exchangeRate) : \(exchangedPrice)")
                            
                            let infoCoin = InfoCoin(coin: Coin.valueOf(name: coinName), currentPrice: exchangedPrice)
                            
                            arrResult.append(infoCoin)
                        }
                        complete(true, arrResult)
                    }
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
        
        //After get exchange rate then get price and exchange the price to base currency
        Api.getExchangeRate(from: .cny, complete: {isSuccess, exchangeRate in
            if(isSuccess){
                print("환율가져온거 Okcoin : \(exchangeRate)")
                
                //Add empty coins that not tradable in this site.
                var arrResult = addEmptyCoin(arrSelectedCoins: arrSelectedCoins)
                
                for coinName in arrSelectedCoins {
                    
                    //Okcoin offers only BTC, ETH, LTC
                    if(Site.okcoin.arrTradableCoin().contains(coinName)) {
                        
                        Alamofire.request("https://www.okcoin.cn/api/v1/ticker.do?symbol=\(coinName)_cny", method: .get).responseJSON { (responseData) -> Void in
                            if((responseData.result.value) != nil) {
                                let swiftyJsonVar = JSON(responseData.result.value!)
                                
                                let dataCurrency = swiftyJsonVar["ticker"]
                                let currentPrice = dataCurrency["last"].stringValue
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
                    else{
                        let infoCoin = InfoCoin(coin: Coin.valueOf(name: coinName), currentPrice: 0.0)
                        arrResult.append(infoCoin)
                    }
                }
            }
        })
    }
    
    static func getCoinsStateHuobiByCryptowatch(arrSelectedCoins: [String], complete:@escaping (_ isSuccess: Bool, _ arrResult: [InfoCoin]) -> Void){
        
        //After get exchange rate then get price and exchange the price to base currency
        Api.getExchangeRate(from: .cny, complete: {isSuccess, exchangeRate in
            if(isSuccess){
                //Add empty coins that not tradable in this site.
                var arrResult = addEmptyCoin(arrSelectedCoins: arrSelectedCoins)
                
                for coinName in arrSelectedCoins {
                    
                    //Okcoin offers only BTC, ETH, LTC, ETC
                    if(Site.okcoin.arrTradableCoin().contains(coinName)) {
                        Alamofire.request("https://api.cryptowat.ch/markets/huobi/\(coinName)cny/price", method: .get).responseJSON { (responseData) -> Void in
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
                    else{
                        let infoCoin = InfoCoin(coin: Coin.valueOf(name: coinName), currentPrice: 0.0)
                        arrResult.append(infoCoin)
                    }
                }
            }
        })
    }
    
    //From yahoo api
    static func getExchangeRate(from: BaseCurrency, complete:@escaping (_ isSuccess: Bool, _ result: Double) -> Void){
        Alamofire.request("http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.xchange%20where%20pair%3D%22\(from.rawValue + MyValue.myBaseCurrency.rawValue)%22&format=json&diagnostics=true&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys", method: .get).responseJSON { (responseData) -> Void in
            guard let resultValue = responseData.result.value else { return }
            let swiftyJsonVar = JSON(resultValue)
            guard let rate = Double(swiftyJsonVar["query"]["results"]["rate"]["Rate"].stringValue) else { return }
            complete(true, rate)
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
