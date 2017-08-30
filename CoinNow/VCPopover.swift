//
//  VCPopover.swift
//  DDCurrentCoinState
//
//  Created by DingMac on 2017. 6. 25..
//  Copyright © 2017년 DingdingKim. All rights reserved.
//

import Cocoa

class VCPopover: NSViewController {
    @IBOutlet weak var stackViewRoot: NSStackView!
    
    @IBOutlet weak var btMinimode: NSButton!
    @IBOutlet weak var viewStatusSetting: NSView!
    @IBOutlet weak var viewStateTable: NSView!
    
    @IBOutlet weak var btStatusUpdatePer: NSPopUpButton!
    @IBOutlet weak var btStatusCoin: NSPopUpButton!
    @IBOutlet weak var btStatusSite: NSPopUpButton!
    
    @IBOutlet weak var lbLine: NSTextField!
    
    @IBOutlet weak var lbBaseCurrency: NSTextField!
    @IBOutlet weak var btBaseCurrency: NSPopUpButton!
    @IBOutlet weak var lbUpdateTime: NSTextField!
    @IBOutlet weak var btRefresh: NSButton!
    
    @IBOutlet weak var stackViewCoinCheck: NSStackView!
    @IBOutlet weak var stackViewSiteCheck: NSStackView!
    
    @IBOutlet weak var cbBtc: NSButton!
    @IBOutlet weak var cbEth: NSButton!
    @IBOutlet weak var cbDash: NSButton!
    @IBOutlet weak var cbLtc: NSButton!
    @IBOutlet weak var cbEtc: NSButton!
    @IBOutlet weak var cbXrp: NSButton!
    @IBOutlet weak var cbBch: NSButton!
    
    @IBOutlet weak var cbBithumb: NSButton!
    @IBOutlet weak var cbCoinone: NSButton!
    @IBOutlet weak var cbPoloniex: NSButton!
    @IBOutlet weak var cbOkcoin: NSButton!
    @IBOutlet weak var cbHuobi: NSButton!
    
    @IBOutlet var lbBtcTitle: NSTextField!
    @IBOutlet var lbEthTitle: NSTextField!
    @IBOutlet var lbDashTitle: NSTextField!
    @IBOutlet var lbLtcTitle: NSTextField!
    @IBOutlet var lbEtcTitle: NSTextField!
    @IBOutlet var lbXrpTitle: NSTextField!
    @IBOutlet var lbBchTitle: NSTextField!
    
    @IBOutlet weak var stackViewSites: NSStackView!
    @IBOutlet weak var stackViewCoinName: NSStackView!
    
    @IBOutlet weak var btDonate: NSButton!
    @IBOutlet weak var viewDonateToggle: NSView!
    @IBOutlet weak var viewDonate: NSView!
    @IBOutlet weak var lbDingAlert: NSTextField!//alert message from Dingding to user
    
    var arrCbCoin = [NSButton]()
    var arrCbSite = [NSButton]()
    
    var arrlbCoinTitle = [NSTextField]()
    
    var arrSiteView = [ModelSite]()
    
    var countUpdatedSite: Int = 0
    
