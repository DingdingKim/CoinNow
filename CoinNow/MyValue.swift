//
//  MyValue.swift
//  CoinNow
//
//  Created by DingMac on 2017. 7. 13..
//  Copyright © 2017년 DingdingKim. All rights reserved.
//

import Foundation
import Cocoa

struct MyValue {
    //상태바에 업데이트 주기
    static var updatePer = UserDefaults.standard.string(forKey: Const.UserDefaultKey.UPDATE_PER) ?? Const.DEFAULT_UPDATE_PER.stirng {
        didSet {
            UserDefaults.standard.set(updatePer, forKey: Const.UserDefaultKey.UPDATE_PER)
            UserDefaults.standard.synchronize()
            
            (NSApplication.shared().delegate as! AppDelegate).setTimerSec(updatePer: updatePer)
            print("updatePer >> didSet 호출됨 >> \(updatePer)")
        }
    }
    
    //상태바에 내 코인
    static var myCoin: Coin = Coin.valueOf(name: UserDefaults.standard.string(forKey: Const.UserDefaultKey.MY_COIN) ?? Const.DEFAULT_MY_COIN) {
        didSet {
            UserDefaults.standard.set(myCoin.rawValue, forKey: Const.UserDefaultKey.MY_COIN)
            UserDefaults.standard.synchronize()
            
            (NSApplication.shared().delegate as! AppDelegate).updateStatusLabel(willShowLoadingText: false)
            print("myCoin >> didSet 호출됨 >> \(myCoin.rawValue)")
        }
    }
    //상태바에 내 사이트
    static var mySite: Site = Site.valueOf(name: UserDefaults.standard.string(forKey: Const.UserDefaultKey.MY_SITE) ?? Const.DEFAULT_MY_SITE) {
        didSet {
            UserDefaults.standard.set(mySite.rawValue, forKey: Const.UserDefaultKey.MY_SITE)
            UserDefaults.standard.synchronize()
            
            (NSApplication.shared().delegate as! AppDelegate).updateStatusLabel(willShowLoadingText: false)
            print("mySite >> didSet 호출됨 >> \(mySite.rawValue)")
        }
    }
    
    //내 기준가격
    static var myBaseCurrency: BaseCurrency = BaseCurrency.valueOf(name: UserDefaults.standard.string(forKey: Const.UserDefaultKey.MY_BASE_CURRENCY) ?? Const.DEFAULT_MY_BASE_CURRENCY) {
        didSet {
            UserDefaults.standard.set(myBaseCurrency.rawValue, forKey: Const.UserDefaultKey.MY_BASE_CURRENCY)
            UserDefaults.standard.synchronize()
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "VCPopover.updateCoinState"), object: nil)
            Const.exchangeRateLastUpdateTime = nil // For update new exchange rate

            (NSApplication.shared().delegate as! AppDelegate).updateStatusLabel(willShowLoadingText: false)
            print("myBaseCurrency >> didSet 호출됨 >> \(myBaseCurrency.rawValue)")
        }
    }
    
    //팝업에 선택되어있는 코인들(업데이트 할때 업데이트 시킬 코인들)
    static var arrSelectedCoin: [String] = UserDefaults.standard.stringArray(forKey: Const.UserDefaultKey.SELECTED_COINS) ?? Coin.allValues {
        didSet {
            UserDefaults.standard.set(arrSelectedCoin, forKey: Const.UserDefaultKey.SELECTED_COINS)
            UserDefaults.standard.synchronize()
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "VCPopover.updateCoinState"), object: nil)
            
            print("arrSelectedCoin >> didSet 호출됨 : \(arrSelectedCoin)")
        }
    }
    
    //팝업에 선택되어있는 사이트들(업데이트 할때 업데이트 시킬 사이트들)
    static var arrSelectedSite: [String] = UserDefaults.standard.stringArray(forKey: Const.UserDefaultKey.SELECTED_SITES) ?? Site.allValues {
        didSet {
            UserDefaults.standard.set(arrSelectedSite, forKey: Const.UserDefaultKey.SELECTED_SITES)
            UserDefaults.standard.synchronize()
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "VCPopover.updateCoinState"), object: nil)
            
            print("arrSelectedSite >> didSet 호출됨 \(arrSelectedSite)")
        }
    }
}
