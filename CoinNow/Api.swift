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
    //1st : yahoo, 2nd : my server
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
            
            //1st : yahoo
            let urlYahoo = "http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.xchange%20where%20pair%20in%20(%22\(pairOfCurrency)%22)&format=json&env=store://datatables.org/alltableswithkeys&callback="
            Alamofire.request(urlYahoo, method: .get).responseJSON { (responseData) -> Void in
                if let resultValue = responseData.result.value {
                    let swiftyJsonVar = JSON(resultValue)
                    if let rate = swiftyJsonVar["query"]["results"]["rate"]["Rate"].string {
                        cachedexchangeRate[pairOfCurrency] = Double(rate) ?? 0
                        complete(true, Double(rate) ?? 0)
                    }
                    else {
                        //2nd : my server
                        Alamofire.request("http://coinnow.herokuapp.com/coinnow/api/getExchangeRate?pair=\(pairOfCurrency)", method: .get).responseJSON { (responseData) -> Void in
                            if((responseData.result.value) != nil) {
                                let swiftyJsonVar = JSON(responseData.result.value!)
                                
                                let exchangeRate = Double(swiftyJsonVar["result"].stringValue) ?? 0
                                cachedexchangeRate[pairOfCurrency] = exchangeRate
                                
                                complete(true, exchangeRate)
                            }
                        }
                    }
                }
            }
        }
        //valid cached exchange rate
        else {
            complete(true, cachedexchangeRate[pairOfCurrency] ?? 0)
        }
    }
    
    //Get alert message from Dingding to user
    //😱😱😱😱😱😱😱😱😱😱😱😱😱😱😱😱😱😱😱😱I will refactoring this codes .... I was so hasty right now.
    static func getDingAlertMessage(complete:@escaping (_ isSuccess: Bool, _ result: String) -> Void) {
        Alamofire.request("http://coinnow.herokuapp.com/coinnow/api/getDingAlertMessage?language=\(NSLocale.preferredLanguages[0])", method: .get).responseJSON { (responseData) -> Void in
            if((responseData.result.value) != nil) {
                let swiftyJsonVar = JSON(responseData.result.value!)
                let statusCode = swiftyJsonVar["statusCode"].intValue
                
                if(statusCode == API_STATUS_CODE_SUCCESS_DING){
                    let message = swiftyJsonVar["result"].stringValue
                    
                    if(message == ""){
                        complete(false, message)
                    }
                    else {
                        complete(true, message)
                    }
                }
                else {
                    complete(false, "")
                }
            }
            else {
                complete(false, "")
            }
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