    override func viewDidLoad() {
        arrCbCoin = [cbBtc, cbEth, cbDash, cbLtc, cbEtc, cbXrp, cbBch]
        arrCbSite = [cbBithumb, cbCoinone, cbPoloniex, cbOkcoin, cbHuobi]
        arrlbCoinTitle = [lbBtcTitle, lbEthTitle, lbDashTitle, lbLtcTitle, lbEtcTitle, lbXrpTitle, lbBchTitle]
        
        addSiteView()
        
        initView()
        
        //Need to update in outside
        NotificationCenter.default.addObserver(self, selector: #selector(VCPopover.updateCoinState), name: NSNotification.Name(rawValue: "VCPopover.updateCoinState"), object: nil)
        NSRunningApplication.current().activate(options: NSApplicationActivationOptions.activateIgnoringOtherApps)
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        updateCoinState()
        
        if(self.isDarkMode()) {
            (NSApplication.shared().delegate as! AppDelegate).statusItem.image = NSImage(named: "icon_white")
            btDonate.image = NSImage.init(named: "ic_expand_more_white")
            btRefresh.image = NSImage(named: "ic_autorenew_white")
            lbLine.backgroundColor = NSColor.white.withAlphaComponent(0.3)
            btMinimode.image = NSImage.init(named: "ic_fullscreen_white")
            btMinimode.image = NSImage.init(named: self.isDarkMode() ? "ic_fullscreen_exit_white" : "ic_fullscreen_exit_black")
        }
        else {
            (NSApplication.shared().delegate as! AppDelegate).statusItem.image = NSImage(named: "icon_black")
            btDonate.image = NSImage.init(named: "ic_expand_more_black")
            btRefresh.image = NSImage(named: "ic_autorenew_black")
            lbLine.backgroundColor = NSColor.darkGray.withAlphaComponent(0.3)
            btMinimode.image = NSImage.init(named: "ic_fullscreen_black")
        }
        NSRunningApplication.current().activate(options: NSApplicationActivationOptions.activateIgnoringOtherApps)

        //From Secret Api !
        getDingdingAlertMessage()
        isShowDonateLayout()
    }
    
    //Setup popup buttons
    func initView() {
        viewDonateToggle.isHidden = true
        viewDonate.isHidden = true
        
        lbDingAlert.isHidden = true
        
        //For animation..
        btRefresh.wantsLayer = true
        
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
        
        //Calculate count of selected site
        for cb in arrCbSite {
            if(cb.state == NSOnState) {
                countUpdatedSite += 1
            }
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
        else if(indexOfSite == 4) {
            Api.getCoinsStateHuobiByCryptowatch(arrSelectedCoins: MyValue.arrSelectedCoin, complete: {isSuccess, arrResult in
                self.updateStateViewAfterGetDataFromApi(isSuccess: isSuccess, indexOfView: indexOfSite, arrData: arrResult)
            })
        }
    }
    
    func updateStateViewAfterGetDataFromApi(isSuccess: Bool, indexOfView: Int, arrData: [InfoCoin]) {
        if(isSuccess){
            self.arrSiteView[indexOfView].updateCoinState(arrData: arrData)
            
            //Set update time
            //self.lbUpdateTime.stringValue = Date().todayString(format: "yyyy.MM.dd HH:mm:ss")
        }
        else{
            //Set update fail time
            //self.lbUpdateTime.stringValue = Date().todayString(format: "yyyy.MM.dd HH:mm:ss") + "last update is failed"
        }
        countUpdatedSite -= 1
        
        if(countUpdatedSite <= 0){
            //toggleRefreshButtonAnimation(isRotate: false)
            lbUpdateTime.stringValue = Date().todayString(format: "yyyy.MM.dd HH:mm:ss")
            countUpdatedSite = 0
        }
    }
    
    //Alert message from Dingding(developer this app)
    func getDingdingAlertMessage() {
        SecretApi.getDingAlertMessage(complete: {isSuccess, message in
            if(isSuccess){
                self.lbDingAlert.isHidden = false
                self.lbDingAlert.stringValue = message
            }
            else {
                self.lbDingAlert.isHidden = true
            }
        })
    }
    
    //🤑🤑🤑😢😢😢
    func isShowDonateLayout() {
        SecretApi.isShowDonateLayout(complete: {isSuccess, result in
            guard let isWillShow = Bool(result), isSuccess else {self.toggleDonateView(false); return}
            self.toggleDonateView(isWillShow)
        })
    }
    
    func toggleDonateView(_ isShow: Bool) {
        if(isShow) {
            viewDonateToggle.isHidden = false
        }
        else {
            viewDonateToggle.isHidden = true
        }
    }
    
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
        
        //Update coin list for selected site
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
    
    @IBAction func clickMinimode(_ sender: Any) {
        MyValue.isSimpleMode = !MyValue.isSimpleMode

        if(MyValue.isSimpleMode) {
            viewStatusSetting.isHidden = true
            stackViewCoinCheck.isHidden = true
            stackViewSiteCheck.isHidden = true
            lbLine.isHidden = true
            lbBaseCurrency.isHidden = true
            btBaseCurrency.isHidden = true
            
            btMinimode.image = NSImage.init(named: self.isDarkMode() ? "ic_fullscreen_white" : "ic_fullscreen_black")
        }
        else {
            for view in stackViewRoot.arrangedSubviews {
                if(view != viewDonate && view != viewDonateToggle){
                    view.isHidden = false
                }
            }
            
            lbBaseCurrency.isHidden = false
            btBaseCurrency.isHidden = false
            
            btMinimode.image = NSImage.init(named: self.isDarkMode() ? "ic_fullscreen_exit_white" : "ic_fullscreen_exit_black")
        }
    }
    
    @IBAction func clickDonate(_ sender: NSButton) {
        //close
        if(sender.tag == 0){
            btDonate.image = NSImage.init(named: self.isDarkMode() ? "ic_expand_less_white" : "ic_expand_less_black")
            viewDonate.isHidden = false
            sender.tag = 1
        }
        else {
            btDonate.image = NSImage.init(named: self.isDarkMode() ? "ic_expand_more_white" : "ic_expand_more_black")
            viewDonate.isHidden = true
            sender.tag = 0
        }
    }
    
    //Click to copy donate address
    @IBAction func clickCopyDonateAddress(_ sender: NSButton) {
        let address = Coin.donateAddress(index: sender.tag)
        
        let pasteboard = NSPasteboard.general()
        pasteboard.declareTypes([NSPasteboardTypeString], owner: nil)
        pasteboard.setString(address, forType: NSPasteboardTypeString)
    }
    
    //Terminate App
    @IBAction func clickQuit(_ sender: NSButton) {
        (NSApplication.shared().delegate as! AppDelegate).terminateTimer()
        NSApp.terminate(self)
    }
    
    //Animate refresh icon. When update data
    func toggleRefreshButtonAnimation(isRotate: Bool) {
        if isRotate {
            let spinAnimation = CABasicAnimation()
            spinAnimation.fromValue = 0
            spinAnimation.toValue = Double.pi
            spinAnimation.duration = 2
            spinAnimation.repeatCount = Float.infinity
            spinAnimation.isRemovedOnCompletion = false
            //spinAnimation.fillMode = kCAFillModeForwards
            spinAnimation.timingFunction = CAMediaTimingFunction (name: kCAMediaTimingFunctionLinear)
            
            btRefresh.layer?.anchorPoint = CGPoint(x: btRefresh.bounds.width/2, y: btRefresh.bounds.height/2)
            btRefresh.layer?.add(spinAnimation, forKey: "transform.rotation.z")
        } else {
            btRefresh.layer?.removeAllAnimations()
        }
    }
}
