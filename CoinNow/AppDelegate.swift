//
//  AppDelegate.swift
//  CoinNow
//
//  Created by DingMac on 2017. 7. 2..
//  Copyright © 2017년 DingdingKim. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    public let statusItem = NSStatusBar.system().statusItem(withLength: -1)
    let popover = NSPopover()
    var eventMonitor: EventMonitor?
    
    public static var timer = Timer()
    
    //Set button at status bar(toggle popover)
    func setStatusButton() {
        if let button = statusItem.button {
            button.image = NSImage(named: "icon")
            button.action = #selector(AppDelegate.togglePopover(_:))
        }
        
        popover.contentViewController = VCPopover(nibName: "VCPopover", bundle: nil)
        
        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [unowned self] event in
            if self.popover.isShown {
                self.closePopover(event)
            }
        }
        eventMonitor?.start()
    }
    
    //Set label that show my coin state at status bar
    public func updateStatusLabel(willShowLoadingText: Bool) {
        if(willShowLoadingText) {
            self.statusItem.title = "Loading.."
        }
        
        Api.getCoinsState_Bithum(arrSelectedCoins: Const.arrCoinName, complete: {isSuccess, arrResult in
            
            for infoCoin in arrResult {
                if(infoCoin.coinName! == (UserDefaults.standard.string(forKey: Const.UserDefaultKey.MY_COIN) ?? "BTC")) {
                    self.setStatusLabelTitle(title: "\(infoCoin.coinName!) \(Double(infoCoin.current_price!).withCommas()) ")
                    break
                }
            }
            debugPrint("updateStatusLabel : \(Date().todayString(format: "yyyy.MM.dd HH:mm:ss"))")
        })
    }
    
    public func setStatusLabelTitle(title: String) {
        self.statusItem.title = title
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setStatusButton()
        
        updateStatusLabel(willShowLoadingText: true)
        
        setTimerSec()
    }
    
    //set timer sec that for update status bar title
    func setTimerSec() {
        AppDelegate.timer.invalidate()
        
        let repeatSecString = UserDefaults.standard.string(forKey: Const.UserDefaultKey.UPDATE_PER) ?? "1min"
        let repearSecInt: Double = Const.arrUpdatePerInt[Const.arrUpdatePerString.index(of: repeatSecString)!]
        
        AppDelegate.timer = Timer.scheduledTimer(timeInterval: repearSecInt, target: self, selector: #selector(updateStatusLabel), userInfo: nil, repeats: true)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        //terminate timer
        AppDelegate.timer.invalidate()
    }
    
    func togglePopover(_ sender: AnyObject?) {
        if popover.isShown {
            closePopover(sender)
        } else {
            showPopover(sender)
        }
    }
    
    func showPopover(_ sender: AnyObject?) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
        eventMonitor?.start()
    }
    
    func closePopover(_ sender: AnyObject?) {
        popover.performClose(sender)
        eventMonitor?.stop()
    }
}

