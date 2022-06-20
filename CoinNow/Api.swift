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
    
    //Bithumb ["BTC", "ETH", "DASH", "LTC", "ETC", "XRP", "BCH", "XMR", "ZEC", "BTG"]
    static func getCoinsStateBithumb(arrSelectedCoins: [String], complete: @escaping (_ isSuccess: Bool, _ arrResult: [InfoCoin]) -> Void){
        
        //After get exchange rate then get price and exchange the price to base currency
        Api.getExchangeRate(from: .krw, complete: {isSuccess, exchangeRate in
            guard isSuccess else { complete(false, makeResultArrayOfFail()); return }
            
            //Add empty coins that not selected and not tradable in this site.
            var arrResult = addEmptyCoin(arrSelectedCoins: arrSelectedCoins, arrTradableCoins: Site.bithumb.arrTradableCoin())
            
            Alamofire.request("https://api.bithumb.com/public/ticker/ALL", method: .get).responseJSON { (responseData) -> Void in
                guard let resultValue = responseData.result.value else { complete(false, makeResultArrayOfFail()); return }
                let resultValuseJson = (JSON(resultValue))
                
                guard resultValuseJson["status"].stringValue == API_STATUS_CODE_SUCCESS_BITHUMB else { complete(false, makeResultArrayOfFail()); return }
                
                for coinName in arrSelectedCoins {
                    //Add only tradable coins
                    guard Site.bithumb.arrTradableCoin().contains(coinName) else { complete(false, makeResultArrayOfFail()); continue}
                    
                    guard let currentPrice = resultValuseJson["data"][coinName]["closing_price"].string else { complete(false, makeResultArrayOfFail()); continue }
                    let exchangedPrice = (Double(currentPrice) ?? CoinPrice.fail.rawValue) * exchangeRate
                    
                    let infoCoin = InfoCoin(coin: Coin.valueOf(name: coinName), currentPrice: exchangedPrice)
                    arrResult.append(infoCoin)
                }
                complete(true, arrResult)
            }
        })
    }
    
    //Coinone ["BTC", "ETH", "ETC", "XRP", "BCH", "QTUM", "IOTA"]
    static func getCoinsStateCoinone(arrSelectedCoins: [String], complete: @escaping (_ isSuccess: Bool, _ arrResult: [InfoCoin]) -> Void){
        
        Api.getExchangeRate(from: .krw, complete: {isSuccess, exchangeRate in
            guard isSuccess else { complete(false, makeResultArrayOfFail()); return }
            
            var arrResult = addEmptyCoin(arrSelectedCoins: arrSelectedCoins, arrTradableCoins: Site.coinone.arrTradableCoin())
            
            Alamofire.request("https://api.coinone.co.kr/ticker/?currency=all", method: .get).responseJSON { (responseData) -> Void in
                guard let resultValue = responseData.result.value else { complete(false, makeResultArrayOfFail()); return }
                let resultValuseJson = (JSON(resultValue))
                
                guard resultValuseJson["errorCode"].stringValue == API_STATUS_CODE_SUCCESS_COINONE else { complete(false, makeResultArrayOfFail()); return }
                
                for coinName in arrSelectedCoins {
                    guard Site.coinone.arrTradableCoin().contains(coinName) else { complete(false, makeResultArrayOfFail()); continue}
                    
                    guard let currentPrice = resultValuseJson[coinName.lowercased()]["last"].string else { complete(false, makeResultArrayOfFail()); continue}
                    let exchangedPrice = (Double(currentPrice) ?? CoinPrice.fail.rawValue) * exchangeRate
                    
                    let infoCoin = InfoCoin(coin: Coin.valueOf(name: coinName), currentPrice: exchangedPrice)
                    arrResult.append(infoCoin)
                }
                complete(true, arrResult)
            }
        })
    }
    
    //Poloniex ["BTC", "ETH", "DASH", "LTC", "ETC", "XRP", "BCH", "XMR"]
    static func getCoinsStatePoloniex(arrSelectedCoins: [String], complete: @escaping (_ isSuccess: Bool, _ arrResult: [InfoCoin]) -> Void) {
        
        Api.getExchangeRate(from: .usd, complete: {isSuccess, exchangeRate in
            guard isSuccess else { complete(false, makeResultArrayOfFail()); return }
            
            var arrResult = addEmptyCoin(arrSelectedCoins: arrSelectedCoins, arrTradableCoins: Site.poloniex.arrTradableCoin())
            
            Alamofire.request("https://poloniex.com/public?command=returnTicker", method: .get).responseJSON { (responseData) -> Void in
                guard let resultValue = responseData.result.value else { complete(false, makeResultArrayOfFail()); return}
                let resultValuseJson = (JSON(resultValue))
                
                for coinName in arrSelectedCoins {
                    guard Site.poloniex.arrTradableCoin().contains(coinName) else { complete(false, makeResultArrayOfFail()); continue}
                    
                    guard let currentPrice = resultValuseJson["USDT_\(coinName)"]["last"].string else { complete(false, makeResultArrayOfFail()); continue}
                    let exchangedPrice = (Double(currentPrice) ?? CoinPrice.fail.rawValue) * (exchangeRate)// * Const.USDT_RATE
                   
                    let infoCoin = InfoCoin(coin: Coin.valueOf(name: coinName), currentPrice: exchangedPrice)
                    arrResult.append(infoCoin)
                }
                complete(true, arrResult)
            }
        })
    }
    
    /*
    //OkCoin ["BTC", "ETH", "LTC"]
    static func getCoinsStateOkcoin(arrSelectedCoins: [String], complete: @escaping (_ isSuccess: Bool, _ arrResult: [InfoCoin]) -> Void){
        
        Api.getExchangeRate(from: .cny, complete: {isSuccess, exchangeRate in
            guard isSuccess else { complete(false, makeResultArrayOfFail()); return }
            
            var arrResult = addEmptyCoin(arrSelectedCoins: arrSelectedCoins, arrTradableCoins: Site.okcoin.arrTradableCoin())
            
            for coinName in arrSelectedCoins {
                guard Site.okcoin.arrTradableCoin().contains(coinName) else { complete(false, makeResultArrayOfFail()); continue}
                
                Alamofire.request("https://www.okcoin.cn/api/v1/ticker.do?symbol=\(coinName)_cny", method: .get).responseJSON { (responseData) -> Void in
                    guard let resultValue = responseData.result.value else { complete(false, makeResultArrayOfFail()); return}
                    
                    guard let currentPrice = (JSON(resultValue))["ticker"]["last"].string else { complete(false, makeResultArrayOfFail()); return}
                    let exchangedPrice = (Double(currentPrice) ?? CoinPrice.fail.rawValue) * exchangeRate
                    
                    let infoCoin = InfoCoin(coin: Coin.valueOf(name: coinName), currentPrice: exchangedPrice)
                    arrResult.append(infoCoin)
                    
                    //callback when finish last item request
                    if(arrResult.count == Coin.allValues.count) {
                        //After all request is finished
                        complete(true, arrResult)
                    }
                }
            }
        })
    }
    
    //Huobi ["BTC", "LTC"]
    static func getCoinsStateHuobiByCryptowatch(arrSelectedCoins: [String], complete: @escaping (_ isSuccess: Bool, _ arrResult: [InfoCoin]) -> Void){
        
        Api.getExchangeRate(from: .cny, complete: {isSuccess, exchangeRate in
            guard isSuccess else { complete(false, makeResultArrayOfFail()); return }
            
            var arrResult = addEmptyCoin(arrSelectedCoins: arrSelectedCoins, arrTradableCoins: Site.huobi.arrTradableCoin())
            
            for coinName in arrSelectedCoins {
                guard Site.huobi.arrTradableCoin().contains(coinName) else { complete(false, makeResultArrayOfFail()); continue}
                
                Alamofire.request("https://api.cryptowat.ch/markets/huobi/\(coinName)cny/price", method: .get).responseJSON { (responseData) -> Void in
                    guard let resultValue = responseData.result.value else { complete(false, makeResultArrayOfFail()); return}
                    
                    guard let currentPrice = (JSON(resultValue))["result"]["price"].double else { complete(false, makeResultArrayOfFail()); return}
                    let exchangedPrice = currentPrice * exchangeRate
                    
                    let infoCoin = InfoCoin(coin: Coin.valueOf(name: coinName), currentPrice: exchangedPrice)
                    arrResult.append(infoCoin)
                    
                    //callback when finish last item request
                    if(arrResult.count == Coin.allValues.count) {
                        //After all request is finished
                        complete(true, arrResult)
                    }
                }
            }
        })
    }
     */
    
    //Bitfinex ["BTC", "ETH", "DASH", "LTC", "ETC", "XRP", "BCH", "XMR"]
    static func getCoinsStateBitfinex(arrSelectedCoins: [String], complete: @escaping (_ isSuccess: Bool, _ arrResult: [InfoCoin]) -> Void){
        
        Api.getExchangeRate(from: .usd, complete: {isSuccess, exchangeRate in
            guard isSuccess else { complete(false, makeResultArrayOfFail()); return }
            
            var arrResult = addEmptyCoin(arrSelectedCoins: arrSelectedCoins, arrTradableCoins: Site.bitfinex.arrTradableCoin())
            
            for coinName in arrSelectedCoins {
                guard Site.bitfinex.arrTradableCoin().contains(coinName) else { complete(false, makeResultArrayOfFail()); continue}

                var realCoinName = coinName
                
                //DASH -> dsh
                if(coinName == "DASH") {
                    realCoinName = "dsh"
                }
                //QTUM -> QTM
                else if(coinName == "QTUM") {
                    realCoinName = "QTM"
                }
                //IOTA -> IOT
                else if(coinName == "IOTA") {
                    realCoinName = "IOT"
                }
                
                Alamofire.request("https://api.bitfinex.com/v1/pubticker/\(realCoinName)USD", method: .get).responseJSON { (responseData) -> Void in
                    guard let resultValue = responseData.result.value else { complete(false, makeResultArrayOfFail()); return}
                    
                    guard let currentPrice = (JSON(resultValue))["last_price"].string else { complete(false, makeResultArrayOfFail()); return}
                    let exchangedPrice = (Double(currentPrice) ?? CoinPrice.fail.rawValue) * exchangeRate
                    
                    let infoCoin = InfoCoin(coin: Coin.valueOf(name: coinName), currentPrice: exchangedPrice)
                    arrResult.append(infoCoin)
                    
                    //callback when finish last item request
                    if(arrResult.count == Coin.allValues.count) {
                        //After all request is finished
                        complete(true, arrResult)
                    }
                }
            }
        })
    }
    
    //Bittrex ["BTC", "ETH", "DASH", "LTC", "ETC", "XRP", "BCH", "XMR"]
    static func getCoinsStateBittrex(arrSelectedCoins: [String], complete: @escaping (_ isSuccess: Bool, _ arrResult: [InfoCoin]) -> Void){
        
        Api.getExchangeRate(from: .usd, complete: {isSuccess, exchangeRate in
            guard isSuccess else { complete(false, makeResultArrayOfFail()); return }
            
            var arrResult = addEmptyCoin(arrSelectedCoins: arrSelectedCoins, arrTradableCoins: Site.bittrex.arrTradableCoin())
            
            for coinName in arrSelectedCoins {
                guard Site.bittrex.arrTradableCoin().contains(coinName) else { complete(false, makeResultArrayOfFail()); continue}
                
                Alamofire.request("https://bittrex.com/api/v1.1/public/getticker?market=USDT-\(coinName == "BCH" ? "BCC" : coinName)", method: .get).responseJSON { (responseData) -> Void in
                    guard let resultValue = responseData.result.value else { complete(false, makeResultArrayOfFail()); return}

                    guard let currentPrice = (JSON(resultValue))["result"]["Last"].double else { complete(false, makeResultArrayOfFail()); return}
                    let exchangedPrice = (currentPrice ) * exchangeRate
                    
                    let infoCoin = InfoCoin(coin: Coin.valueOf(name: coinName), currentPrice: exchangedPrice)
                    arrResult.append(infoCoin)
                    
                    //callback when finish last item request
                    if(arrResult.count == Coin.allValues.count) {
                        //After all request is finished
                        complete(true, arrResult)
                    }
                }
            }
        })
    }
    
    //Upbit 다이쪄
    static func getCoinsStateUpbit(arrSelectedCoins: [String], complete: @escaping (_ isSuccess: Bool, _ arrResult: [InfoCoin]) -> Void){
        
        Api.getExchangeRate(from: .krw, complete: {isSuccess, exchangeRate in
            guard isSuccess else { complete(false, makeResultArrayOfFail()); return }
            var arrResult = addEmptyCoin(arrSelectedCoins: arrSelectedCoins, arrTradableCoins: Site.upbit.arrTradableCoin())

            for coinName in arrSelectedCoins {
                guard Site.upbit.arrTradableCoin().contains(coinName) else { complete(false, makeResultArrayOfFail()); continue}
                
                Alamofire.request("https://crix-api-endpoint.upbit.com/v1/crix/trades/ticks?code=CRIX.UPBIT.KRW-\(coinName == "BCH" ? "BCC" : coinName)&count=1", method: .get).responseJSON { (responseData) -> Void in
                    guard let resultValue = responseData.result.value else { complete(false, makeResultArrayOfFail()); return}
                    guard let jsonArrayTick = (JSON(resultValue)).array else { complete(false, makeResultArrayOfFail()); return}
                    guard let currentPrice = jsonArrayTick[0]["tradePrice"].double else { complete(false, makeResultArrayOfFail()); return}
                    let exchangedPrice = (currentPrice ) * exchangeRate
                    
                    let infoCoin = InfoCoin(coin: Coin.valueOf(name: coinName), currentPrice: exchangedPrice)
                    arrResult.append(infoCoin)
                    
                    //callback when finish last item request
                    if(arrResult.count == Coin.allValues.count) {
                        //After all request is finished
                        complete(true, arrResult)
                    }
                }
            }
        })
    }
    
    //From Dingding server api
    //Caching update time
    static var lastUpdateTimeOfExchangeRate: [String:Date] = ["KRWUSD": Date(), "KRWCNY": Date(), "USDKRW": Date(), "USDCNY": Date(), "CNYUSD": Date(), "CNYKRW": Date()]
    static var cachedexchangeRate: [String:Double] = ["KRWUSD": 0, "KRWCNY": 0, "USDKRW": 0, "USDCNY": 0, "CNYUSD": 0, "CNYKRW": 0]
    
    static func getExchangeRate(from: BaseCurrency, complete: @escaping (_ isSuccess: Bool, _ result: Double) -> Void){
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
                guard let exchangeRate = (JSON(resultValue))["result"].double, (JSON(resultValue))["statusCode"].int == API_STATUS_CODE_SUCCESS_DING else { return }
                
                cachedexchangeRate[pairOfCurrency] = exchangeRate
                complete(true, exchangeRate)
            }
        }
        //valid cached exchange rate
        else {
            complete(true, cachedexchangeRate[pairOfCurrency] ?? 0)
        }
    }
    
    //Add empty object(Not selected coins and Not tradable coins in that site)
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
