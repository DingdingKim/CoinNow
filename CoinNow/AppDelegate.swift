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
    
    let statusItem = NSStatusBar.system.statusItem(withLength: -1)
    private let popover = NSPopover()
    
    private static var timer = Timer()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setStatusButton()
        
        updateStatusLabel(willShowLoadingText: true)
        
        setTimerSec(updatePer: MyValue.updatePer)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        //terminate timer
        terminateTimer()
    }
    
    //Set button at status bar(toggle popover)
    func setStatusButton() {
        popover.behavior = .transient//close popover when click outside
        
        //For os is dark mode
        if(MyValue.isShowStatusbarIcon) {
            if(UserDefaults.standard.string(forKey: "AppleInterfaceStyle") ?? "Light" == "Dark") {
                self.statusItem.image = NSImage(named: "icon_white")
            }
            else {
                self.statusItem.image = NSImage(named: "icon_black")
            }
        }
        else {
            self.statusItem.image = NSImage(named: "icon_none")
        }
        
        self.statusItem.button?.action = #selector(AppDelegate.togglePopover(_:))
        popover.contentViewController = VCPopover(nibName: "VCPopover", bundle: nil)
    }
    
    //Set label that show my coin state at status bar
    @objc public func updateStatusLabel(willShowLoadingText: Bool) {
        //print("Update Status Label : \(MyValue.mySite) / \(String(describing: MyValue.myCoin))")
        
        guard !MyValue.myCoin.isEmpty else { return }
        
        if MyValue.mySite == .upbit {
            Api.getMyCoinTick(marketAndCode: MyValue.myCoin, complete: { isSuccess, result in
                self.setStatusLabelTitle(title: "\(MyValue.myCoin.split(separator: "-")[1]) \(result ?? "-") ")
            })
        }
        //TODO 바낸 추가하기
    }
    
    public func setStatusLabelTitle(title: String) {
        self.statusItem.title = title
    }
    
    //set timer sec that for update status bar title
    func setTimerSec(updatePer: String) {
        terminateTimer()
        //debugPrint("setTimerSec : \(updatePer)")
        
        AppDelegate.timer = Timer.scheduledTimer(timeInterval: Const.dicUpdatePerSec[updatePer] ?? Const.DEFAULT_UPDATE_PER.double, target: self, selector: #selector(updateStatusLabel), userInfo: nil, repeats: true)
    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
        if popover.isShown {
            popover.performClose(sender)
        }
        else {
            if let button = statusItem.button {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            }
        }
    }
    
    func terminateTimer() {
        AppDelegate.timer.invalidate()
    }
}
