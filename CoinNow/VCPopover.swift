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
    
    @IBOutlet weak var viewCoinCheck: NSView!
//    @IBOutlet weak var stackViewCoinCheck1: NSStackView!
//    @IBOutlet weak var stackViewCoinCheck2: NSStackView!
    @IBOutlet weak var stackViewSiteCheck: NSStackView!
    
    @IBOutlet weak var cbBtc: NSButton!
    @IBOutlet weak var cbEth: NSButton!
    @IBOutlet weak var cbDash: NSButton!
    @IBOutlet weak var cbLtc: NSButton!
    @IBOutlet weak var cbEtc: NSButton!
    @IBOutlet weak var cbXrp: NSButton!
    @IBOutlet weak var cbBch: NSButton!
    @IBOutlet weak var cbXmr: NSButton!
    @IBOutlet weak var cbQtum: NSButton!
    @IBOutlet weak var cbZec: NSButton!
    @IBOutlet weak var cbBtg: NSButton!
    @IBOutlet weak var cbIota: NSButton!
    @IBOutlet weak var cbEmc2: NSButton!
    
    @IBOutlet weak var cbEos: NSButton!
    @IBOutlet weak var cbAda: NSButton!
    @IBOutlet weak var cbSnt: NSButton!
    @IBOutlet weak var cbNeo: NSButton!
    @IBOutlet weak var cbXlm: NSButton!
    @IBOutlet weak var cbXem: NSButton!
    @IBOutlet weak var cbStrat: NSButton!
    @IBOutlet weak var cbPowr: NSButton!
    @IBOutlet weak var cbTix: NSButton!
    @IBOutlet weak var cbSteem: NSButton!
    @IBOutlet weak var cbMer: NSButton!
    @IBOutlet weak var cbMtl: NSButton!
    @IBOutlet weak var cbSbd: NSButton!
    @IBOutlet weak var cbOmg: NSButton!
    @IBOutlet weak var cbStorj: NSButton!
    @IBOutlet weak var cbKmd: NSButton!
    @IBOutlet weak var cbArk: NSButton!
    @IBOutlet weak var cbLsk: NSButton!
    @IBOutlet weak var cbGrs: NSButton!
    @IBOutlet weak var cbPivx: NSButton!
    @IBOutlet weak var cbWaves: NSButton!
    @IBOutlet weak var cbVtc: NSButton!
    @IBOutlet weak var cbArdr: NSButton!
    
    @IBOutlet weak var cbBithumb: NSButton!
    @IBOutlet weak var cbCoinone: NSButton!
    @IBOutlet weak var cbPoloniex: NSButton!
