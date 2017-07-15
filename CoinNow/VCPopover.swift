//
//  VCPopover.swift
//  DDCurrentCoinState
//
//  Created by DingMac on 2017. 6. 25..
//  Copyright © 2017년 DingdingKim. All rights reserved.
//

import Cocoa

class VCPopover: NSViewController {
    @IBOutlet weak var btStatusUpdatePer: NSPopUpButton!
    @IBOutlet weak var btStatusCoin: NSPopUpButton!
    @IBOutlet weak var btStatusSite: NSPopUpButton!
    
    @IBOutlet weak var lbLine: NSTextField!
    
    @IBOutlet weak var btBaseCurrency: NSPopUpButton!
    @IBOutlet weak var lbUpdateTime: NSTextField!
    @IBOutlet weak var btRefresh: NSButton!
    
    @IBOutlet weak var cbBtc: NSButton!
    @IBOutlet weak var cbEth: NSButton!
    @IBOutlet weak var cbDash: NSButton!
    @IBOutlet weak var cbLtc: NSButton!
    @IBOutlet weak var cbEtc: NSButton!
    @IBOutlet weak var cbXrp: NSButton!
    
    @IBOutlet weak var cbBithumb: NSButton!
    @IBOutlet weak var cbCoinone: NSButton!
    @IBOutlet weak var cbPoloniex: NSButton!
    @IBOutlet weak var cbOkcoin: NSButton!
    
    @IBOutlet var lbBtcTitle: NSTextField!
    @IBOutlet var lbEthTitle: NSTextField!
    @IBOutlet var lbDashTitle: NSTextField!
    @IBOutlet var lbLtcTitle: NSTextField!
    @IBOutlet var lbEtcTitle: NSTextField!
    @IBOutlet var lbXrpTitle: NSTextField!
    
    @IBOutlet weak var stackViewSites: NSStackView!
    @IBOutlet weak var stackViewCoinName: NSStackView!
    
    var arrCbCoin = [NSButton]()
    var arrCbSite = [NSButton]()
    
    var arrlbCoinTitle = [NSTextField]()
    
    var arrSiteView = [ModelSite]()
    
