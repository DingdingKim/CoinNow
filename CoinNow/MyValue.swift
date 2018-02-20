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
    //상태바 코인 업데이트 주기
    static var updatePer = UserDefaults.standard.string(forKey: Const.UserDefaultKey.UPDATE_PER) ?? Const.DEFAULT_UPDATE_PER.stirng {
        didSet {
            UserDefaults.standard.set(updatePer, forKey: Const.UserDefaultKey.UPDATE_PER)
            UserDefaults.standard.synchronize()
            
            (NSApplication.shared().delegate as! AppDelegate).setTimerSec(updatePer: updatePer)
            //debugPrint("updatePer >> didSet \(updatePer)")
        }
    }
    
    //상태바 코인
    static var myCoin: Coin = Coin.valueOf(name: UserDefaults.standard.string(forKey: Const.UserDefaultKey.MY_COIN) ?? Const.DEFAULT_MY_COIN) {
        didSet {
            UserDefaults.standard.set(myCoin.rawValue, forKey: Const.UserDefaultKey.MY_COIN)
            UserDefaults.standard.synchronize()
            
            (NSApplication.shared().delegate as! AppDelegate).updateStatusLabel(willShowLoadingText: false)
            //debugPrint("myCoin >> didSet \(myCoin.rawValue)")
        }
    }
    
    //상태바 코인의 사이트
    static var mySite: Site = Site.valueOf(name: UserDefaults.standard.string(forKey: Const.UserDefaultKey.MY_SITE) ?? Const.DEFAULT_MY_SITE) {
        didSet {
            UserDefaults.standard.set(mySite.rawValue, forKey: Const.UserDefaultKey.MY_SITE)
            UserDefaults.standard.synchronize()
            
            (NSApplication.shared().delegate as! AppDelegate).updateStatusLabel(willShowLoadingText: false)
            //debugPrint("mySite >> didSet \(mySite.rawValue)")
        }
    }
    
    //기준 통화
    static var myBaseCurrency: BaseCurrency = BaseCurrency.valueOf(name: UserDefaults.standard.string(forKey: Const.UserDefaultKey.MY_BASE_CURRENCY) ?? Const.DEFAULT_MY_BASE_CURRENCY) {
        didSet {
            UserDefaults.standard.set(myBaseCurrency.rawValue, forKey: Const.UserDefaultKey.MY_BASE_CURRENCY)
            UserDefaults.standard.synchronize()
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "VCPopover.updateCoinState"), object: nil)

            (NSApplication.shared().delegate as! AppDelegate).updateStatusLabel(willShowLoadingText: false)
            //debugPrint("myBaseCurrency >> didSet \(myBaseCurrency.rawValue)")
        }
    }
    
    //선택된 코인들
    static var arrSelectedCoin: [String] = UserDefaults.standard.stringArray(forKey: Const.UserDefaultKey.SELECTED_COINS) ?? Coin.defaultSelectedValues {
        didSet {
            UserDefaults.standard.set(arrSelectedCoin, forKey: Const.UserDefaultKey.SELECTED_COINS)
            UserDefaults.standard.synchronize()
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "VCPopover.updateCoinState"), object: nil)
            
            //debugPrint("arrSelectedCoin >> didSet \(arrSelectedCoin)")
        }
    }
    
    //선택된 사이트들
    static var arrSelectedSite: [String] = UserDefaults.standard.stringArray(forKey: Const.UserDefaultKey.SELECTED_SITES) ?? Site.defaultSelectedValues {
        didSet {
            UserDefaults.standard.set(arrSelectedSite, forKey: Const.UserDefaultKey.SELECTED_SITES)
            UserDefaults.standard.synchronize()
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "VCPopover.updateCoinState"), object: nil)
            
            //debugPrint("arrSelectedSite >> didSet \(arrSelectedSite)")
        }
    }
    
    //미니모드 활성화 여부
    static var isSimpleMode: Bool = UserDefaults.standard.bool(forKey: Const.UserDefaultKey.IS_SIMPLE_MODE) {
        didSet {
            UserDefaults.standard.set(isSimpleMode, forKey: Const.UserDefaultKey.IS_SIMPLE_MODE)
            UserDefaults.standard.synchronize()
        }
    }
    
    //상태바에 번개 아이콘 표시 여부
    static var isShowStatusbarIcon: Bool = UserDefaults.standard.bool(forKey: Const.UserDefaultKey.IS_SHOW_ICON) ?? false {
        didSet {
            UserDefaults.standard.set(isShowStatusbarIcon, forKey: Const.UserDefaultKey.IS_SHOW_ICON)
            UserDefaults.standard.synchronize()
        }
    }
    
    //다 지우기
    static func clear() {
        UserDefaults.standard.removeObject(forKey: Const.UserDefaultKey.IS_SHOW_ICON)
        UserDefaults.standard.removeObject(forKey: Const.UserDefaultKey.IS_SIMPLE_MODE)
        UserDefaults.standard.removeObject(forKey: Const.UserDefaultKey.MY_BASE_CURRENCY)
        UserDefaults.standard.removeObject(forKey: Const.UserDefaultKey.MY_COIN)
        UserDefaults.standard.removeObject(forKey: Const.UserDefaultKey.MY_SITE)
        UserDefaults.standard.removeObject(forKey: Const.UserDefaultKey.SELECTED_COINS)
        UserDefaults.standard.removeObject(forKey: Const.UserDefaultKey.SELECTED_SITES)
        UserDefaults.standard.removeObject(forKey: Const.UserDefaultKey.UPDATE_PER)
        UserDefaults.standard.synchronize()
        
    }
}
