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
    static var updatePer: UpdatePer = UpdatePer(rawValue: UserDefaults.standard.string(forKey: Const.UserDefaultKey.UPDATE_PER) ?? Const.DEFAULT_UPDATE_PER.rawValue) ?? .realTime {
        didSet {
            UserDefaults.standard.set(updatePer.rawValue, forKey: Const.UserDefaultKey.UPDATE_PER)
            UserDefaults.standard.synchronize()
            debugPrint("updatePer >> didSet \(updatePer)")
            
            (NSApplication.shared.delegate as! AppDelegate).updateUpdatePer()
        }
    }
    
    //상태바 거래소
    static var mySiteType: SiteType = SiteType(rawValue: UserDefaults.standard.string(forKey: Const.UserDefaultKey.MY_SITE) ?? Const.DEFAULT_MY_SITE) ?? .upbit {
        didSet {
            UserDefaults.standard.set(mySiteType.rawValue, forKey: Const.UserDefaultKey.MY_SITE)
            UserDefaults.standard.synchronize()
            debugPrint("mySiteType >> didSet \(mySiteType.rawValue)")
            
            (NSApplication.shared.delegate as! AppDelegate).updateStatusItem()
        }
    }
    
    //상태바 코인
    static var myCoin: String = UserDefaults.standard.string(forKey: Const.UserDefaultKey.MY_COIN) ?? Const.DEFAULT_MY_COIN {
        didSet {
            UserDefaults.standard.set(myCoin, forKey: Const.UserDefaultKey.MY_COIN)
            UserDefaults.standard.synchronize()
            debugPrint("myCoin >> didSet \(String(describing: myCoin))")

            (NSApplication.shared.delegate as! AppDelegate).updateStatusItem()
        }
    }
    
    //선택된 코인들
    static var selectedCoins: [Coin] = (try? PropertyListDecoder().decode([Coin].self, from: UserDefaults.standard.data(forKey: Const.UserDefaultKey.SELECTED_COINS) ?? Data())) ?? [Coin]() {
        didSet {
            if let data = try? PropertyListEncoder().encode(selectedCoins) {
                UserDefaults.standard.set(data, forKey: Const.UserDefaultKey.SELECTED_COINS)
                UserDefaults.standard.synchronize()
                
                debugPrint("selectedCoins >> didSet \(selectedCoins)")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "VCPopover.updateSelectedCoins"), object: nil)
            }
            
            //소켓에 업데이트된 코인 선택 목록으로 다시 요청한다
            //(NSApplication.shared.delegate as! AppDelegate).writeToSocket()
        }
    }
    
    //미니모드 활성화 여부
    static var isSimpleMode: Bool = UserDefaults.standard.bool(forKey: Const.UserDefaultKey.IS_SIMPLE_MODE) {
        didSet {
            UserDefaults.standard.set(isSimpleMode, forKey: Const.UserDefaultKey.IS_SIMPLE_MODE)
            UserDefaults.standard.synchronize()
            
            debugPrint("isSimpleMode >> didSet \(String(describing: isSimpleMode))")
        }
    }
    
    //상태바에 번개 아이콘 표시 여부
    static var isHiddenStatusbarIcon: Bool = UserDefaults.standard.bool(forKey: Const.UserDefaultKey.IS_SHOW_ICON) {
        didSet {
            UserDefaults.standard.set(isHiddenStatusbarIcon, forKey: Const.UserDefaultKey.IS_SHOW_ICON)
            UserDefaults.standard.synchronize()
            
            debugPrint("isHiddenStatusbarIcon >> didSet \(String(describing: isHiddenStatusbarIcon))")
            
            (NSApplication.shared.delegate as! AppDelegate).updateStatusItem()
        }
    }
    
    //상태바에 마켓 코드 표시 여부
    static var isHiddenStatusbarMarket: Bool = UserDefaults.standard.bool(forKey: Const.UserDefaultKey.IS_SHOW_MARKET) {
        didSet {
            UserDefaults.standard.set(isHiddenStatusbarMarket, forKey: Const.UserDefaultKey.IS_SHOW_MARKET)
            UserDefaults.standard.synchronize()
            
            debugPrint("isHiddenStatusbarMarket >> didSet \(String(describing: isHiddenStatusbarMarket))")
            
            (NSApplication.shared.delegate as! AppDelegate).updateStatusItem()
        }
    }
    
    //다 지우기
    static func clear() {
        UserDefaults.standard.removeObject(forKey: Const.UserDefaultKey.IS_SIMPLE_MODE)
        UserDefaults.standard.removeObject(forKey: Const.UserDefaultKey.UPDATE_PER)
        UserDefaults.standard.removeObject(forKey: Const.UserDefaultKey.MY_SITE)
        UserDefaults.standard.removeObject(forKey: Const.UserDefaultKey.MY_COIN)
        UserDefaults.standard.removeObject(forKey: Const.UserDefaultKey.IS_SHOW_ICON)
        UserDefaults.standard.removeObject(forKey: Const.UserDefaultKey.IS_SHOW_MARKET)
        
        UserDefaults.standard.removeObject(forKey: Const.UserDefaultKey.SELECTED_COINS)
        
        UserDefaults.standard.synchronize()
    }
}
