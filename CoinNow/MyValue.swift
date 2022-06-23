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
            
            (NSApplication.shared.delegate as! AppDelegate).setTimerSec(updatePer: updatePer)
            //debugPrint("updatePer >> didSet \(updatePer)")
        }
    }
    
    //상태바 거래소
    static var mySiteType : SiteType = SiteType(rawValue: UserDefaults.standard.string(forKey: Const.UserDefaultKey.MY_SITE) ?? Const.DEFAULT_MY_SITE) ?? .upbit {
        didSet {
            UserDefaults.standard.set(mySiteType.rawValue, forKey: Const.UserDefaultKey.MY_SITE)
            UserDefaults.standard.synchronize()
            
            (NSApplication.shared.delegate as! AppDelegate).updateStatusLabel(willShowLoadingText: false)
            //debugPrint("mySiteType >> didSet \(mySiteType.rawValue)")
        }
    }
    
    //상태바 코인
    static var myCoin: String = UserDefaults.standard.string(forKey: Const.UserDefaultKey.MY_COIN) ?? Const.DEFAULT_MY_COIN {
        didSet {
            UserDefaults.standard.set(myCoin, forKey: Const.UserDefaultKey.MY_COIN)
            UserDefaults.standard.synchronize()

            (NSApplication.shared.delegate as! AppDelegate).updateStatusLabel(willShowLoadingText: false)
            debugPrint("myCoin >> didSet \(String(describing: myCoin))")
        }
    }
    
    //선택된 코인들
    static var selectedCoins: [Coin] = (try? PropertyListDecoder().decode([Coin].self, from: UserDefaults.standard.data(forKey: Const.UserDefaultKey.SELECTED_COINS) ?? Data())) ?? [Coin]() {
        didSet {
            if let data = try? PropertyListEncoder().encode(selectedCoins) {
                UserDefaults.standard.set(data, forKey: Const.UserDefaultKey.SELECTED_COINS)
                UserDefaults.standard.synchronize()
            }
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "VCPopover.updateSelectedCoins"), object: nil)
            
            //debugPrint("selectedCoins >> didSet \(selectedCoins)")
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
    static var isShowStatusbarIcon: Bool = UserDefaults.standard.bool(forKey: Const.UserDefaultKey.IS_SHOW_ICON) {
        didSet {
            UserDefaults.standard.set(isShowStatusbarIcon, forKey: Const.UserDefaultKey.IS_SHOW_ICON)
            UserDefaults.standard.synchronize()
        }
    }
    
    //다 지우기
    static func clear() {
        UserDefaults.standard.removeObject(forKey: Const.UserDefaultKey.IS_SHOW_ICON)
        UserDefaults.standard.removeObject(forKey: Const.UserDefaultKey.IS_SIMPLE_MODE)
        UserDefaults.standard.removeObject(forKey: Const.UserDefaultKey.MY_MARKET)
        UserDefaults.standard.removeObject(forKey: Const.UserDefaultKey.MY_COIN)
        UserDefaults.standard.removeObject(forKey: Const.UserDefaultKey.MY_MARKET)
        UserDefaults.standard.removeObject(forKey: Const.UserDefaultKey.SELECTED_COINS)
        UserDefaults.standard.removeObject(forKey: Const.UserDefaultKey.SELECTED_SITES)
        UserDefaults.standard.removeObject(forKey: Const.UserDefaultKey.UPDATE_PER)
        UserDefaults.standard.synchronize()
    }
}
