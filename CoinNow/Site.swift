//
//  Site.swift
//  CoinNow
//
//  Created by DingMac on 2017. 7. 13..
//  Copyright © 2017년 DingdingKim. All rights reserved.
//

import Foundation

enum SiteType: String, Codable, CaseIterable {
    case upbit = "Upbit", binance = "Binance"
}

class Site {
    var siteType: SiteType = .upbit
    var coins: [Coin] = []
    var marketAndCoins: [(market: String, coins: [Coin])] = []
    
    init(siteType: SiteType) {
        self.siteType = siteType
        
        setData() {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "VCPopover.finishSetCoins"), object: nil)
        }
    }
    
    func setData( complete: @escaping () -> Void){
        switch siteType {
        case .upbit:
            Api.getUpbitCoins(complete: {isSuccess, result in
                self.coins.removeAll()
                self.coins.append(contentsOf: result.sorted(by: { $0.market > $1.market }))
                
                //마켓을 강제로 넣어주는게 나을것같다
                let markets: [String] = ["KRW", "BTC", "USDT"]
                //let markets: [String] = Array(Set(result.map { $0.market }.sorted(by: { $0.first! > $1.first! })))
                
                for market in markets {
                    self.marketAndCoins.append((market: market, coins: result.filter { $0.market == market }))
                }
                
                if self.siteType == Const.DEFAULT_SITE_TYPE {
                    //아무것도 없는 경우 업빗에서 가져온거에서 앞에 3개를 넣어준다
                    if MyValue.selectedCoins.count == 0 {
                        MyValue.selectedCoins.append(contentsOf: self.marketAndCoins[0].coins.sorted(by: { $0.market > $1.market })[0...3])
                    }
                }
                
                complete()
            })
            
        case .binance:
            self.marketAndCoins = []
        }
    }
}
