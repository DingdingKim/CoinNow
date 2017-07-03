//
//  VCPopover.swift
//  DDCurrentCoinState
//
//  Created by DingMac on 2017. 6. 25..
//  Copyright © 2017년 DingdingKim. All rights reserved.
//

import Cocoa

class VCPopover: NSViewController {
    @IBOutlet weak var cbBtc: NSButton!
    @IBOutlet weak var cbEth: NSButton!
    @IBOutlet weak var cbDash: NSButton!
    @IBOutlet weak var cbLtc: NSButton!
    @IBOutlet weak var cbEtc: NSButton!
    @IBOutlet weak var cbXrp: NSButton!
    
    @IBOutlet weak var lbUpdateTime: NSTextField!
    
    @IBOutlet weak var btPopupUpdatePer: NSPopUpButton!
    @IBOutlet weak var btPopupMyCoin: NSPopUpButton!
    
    @IBOutlet var lbBtcBithumb: NSTextField!
    @IBOutlet var lbEthBithumb: NSTextField!
    @IBOutlet var lbDashBithumb: NSTextField!
    @IBOutlet var lbLtcBithumb: NSTextField!
    @IBOutlet var lbEtcBithumb: NSTextField!
    @IBOutlet var lbXrpBithumb: NSTextField!
    
    @IBOutlet var lbBtcPoloniex: NSTextField!
    @IBOutlet var lbEthPoloniex: NSTextField!
    @IBOutlet var lbDashPoloniex: NSTextField!
    @IBOutlet var lbLtcPoloniex: NSTextField!
    @IBOutlet var lbEtcPoloniex: NSTextField!
    @IBOutlet var lbXrpPoloniex: NSTextField!
    
    @IBOutlet var lbBtcTitle: NSTextField!
    @IBOutlet var lbEthTitle: NSTextField!
    @IBOutlet var lbDashTitle: NSTextField!
    @IBOutlet var lbLtcTitle: NSTextField!
    @IBOutlet var lbEtcTitle: NSTextField!
    @IBOutlet var lbXrpTitle: NSTextField!
    
    var arrCb = [NSButton]()
    var arrlbTitle = [NSTextField]()
    var arrlbBithumb = [NSTextField]()
    var arrlbPoloniex = [NSTextField]()
    var arrlbCoinone = [NSTextField]()
    
    var arrSelectedCoins = [String]()
    
    //Dollar -> KRW
    var exchangeRate:Double = 0.0
    
    override func viewDidLoad() {
        arrCb = [cbBtc, cbEth, cbDash, cbLtc, cbEtc, cbXrp]
        arrCb = [cbBtc, cbEth, cbDash, cbLtc, cbEtc, cbXrp]
        arrlbTitle = [lbBtcTitle, lbEthTitle, lbDashTitle, lbLtcTitle, lbEtcTitle, lbXrpTitle]
        arrlbBithumb = [lbBtcBithumb, lbEthBithumb, lbDashBithumb, lbLtcBithumb, lbEtcBithumb, lbXrpBithumb]
        arrlbPoloniex = [lbBtcPoloniex, lbEthPoloniex, lbDashPoloniex, lbLtcPoloniex, lbEtcPoloniex, lbXrpPoloniex]
        
        setPopupButtons()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        updateState()
    }
    
    func setPopupButtons() {
        btPopupUpdatePer.addItems(withTitles: Const.arrUpdatePerString)
        btPopupMyCoin.addItems(withTitles: Const.arrCoinName)
        
        let updatePer = UserDefaults.standard.string(forKey: Const.UserDefaultKey.UPDATE_PER) ?? "1min"
        let myCoin = UserDefaults.standard.string(forKey: Const.UserDefaultKey.MY_COIN) ?? "BTC"
        
        btPopupUpdatePer.selectItem(at: Const.arrUpdatePerString.index(of: updatePer) ?? 0)
        btPopupMyCoin.selectItem(at: Const.arrCoinName.index(of: myCoin) ?? 0)
    }
    
