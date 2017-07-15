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
    static var updatePer = UserDefaults.standard.string(forKey: Const.UserDefaultKey.UPDATE_PER) ?? Const.DEFAULT_UPDATE_PER.stirng {
        didSet {
            UserDefaults.standard.set(updatePer, forKey: Const.UserDefaultKey.UPDATE_PER)
            UserDefaults.standard.synchronize()
            
            (NSApplication.shared().delegate as! AppDelegate).setTimerSec(updatePer: updatePer)
            debugPrint("updatePer >> didSet \(updatePer)")
        }
    }
    
    static var myCoin: Coin = Coin.valueOf(name: UserDefaults.standard.string(forKey: Const.UserDefaultKey.MY_COIN) ?? Const.DEFAULT_MY_COIN) {
        didSet {
            UserDefaults.standard.set(myCoin.rawValue, forKey: Const.UserDefaultKey.MY_COIN)
            UserDefaults.standard.synchronize()
            
            (NSApplication.shared().delegate as! AppDelegate).updateStatusLabel(willShowLoadingText: false)
            debugPrint("myCoin >> didSet \(myCoin.rawValue)")
        }
    }
    
    static var mySite: Site = Site.valueOf(name: UserDefaults.standard.string(forKey: Const.UserDefaultKey.MY_SITE) ?? Const.DEFAULT_MY_SITE) {
        didSet {
            UserDefaults.standard.set(mySite.rawValue, forKey: Const.UserDefaultKey.MY_SITE)
            UserDefaults.standard.synchronize()
            
            (NSApplication.shared().delegate as! AppDelegate).updateStatusLabel(willShowLoadingText: false)
            debugPrint("mySite >> didSet \(mySite.rawValue)")
        }
    }
    
    static var myBaseCurrency: BaseCurrency = BaseCurrency.valueOf(name: UserDefaults.standard.string(forKey: Const.UserDefaultKey.MY_BASE_CURRENCY) ?? Const.DEFAULT_MY_BASE_CURRENCY) {
        didSet {
            UserDefaults.standard.set(myBaseCurrency.rawValue, forKey: Const.UserDefaultKey.MY_BASE_CURRENCY)
            UserDefaults.standard.synchronize()
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "VCPopover.updateCoinState"), object: nil)

            (NSApplication.shared().delegate as! AppDelegate).updateStatusLabel(willShowLoadingText: false)
            debugPrint("myBaseCurrency >> didSet \(myBaseCurrency.rawValue)")
        }
    }
    
    static var arrSelectedCoin: [String] = UserDefaults.standard.stringArray(forKey: Const.UserDefaultKey.SELECTED_COINS) ?? Coin.allValues {
        didSet {
            UserDefaults.standard.set(arrSelectedCoin, forKey: Const.UserDefaultKey.SELECTED_COINS)
            UserDefaults.standard.synchronize()
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "VCPopover.updateCoinState"), object: nil)
            
            debugPrint("arrSelectedCoin >> didSet \(arrSelectedCoin)")
        }
    }
    
    static var arrSelectedSite: [String] = UserDefaults.standard.stringArray(forKey: Const.UserDefaultKey.SELECTED_SITES) ?? Site.allValues {
        didSet {
            UserDefaults.standard.set(arrSelectedSite, forKey: Const.UserDefaultKey.SELECTED_SITES)
            UserDefaults.standard.synchronize()
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "VCPopover.updateCoinState"), object: nil)
            
            debugPrint("arrSelectedSite >> didSet \(arrSelectedSite)")
        }
    }
    
    static var isSimpleMode: Bool = UserDefaults.standard.bool(forKey: Const.UserDefaultKey.IS_SIMPLE_MODE) {
        didSet {
            UserDefaults.standard.set(isSimpleMode, forKey: Const.UserDefaultKey.IS_SIMPLE_MODE)
            UserDefaults.standard.synchronize()
            
            debugPrint("arrSelectedSite >> didSet \(arrSelectedSite)")
        }
    }
}
