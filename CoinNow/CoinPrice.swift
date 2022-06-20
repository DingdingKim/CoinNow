//
//  CoinPrice.swift
//  CoinNow
//
//  Created by DingMac on 2017. 9. 1..
//  Copyright © 2017년 DingdingKim. All rights reserved.
//

import Foundation

enum CoinPrice: Double{
    //fail : When server does not receive a value
    //noValue : When there is no value to display. This is not fail. (Conin that can not be traded on the market.)
    case fail = -1.0, noValue = 0.0
    
    func text() -> String {
        switch self {
        case .fail:
            return "Fail"
        case .noValue:
            return "-"
        }
    }
}