    //Update coins sate in popover view
    func updateState() {
        lbUpdateTime.stringValue = "Loading..."
        
        for lb in arrlbBithumb {
            lb.stringValue = "Loading..."
        }
        
        for lb in arrlbPoloniex {
            lb.stringValue = "Loading..."
        }
        
        for cb in arrCb {
            if(cb.state == NSOnState){
                arrSelectedCoins.append(Const.arrCoinName[cb.tag])
                
                arrlbBithumb[cb.tag].isHidden = false
                arrlbPoloniex[cb.tag].isHidden = false
                arrlbTitle[cb.tag].isHidden = false
            }
            else {
                arrlbBithumb[cb.tag].isHidden = true
                arrlbPoloniex[cb.tag].isHidden = true
                arrlbTitle[cb.tag].isHidden = true
            }
        }
        
        self.getBithumb()
        
        self.getExchangeRateAndPoloniex()
    }
    
    func getBithumb(){
        Api.getCoinsState_Bithum(arrSelectedCoins: arrSelectedCoins, complete: {isSuccess, arrResult in
            if(isSuccess){
                for infoCoin in arrResult {
                    
                    for index in 0...Const.arrCoinName.count-1 {
                        if(infoCoin.coinName! == Const.arrCoinName[index]) {
                            self.arrlbBithumb[index].stringValue = infoCoin.current_price!.withCommas()
                        }
                        
                        //update my coin state in status bar
                        if(infoCoin.coinName! == (UserDefaults.standard.string(forKey: Const.UserDefaultKey.MY_COIN) ?? "BTC")) {
                            (NSApplication.shared().delegate as! AppDelegate).setStatusLabelTitle(title: "\(infoCoin.coinName!) \(Double(infoCoin.current_price!).withCommas())")
                        }
                    }
                }
                self.lbUpdateTime.stringValue = Date().todayString(format: "yyyy.MM.dd HH:mm:ss")
            }
            else{
                self.lbUpdateTime.stringValue = Date().todayString(format: "yyyy.MM.dd HH:mm:ss") + "last update is failed"
            }
        })
    }
    
    func getPoloniex() {
        Api.getCoinsState_Poliniex(arrSelectedCoins: arrSelectedCoins, complete: {isSuccess, arrResult in
            for infoCoin in arrResult {
                
                for index in 0...Const.arrCoinName.count-1 {
                    if(infoCoin.coinName! == Const.arrCoinName[index]) {
                        self.arrlbPoloniex[index].stringValue = Int(self.exchangeRate * infoCoin.current_price!).withCommas()
                    }
                }
            }
        })
    }
    
    //get exchange rate(Dollar to KRW) -> get poloniex data -> USDT * exchange rate
    func getExchangeRateAndPoloniex() {
        Api.getExchangeRate(complete: {isSuccess, result in
            if(isSuccess) {
                self.exchangeRate = result

                self.getPoloniex()
            }
            else {
                self.exchangeRate = 0
            }
        })
    }
    
    //change coin(will update) check state
    @IBAction func changeCheckState(_ sender: NSButton) {
        
        if(sender.state == NSOnState) {
            arrlbBithumb[sender.tag].isHidden = false
            arrlbPoloniex[sender.tag].isHidden = false
            arrlbTitle[sender.tag].isHidden = false
            
            if(arrlbBithumb[sender.tag].stringValue == "Loading...") {
                updateState()
            }
        }
        else {
            arrlbBithumb[sender.tag].isHidden = true
            arrlbPoloniex[sender.tag].isHidden = true
            arrlbTitle[sender.tag].isHidden = true
        }
    }
    
    //Change my coin
    @IBAction func changeMyCoin(_ sender: NSPopUpButton) {
        UserDefaults.standard.set(Const.arrCoinName[sender.indexOfSelectedItem], forKey: Const.UserDefaultKey.MY_COIN)
        UserDefaults.standard.synchronize()
        
        (NSApplication.shared().delegate as! AppDelegate).updateStatusLabel(willShowLoadingText: false)
    }
    
    //Change Update per time
    @IBAction func changUpdatePer(_ sender: NSPopUpButton) {
        UserDefaults.standard.set(Const.arrUpdatePerString[sender.indexOfSelectedItem], forKey: Const.UserDefaultKey.UPDATE_PER)
        UserDefaults.standard.synchronize()
        
        (NSApplication.shared().delegate as! AppDelegate).setTimerSec()
    }
    
    //Refresh data
    @IBAction func clickRefresh(_ sender: NSButton) {
        updateState()
    }
    
    //Terminate App
    @IBAction func clickQuit(_ sender: NSButton) {
        AppDelegate.timer.invalidate()
        NSApp.terminate(self)
    }
}
