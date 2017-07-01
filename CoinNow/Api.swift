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
    static let API_STATUS_CODE_SUCCESS = "0000"
    
    static func getCoinsState_Bithum(arrSelectedCoins: [String], complete:@escaping (_ isSuccess: Bool, _ arrResult: [InfoCoin]) -> Void){
        
        Alamofire.request("https://api.bithumb.com/public/ticker/ALL", method: .get).responseJSON { (responseData) -> Void in
            if((responseData.result.value) != nil) {
                let swiftyJsonVar = JSON(responseData.result.value!)
                
                let status_code = swiftyJsonVar["status"].stringValue

                var arrResult = [InfoCoin]()

                if(status_code == API_STATUS_CODE_SUCCESS){
                    
                    for coinName in arrSelectedCoins {
                        let dataCurrency = swiftyJsonVar["data"][coinName]
//                        let opening_price = dataCurrency["opening_price"].stringValue //최근 24시간 내 시작 거래금액
                        let closing_price = dataCurrency["closing_price"].stringValue //최근 24시간 내 마지막 거래금액
//                        let min_price = dataCurrency["min_price"].stringValue //최근 24시간 내 최저 거래금액
//                        let max_price = dataCurrency["max_price"].stringValue //최근 24시간 내 최고 거래금액
//                        let average_price = dataCurrency["average_price"].stringValue //최근 24시간 내 평균 거래금액
//                        let units_traded = dataCurrency["units_traded"].stringValue //최근 24시간 내 Currency 거래량
//                        let volume_1day = dataCurrency["volume_1day"].stringValue //최근 1일간 Currency 거래량
//                        let volume_7day = dataCurrency["volume_7day"].stringValue //최근 7일간 Currency 거래량
//                        let buy_price = dataCurrency["buy_price"].stringValue //거래 대기건 최고 구매가
//                        let sell_price = dataCurrency["sell_price"].stringValue //거래 대기건 최소 판매가
                        
                        let date = swiftyJsonVar["data"]["date"].stringValue //현재 시간 Timestamp
                        
                        let infoCoin = InfoCoin(coinName: coinName, current_price: Double(closing_price) ?? 0, date: date)
                        
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
    
    static func getCoinsState_Poliniex(arrSelectedCoins: [String], complete:@escaping (_ isSuccess: Bool, _ arrResult: [InfoCoin]) -> Void){
        
        Alamofire.request("https://poloniex.com/public?command=returnTicker", method: .get).responseJSON { (responseData) -> Void in
            if((responseData.result.value) != nil) {
                let swiftyJsonVar = JSON(responseData.result.value!)
                
                var arrResult = [InfoCoin]()
                
                for coinName in arrSelectedCoins {
                    let dataCurrency = swiftyJsonVar["USDT_\(coinName)"]
                    
                    let current_price = dataCurrency["last"].stringValue //최근 24시간 내 마지막 거래금액
                    let date = Date().todayString(format: "yyyy.MM.dd HH:mm:ss")
                    
                    let infoCoin = InfoCoin(coinName: coinName, current_price: (Double(current_price) ?? 0.0), date: date)
                    
                    arrResult.append(infoCoin)
                }
                complete(true, arrResult)
            }
        }
    }
    
    static func getExchangeRate(complete:@escaping (_ isSuccess: Bool, _ result: Double) -> Void){
        
        Alamofire.request("http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.xchange%20where%20pair%3D%22USDKRW%22&format=json&diagnostics=true&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys", method: .get).responseJSON { (responseData) -> Void in
            if((responseData.result.value) != nil) {
                let swiftyJsonVar = JSON(responseData.result.value!)
                
                let rate = swiftyJsonVar["query"]["results"]["rate"]["Rate"].stringValue
                
                complete(true, Double(rate)!)
            }
        }
    }
}
