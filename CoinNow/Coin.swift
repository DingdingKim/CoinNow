//
//  Coin.swift
//  CoinNow
//
//  Created by DingMac on 2017. 7. 13..
//  Copyright © 2017년 DingdingKim. All rights reserved.
//

import Foundation
import Cocoa
import SwiftyJSON

struct Coin: Codable {
    var marketAndCode: String = "" // KRW-BTC
    var name: String = "" // bitcoin
    var code: String = "" // btc
    var market: String = "" // krw
    var site: SiteType // upbit
    var uniqueId: String = "" // marketAndCode + site
    
    var isChecked: Bool {
        get {
            return MyValue.selectedCoins.filter { $0.marketAndCode == self.marketAndCode && $0.site.rawValue == self.site.rawValue }.count > 0
        }
    }
    
    init(from site: SiteType, data: JSON) {
        self.site = site
        
        switch site {
        case .upbit:
            self.marketAndCode = data["market"].stringValue
            self.name = data["english_name"].stringValue
            self.market = String(data["market"].stringValue.split(separator: "-")[0])
            self.code = String(data["market"].stringValue.split(separator: "-")[1])
            self.uniqueId = "\(self.marketAndCode)/\(self.site.rawValue)"
            
        default:
            print("nothing")
        }
    }
}
