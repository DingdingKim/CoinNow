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
                self.coins.append(contentsOf: result)
                
                if self.siteType == Const.DEFAULT_SITE_TYPE {
                    //아무것도 없는 경우 업빗에서 가져온거에서 앞에 3개를 넣어준다
                    if MyValue.selectedCoins.count == 0 {
                        MyValue.selectedCoins.append(contentsOf: result[0...3])
                        print("더합니다")
                    }
                }
                
                complete()
            })
            
        case .binance:
            self.coins = [] //TODO
        }
    }
}