//    @IBOutlet weak var cbOkcoin: NSButton!
//    @IBOutlet weak var cbHuobi: NSButton!
    @IBOutlet weak var cbBitfinex: NSButton!
    @IBOutlet weak var cbBittrex: NSButton!
    @IBOutlet weak var cbUpbit: NSButton!
    
    @IBOutlet var lbBtcTitle: NSTextField!
    @IBOutlet var lbEthTitle: NSTextField!
    @IBOutlet var lbDashTitle: NSTextField!
    @IBOutlet var lbLtcTitle: NSTextField!
    @IBOutlet var lbEtcTitle: NSTextField!
    @IBOutlet var lbXrpTitle: NSTextField!
    @IBOutlet var lbBchTitle: NSTextField!
    @IBOutlet var lbXmrTitle: NSTextField!
    @IBOutlet var lbQtumTitle: NSTextField!
    @IBOutlet var lbZecTitle: NSTextField!
    @IBOutlet var lbBtgTitle: NSTextField!
    @IBOutlet var lbIotaTitle: NSTextField!
    @IBOutlet var lbEmc2Title: NSTextField!
    @IBOutlet var lbEos: NSTextField!
    @IBOutlet var lbAda: NSTextField!
    @IBOutlet var lbSnt: NSTextField!
    @IBOutlet var lbNeo: NSTextField!
    @IBOutlet var lbXlm: NSTextField!
    @IBOutlet var lbXem: NSTextField!
    @IBOutlet var lbStrat: NSTextField!
    @IBOutlet var lbPowr: NSTextField!
    @IBOutlet var lbTix: NSTextField!
    @IBOutlet var lbSteem: NSTextField!
    @IBOutlet var lbMer: NSTextField!
    @IBOutlet var lbMtl: NSTextField!
    @IBOutlet var lbSbd: NSTextField!
    @IBOutlet var lbOmg: NSTextField!
    @IBOutlet var lbStorj: NSTextField!
    @IBOutlet var lbKmd: NSTextField!
    @IBOutlet var lbArk: NSTextField!
    @IBOutlet var lbLsk: NSTextField!
    @IBOutlet var lbGrs: NSTextField!
    @IBOutlet var lbPivx: NSTextField!
    @IBOutlet var lbWaves: NSTextField!
    @IBOutlet var lbVtc: NSTextField!
    @IBOutlet var lbArdr: NSTextField!
    
    @IBOutlet weak var stackViewSites: NSStackView!
    @IBOutlet weak var stackViewCoinName: NSStackView!
    
    @IBOutlet weak var btDonate: NSButton!
    @IBOutlet weak var viewDonateToggle: NSView!
    @IBOutlet weak var viewDonate: NSView!
    @IBOutlet weak var lbDingAlert: NSTextField!//alert message from Dingding to user
    @IBOutlet weak var cbShowIcon: NSButton!
    
    var arrCbCoin = [NSButton]()
    var arrCbSite = [NSButton]()
    
    var arrlbCoinTitle = [NSTextField]()
    
    var arrSiteView = [ModelSite]()
    
    var countUpdatedSite: Int = 0
    
    override func viewDidLoad() {
        arrCbCoin = [cbBtc, cbEth, cbDash, cbLtc, cbEtc, cbXrp, cbBch, cbXmr, cbQtum, cbZec, cbBtg, cbIota, cbEmc2,
                     cbEos, cbAda, cbSnt, cbNeo, cbXlm, cbXem, cbStrat, cbPowr, cbTix, cbSteem, cbMer, cbMtl, cbSbd, cbOmg, cbStorj, cbKmd, cbArk, cbLsk, cbGrs, cbPivx, cbWaves, cbVtc, cbArdr]
        //arrCbSite = [cbBithumb, cbCoinone, cbPoloniex, cbOkcoin, cbHuobi, cbBitfinex, cbBittrex]
        arrCbSite = [cbBithumb, cbCoinone, cbPoloniex, cbBitfinex, cbBittrex, cbUpbit]//휴오비 빼기
        arrlbCoinTitle = [lbBtcTitle, lbEthTitle, lbDashTitle, lbLtcTitle, lbEtcTitle, lbXrpTitle, lbBchTitle, lbXmrTitle, lbQtumTitle, lbZecTitle, lbBtgTitle, lbIotaTitle, lbEmc2Title,
                          lbEos, lbAda, lbSnt, lbNeo, lbXlm, lbXem, lbStrat, lbPowr, lbTix, lbSteem, lbMer, lbMtl, lbSbd, lbOmg, lbStorj, lbKmd, lbArk, lbLsk, lbGrs, lbPivx, lbWaves, lbVtc, lbArdr]
        
        addSiteView()
        
        initView()
        
        //Need to update in outside
        NotificationCenter.default.addObserver(self, selector: #selector(VCPopover.updateCoinState), name: NSNotification.Name(rawValue: "VCPopover.updateCoinState"), object: nil)
        NSRunningApplication.current.activate(options: NSApplication.ActivationOptions.activateIgnoringOtherApps)
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        updateCoinState()
        
        if(self.isDarkMode()) {
            (NSApplication.shared.delegate as! AppDelegate).statusItem.image = MyValue.isShowStatusbarIcon ? NSImage(named: "icon_white") : NSImage(named: "icon_none")
            btDonate.image = NSImage.init(named: "ic_expand_more_white")
            btRefresh.image = NSImage(named: "ic_autorenew_white")
            lbLine.backgroundColor = NSColor.white.withAlphaComponent(0.3)
            btMinimode.image = NSImage.init(named: "ic_fullscreen_white")
            btMinimode.image = NSImage.init(named: self.isDarkMode() ? "ic_fullscreen_exit_white" : "ic_fullscreen_exit_black")
        }
        else {
            (NSApplication.shared.delegate as! AppDelegate).statusItem.image = MyValue.isShowStatusbarIcon ? NSImage(named: "icon_black") : NSImage(named: "icon_none")
            btDonate.image = NSImage.init(named: "ic_expand_more_black")
            btRefresh.image = NSImage(named: "ic_autorenew_black")
            lbLine.backgroundColor = NSColor.darkGray.withAlphaComponent(0.3)
            btMinimode.image = NSImage.init(named: "ic_fullscreen_black")
        }
        NSRunningApplication.current.activate(options: NSApplication.ActivationOptions.activateIgnoringOtherApps)

        //From Secret Api!
        getDingdingAlertMessage()
        isShowDonateLayout()
    }
    
    //Setup popup buttons
    func initView() {
        //MyValue.clear() //For test
        
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
        
        cbShowIcon.state = MyValue.isShowStatusbarIcon ? .on : .off
        
        //Check Button
        for cb in arrCbCoin {
            cb.state = MyValue.arrSelectedCoin.contains(cb.title) ? .on : .off
            
            //Hide not selected coin view
            if(!MyValue.arrSelectedCoin.contains(cb.title)) {
                arrlbCoinTitle[cb.tag].isHidden = true
                
                for index in 0...arrSiteView.count-1 {
                    arrSiteView[index].setVisibilityLabel(position: cb.tag, isHidden: true)
                }
            }
        }
        for cb in arrCbSite {
            cb.state = MyValue.arrSelectedSite.contains(cb.title) ? .on : .off
            
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
        
        //첫번째 더해지는 애는 앞 라인을 숨긴다
        for viewSite in arrSiteView {
            if(!viewSite.isHidden) {
                viewSite.hideSeparator()
                break;
            }
        }
    }
    
    //Update coins sate in popover view
    @objc func updateCoinState() {
        lbUpdateTime.stringValue = Const.DEFAULT_LOADING_TEXT
        
        //Calculate count of selected site
        for cb in arrCbSite {
            if(cb.state == .on) {
                countUpdatedSite += 1
            }
        }
        
        //Update only selected site
        for cb in arrCbSite {
            if(cb.state == .on) {
                getCoinStateFromApi(indexOfSite: arrCbSite.index(of: cb)!)
            }
        }
    }
    
    func getCoinStateFromApi(indexOfSite: Int) {
        if(indexOfSite == 0){
            Api.getCoinsStateBithumb(arrSelectedCoins: MyValue.arrSelectedCoin, complete: {isSuccess, arrResult in
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
//        else if(indexOfSite == 3) {
//            Api.getCoinsStateOkcoin(arrSelectedCoins: MyValue.arrSelectedCoin, complete: {isSuccess, arrResult in
//                self.updateStateViewAfterGetDataFromApi(isSuccess: isSuccess, indexOfView: indexOfSite, arrData: arrResult)
//            })
//        }
//        else if(indexOfSite == 4) {
//            Api.getCoinsStateHuobiByCryptowatch(arrSelectedCoins: MyValue.arrSelectedCoin, complete: {isSuccess, arrResult in
//                self.updateStateViewAfterGetDataFromApi(isSuccess: isSuccess, indexOfView: indexOfSite, arrData: arrResult)
//            })
//        }
        else if(indexOfSite == 3) {
            Api.getCoinsStateBitfinex(arrSelectedCoins: MyValue.arrSelectedCoin, complete: {isSuccess, arrResult in
                self.updateStateViewAfterGetDataFromApi(isSuccess: isSuccess, indexOfView: indexOfSite, arrData: arrResult)
            })
        }
        else if(indexOfSite == 4) {
            Api.getCoinsStateBittrex(arrSelectedCoins: MyValue.arrSelectedCoin, complete: {isSuccess, arrResult in
                self.updateStateViewAfterGetDataFromApi(isSuccess: isSuccess, indexOfView: indexOfSite, arrData: arrResult)
            })
        }
        else if(indexOfSite == 5) {
            Api.getCoinsStateUpbit(arrSelectedCoins: MyValue.arrSelectedCoin, complete: {isSuccess, arrResult in
                //print("야\(arrResult)")
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
//        SecretApi.getDingAlertMessage(complete: {isSuccess, message in
//            if(isSuccess){
//                self.lbDingAlert.isHidden = false
//                self.lbDingAlert.stringValue = message
//            }
//            else {
//                self.lbDingAlert.isHidden = true
//            }
//        })
    }
    
    //🤑🤑🤑😢😢😢
    func isShowDonateLayout() {
//        SecretApi.isShowDonateLayout(complete: {isSuccess, result in
//            guard let isWillShow = Bool(result), isSuccess else {self.toggleDonateView(false); return}
//            self.toggleDonateView(isWillShow)
//        })
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
        if(MyValue.arrSelectedCoin.count > 15) {
            sender.state = .off
        }
        
        let isChecked = sender.state == .on
        
        //Hide coin name label
        arrlbCoinTitle[sender.tag].isHidden = !isChecked
        
        //Hide price label in model view
        for index in 0...arrSiteView.count-1 {
            arrSiteView[index].setVisibilityLabel(position: sender.tag, isHidden: !isChecked)
        }
        
        var arrSelected = [String]()
        for cb in arrCbCoin {
            if(cb.state == .on){
                arrSelected.append(Coin.allValues[cb.tag])
            }
        }
        MyValue.arrSelectedCoin = arrSelected
    }
    
    //change site check state
    @IBAction func changeCheckSite(_ sender: NSButton) {
        let isChecked = sender.state == .on
        
        stackViewSites.subviews[sender.tag].isHidden = !isChecked
        
        var arrSelected = [String]()
        for cb in arrCbSite {
            if(cb.state == .on){
                arrSelected.append(Site.allValues[cb.tag])
            }
        }
        MyValue.arrSelectedSite = arrSelected
        
        //첫번째 더해지는 애는 앞 라인을 숨긴다
        for viewSite in arrSiteView {
            if(!viewSite.isHidden) {
                viewSite.hideSeparator()
                break;
            }
        }
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
            viewCoinCheck.isHidden = true
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
        
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([NSPasteboard.PasteboardType.string], owner: nil)
        pasteboard.setString(address, forType: NSPasteboard.PasteboardType.string)
    }
    
    //Show icon in status bar
    @IBAction func clickShowStatusbarIcon(_ sender: NSButton) {
        MyValue.isShowStatusbarIcon = sender.state == .on
        
        if(MyValue.isShowStatusbarIcon) {
            if(UserDefaults.standard.string(forKey: "AppleInterfaceStyle") ?? "Light" == "Dark") {
                (NSApplication.shared.delegate as! AppDelegate).statusItem.image = NSImage(named: "icon_white")
            }
            else {
                (NSApplication.shared.delegate as! AppDelegate).statusItem.image = NSImage(named: "icon_black")
            }
        }
        else {
            (NSApplication.shared.delegate as! AppDelegate).statusItem.image = NSImage(named: "icon_none")
        }
    }
    
    //Terminate App
    @IBAction func clickQuit(_ sender: NSButton) {
        (NSApplication.shared.delegate as! AppDelegate).terminateTimer()
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
            spinAnimation.timingFunction = CAMediaTimingFunction (name: CAMediaTimingFunctionName.linear)
            
            btRefresh.layer?.anchorPoint = CGPoint(x: btRefresh.bounds.width/2, y: btRefresh.bounds.height/2)
            btRefresh.layer?.add(spinAnimation, forKey: "transform.rotation.z")
        } else {
            btRefresh.layer?.removeAllAnimations()
        }
    }
}
