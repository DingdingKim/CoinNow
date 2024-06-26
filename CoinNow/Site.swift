//
//  Site.swift
//  CoinNow
//
//  Created by DingMac on 2017. 7. 13..
//  Copyright © 2017년 DingdingKim. All rights reserved.
//

import Foundation

enum SiteType: String, Codable, CaseIterable {
    case upbit = "Upbit", binance = "Binance", binanceF = "Binance(Future)"
    
    var markets: [String] {
        switch self {
        case .upbit:
            return ["KRW", "BTC", "USDT"]
            
        case .binance:
            return ["BTC", "USDT"]
            
        case .binanceF:
            return ["USDT"]
        }
    }
}

class Site {
    var siteType: SiteType = .upbit
    var coins: [Coin] = []
    var marketAndCoins: [(market: String, coins: [Coin])] = []
    
    func filteredTicks(searchText: String?) -> [(market: String, coins: [Coin])] {
        guard let searchText = searchText, !searchText.isEmpty else { return marketAndCoins }
        
        var filteredMarketAndCoins: [(market: String, coins: [Coin])] = []
        
        for marketAndCoin in marketAndCoins {
            var findCoins: [Coin] = []
            
            for coin in marketAndCoin.coins {
                if coin.code.lowercased().contains(searchText.lowercased()) || coin.name.lowercased().contains(searchText.lowercased()) {
                    findCoins.append(coin)
                }
            }
            
            if !findCoins.isEmpty {
                filteredMarketAndCoins.append((market: marketAndCoin.market, coins: findCoins))
            }
        }
        return filteredMarketAndCoins
    }
    
    init(siteType: SiteType) {
        self.siteType = siteType
        
        setData() {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "VCPopover.finishSetCoins"), object: nil, userInfo: ["site": self])
        }
    }
    
    //TODO Api호출을 여기서 하는게 맞는거냐....ㅠ
    func setData( complete: @escaping () -> Void){
        switch siteType {
        case .upbit:
            Api.getUpbitCoins(complete: {isSuccess, result in
                self.coins.removeAll()
                self.coins.append(contentsOf: result.sorted(by: { $0.code > $1.code }).sorted(by: { $0.market > $1.market }).sorted { coin,_ in coin.market == "KRW" })
                
                //마켓을 강제로 넣어주는게 나을것같다
                //let markets: [String] = Array(Set(result.map { $0.market }.sorted(by: { $0.first! > $1.first! })))
                
                for market in self.siteType.markets {
                    self.marketAndCoins.append((market: market, coins: result.filter { $0.market == market }))
                }
                
                complete()
            })
            
        case .binance:
            Api.getBinanceCoins(complete: {isSuccess, result in
                self.coins.removeAll()
                self.coins.append(contentsOf: result.sorted(by: { $0.code < $1.code }).sorted(by: { $0.market > $1.market }))
                
                //마켓을 강제로 넣어주는게 나을것같다. 특히나 바낸은 너무 많다
                //let markets: [String] = Array(Set(result.map { $0.market }.sorted(by: { $0.first! > $1.first! })))
                
                for market in self.siteType.markets {
                    self.marketAndCoins.append((market: market, coins: result.filter { $0.market == market }))
                }
                
                complete()
            })
            
        case .binanceF:
            Api.getBinanceFutureCoins(complete: {isSuccess, result in
                self.coins.removeAll()
                self.coins.append(contentsOf: result.sorted(by: { $0.code < $1.code }).sorted(by: { $0.market > $1.market }))
                
                for market in self.siteType.markets {
                    self.marketAndCoins.append((market: market, coins: result.filter { $0.market == market }))
                }
                
                complete()
            })
        }
    }
}