    override func viewDidLoad() {
        arrCbCoin = [cbBtc, cbEth, cbDash, cbLtc, cbEtc, cbXrp]
        arrCbSite = [cbBithumb, cbCoinone, cbPoloniex, cbOkcoin]
        arrlbCoinTitle = [lbBtcTitle, lbEthTitle, lbDashTitle, lbLtcTitle, lbEtcTitle, lbXrpTitle]
        
        addSiteView()
        
        initView()
        
        //다른데서 뷰 업데이트가 필요할 경우
        NotificationCenter.default.addObserver(self, selector: #selector(VCPopover.updateCoinState), name: NSNotification.Name(rawValue: "VCPopover.updateCoinState"), object: nil)
        NSRunningApplication.current().activate(options: NSApplicationActivationOptions.activateIgnoringOtherApps)
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        updateCoinState()
        
        if self.view.acceptsFirstResponder {
            NSRunningApplication.current().activate(options: NSApplicationActivationOptions.activateIgnoringOtherApps)
            self.view.window?.makeFirstResponder(self.view)
        }
        
        if(UserDefaults.standard.string(forKey: "AppleInterfaceStyle") ?? "Light" == "Dark") {
            (NSApplication.shared().delegate as! AppDelegate).statusItem.image = NSImage(named: "icon_white")
            btRefresh.image = NSImage(named: "ic_autorenew_white")
            lbLine.backgroundColor = NSColor.white.withAlphaComponent(0.3)
        }
        else {
            (NSApplication.shared().delegate as! AppDelegate).statusItem.image = NSImage(named: "icon_black")
            btRefresh.image = NSImage(named: "ic_autorenew_black")
            lbLine.backgroundColor = NSColor.darkGray.withAlphaComponent(0.3)
        }
    }
    
    override func viewDidAppear() {
        NSRunningApplication.current().activate(options: NSApplicationActivationOptions.activateIgnoringOtherApps)
    }
    
    //Setup popup buttons
    func initView() {
        
        //Popup Button
        btStatusUpdatePer.addItems(withTitles: Array(Const.dicUpdatePerSec.keys))
        btStatusCoin.addItems(withTitles: Coin.allValues)
        btStatusSite.addItems(withTitles: Site.allValues)
        btBaseCurrency.addItems(withTitles: BaseCurrency.allValues)
        
        btStatusUpdatePer.selectItem(withTitle: MyValue.updatePer)
        btStatusCoin.selectItem(withTitle: MyValue.myCoin.rawValue)
        btStatusSite.selectItem(withTitle: MyValue.mySite.rawValue)
        btBaseCurrency.selectItem(withTitle: MyValue.myBaseCurrency.rawValue)
        
        //Check Button
        for cb in arrCbCoin {
            cb.state = MyValue.arrSelectedCoin.contains(cb.title) ? NSOnState : NSOffState
            
            //Hide not selected coin view
            if(!MyValue.arrSelectedCoin.contains(cb.title)) {
                arrlbCoinTitle[cb.tag].isHidden = true
                
                for index in 0...arrSiteView.count-1 {
                    arrSiteView[index].setVisibilityLabel(position: cb.tag, isHidden: true)
                }
            }
        }
        for cb in arrCbSite {
            cb.state = MyValue.arrSelectedSite.contains(cb.title) ? NSOnState : NSOffState
            
            //Hide not selected site view
            if(!MyValue.arrSelectedSite.contains(cb.title)) {
                stackViewSites.subviews[cb.tag].isHidden = true
            }
        }
    }
    
    //Add exchange site view
    func addSiteView() {
        for siteName in Site.allValues {
            let view = ModelSite(frame: NSRect(x: 0, y: 0, width: 0, height: 0), title: siteName)
            self.stackViewSites.addArrangedSubview(view.view)
            
            arrSiteView.append(view)
            
            //Hide not selected site view
            if(!MyValue.arrSelectedSite.contains(siteName)) {
                view.isHidden = true
            }
        }
        
        arrSiteView[0].hideSeparator()
    }
    
    //Update coins sate in popover view
    func updateCoinState() {
        lbUpdateTime.stringValue = Const.DEFAULT_LOADING_TEXT
        
        //Set all label to Loading..
        for view in arrSiteView {
            view.setLoadingState()
        }
        
        //Update only selected site
        for cb in arrCbSite {
            if(cb.state == NSOnState) {
                getCoinStateFromApi(indexOfSite: arrCbSite.index(of: cb)!)
            }
        }
    }
    
    func getCoinStateFromApi(indexOfSite: Int) {
        if(indexOfSite == 0){
            Api.getCoinsStateBithum(arrSelectedCoins: MyValue.arrSelectedCoin, complete: {isSuccess, arrResult in
                self.updateStateViewAfterGetDataFromApi(isSuccess: isSuccess, indexOfView: indexOfSite, arrData: arrResult)
            })
        }
        else if(indexOfSite == 1) {
            Api.getCoinsStateCoinone(arrSelectedCoins: MyValue.arrSelectedCoin, complete: {isSuccess, arrResult in
                self.updateStateViewAfterGetDataFromApi(isSuccess: isSuccess, indexOfView: indexOfSite, arrData: arrResult)
            })
        }
        else if(indexOfSite == 2) {
            Api.getCoinsStatePoloniex(arrSelectedCoins: MyValue.arrSelectedCoin, complete: {isSuccess, arrResult in
                self.updateStateViewAfterGetDataFromApi(isSuccess: isSuccess, indexOfView: indexOfSite, arrData: arrResult)
            })
        }
        else if(indexOfSite == 3) {
            Api.getCoinsStateOkcoin(arrSelectedCoins: MyValue.arrSelectedCoin, complete: {isSuccess, arrResult in
                self.updateStateViewAfterGetDataFromApi(isSuccess: isSuccess, indexOfView: indexOfSite, arrData: arrResult)
            })
        }
    }
    
    func updateStateViewAfterGetDataFromApi(isSuccess: Bool, indexOfView: Int, arrData: [InfoCoin]) {
        if(isSuccess){
            self.arrSiteView[indexOfView].updateCoinState(arrData: arrData)
            
            //Set update time
            self.lbUpdateTime.stringValue = Date().todayString(format: "yyyy.MM.dd HH:mm:ss")
        }
        else{
            //Set update fail time
            self.lbUpdateTime.stringValue = Date().todayString(format: "yyyy.MM.dd HH:mm:ss") + "last update is failed"
        }
    }
    
    //업데이트 시킬 코인 체크박스 변경
    //change coin(will update) check state
    @IBAction func changeCheckCoin(_ sender: NSButton) {
        let isChecked = sender.state == NSOnState
        
        //Hide coin name label
        arrlbCoinTitle[sender.tag].isHidden = !isChecked
        
        //Hide price label in model view
        for index in 0...arrSiteView.count-1 {
            arrSiteView[index].setVisibilityLabel(position: sender.tag, isHidden: !isChecked)
        }
        
        var arrSelected = [String]()
        for cb in arrCbCoin {
            if(cb.state == NSOnState){
                arrSelected.append(Coin.allValues[cb.tag])
            }
        }
        MyValue.arrSelectedCoin = arrSelected
    }
    
    //거래소 사이트 체크박스 변경
    //change site check state
    @IBAction func changeCheckSite(_ sender: NSButton) {
        let isChecked = sender.state == NSOnState
        
        stackViewSites.subviews[sender.tag].isHidden = !isChecked
        
        var arrSelected = [String]()
        for cb in arrCbSite {
            if(cb.state == NSOnState){
                arrSelected.append(Site.allValues[cb.tag])
            }
        }
        MyValue.arrSelectedSite = arrSelected
    }
    
    //Change Update per sec
    @IBAction func changeUpdatePer(_ sender: NSPopUpButton) {
        MyValue.updatePer = sender.titleOfSelectedItem ?? Const.DEFAULT_UPDATE_PER.stirng
    }
    
    //Change my coin
    @IBAction func changeMyCoin(_ sender: NSPopUpButton) {
        MyValue.myCoin = Coin.valueOf(name: sender.titleOfSelectedItem!)
    }
    
    //Change trading site
    @IBAction func changeMySite(_ sender: NSPopUpButton) {
        MyValue.mySite = Site.valueOf(name: sender.titleOfSelectedItem!)
        
        //거래소를 변경하면 해당 거래소에서 거래가능한 코인들만 넣어줘야한다
        btStatusCoin.removeAllItems()
        btStatusCoin.addItems(withTitles: Site.valueOf(name: sender.title).arrTradableCoin())
        
        
        //Current my coin is not tradable in changed site. So change my coin to first coin of tradable coins in my site.
        if(!Site.valueOf(name: sender.title).arrTradableCoin().contains(MyValue.myCoin.rawValue)) {
            btStatusCoin.selectItem(at: 0)
            
            MyValue.myCoin = Coin.valueOf(name: btStatusCoin.titleOfSelectedItem!)
        }
    }
    
    //Change Base Currency
    @IBAction func changeBaseCurrency(_ sender: NSPopUpButton) {
        MyValue.myBaseCurrency = BaseCurrency.valueOf(name: sender.titleOfSelectedItem!)
    }
    
    //Refresh data
    @IBAction func clickRefresh(_ sender: NSButton) {
        updateCoinState()
    }
    
    //Terminate App
    @IBAction func clickQuit(_ sender: NSButton) {
        (NSApplication.shared().delegate as! AppDelegate).terminateTimer()
        NSApp.terminate(self)
    }
}
