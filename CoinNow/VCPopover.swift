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
    
    @IBOutlet weak var btStatusUpdatePer: NSPopUpButton!
    @IBOutlet weak var btStatusSite: NSPopUpButton!
    @IBOutlet weak var btStatusCoin: NSPopUpButton!
    
    @IBOutlet weak var lbLine: NSTextField!
    
    @IBOutlet weak var lbUpdateTime: NSTextField!
    @IBOutlet weak var btRefresh: NSButton!
    
    @IBOutlet weak var collectionViewCoin: NSCollectionView!
    @IBOutlet weak var collectionViewTick: NSCollectionView!
    
    @IBOutlet weak var btDonate: NSButton!
    @IBOutlet weak var viewDonateToggle: NSView!
    @IBOutlet weak var viewDonate: NSView!
    @IBOutlet weak var lbDingAlert: NSTextField!//alert message from Dingding to user
    @IBOutlet weak var cbShowIcon: NSButton!
    
    var currentTab: Site?
    
    var sites: [Site] = [Site]() //default is upbit TODO 바낸으로 할까? 국가별로 하면 좋을거같다
    var ticks = [Tick]()
    
    override func viewDidLoad() {
        //MyValue.clear() //For test
        
        //Need to update in outside
        //NotificationCenter.default.addObserver(self, selector: #selector(VCPopover.updateTick), name: NSNotification.Name(rawValue: "VCPopover.updateCoinState"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(VCPopover.updateTick), name: NSNotification.Name(rawValue: "VCPopover.updateSelectedCoins"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(VCPopover.finishSetCoins), name: NSNotification.Name(rawValue: "VCPopover.finishSetCoins"), object: nil)
        
        NSRunningApplication.current.activate(options: NSApplication.ActivationOptions.activateIgnoringOtherApps)
        
        initView()
        initData()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
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
        
        NSRunningApplication.current.activate(options: .activateIgnoringOtherApps)

        //From Secret Api!
        //getDingdingAlertMessage()
        //isShowDonateLayout()
    }
    
    func initMyData() {
        if(UserDefaults.standard.string(forKey: "AppleInterfaceStyle") ?? "Light" == "Dark") {
            (NSApplication.shared.delegate as! AppDelegate).statusItem.image = NSImage(named: "icon_white")
        }
    }
    
    func initData() {
        for siteType in SiteType.allCases {
            let site = Site(siteType: siteType)
            
            self.sites.append(site)
            
            if siteType == Const.DEFAULT_SITE_TYPE {
                self.currentTab = site
            }
        }
        
        self.updateTick()
    }
    
    //Setup popup buttons
    func initView() {
        viewDonateToggle.isHidden = true
        viewDonate.isHidden = true
        
        lbDingAlert.isHidden = true
        
        //For animation..
        btRefresh.wantsLayer = true
        
        //initStatusBarConfigureView()
        initCoinCollectionView()
        initTickCollectionView()
    }
    
    //코인정보 다 가지고 온 다음에 호출되어야한다
    func initStatusBarConfigureView() {
        guard let mySite = sites.filter({ $0.siteType == MyValue.mySite }).first else { return }
        
        btStatusUpdatePer.addItems(withTitles: Array(Const.dicUpdatePerSec.keys))
        btStatusSite.addItems(withTitles: SiteType.allCases.map{ $0.rawValue })
        btStatusCoin.addItems(withTitles: mySite.coins.map { $0.marketAndCode })

        btStatusUpdatePer.selectItem(withTitle: MyValue.updatePer)
        btStatusSite.selectItem(withTitle: MyValue.mySite.rawValue)
        btStatusCoin.selectItem(withTitle: MyValue.myCoin)
        
        cbShowIcon.state = MyValue.isShowStatusbarIcon ? .on : .off
    }
    
    func initCoinCollectionView() {
        collectionViewCoin.register(NSNib(nibNamed: "ItemCoin", bundle: nil), forItemWithIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ItemCoin"))
        
        let gridLayout = NSCollectionViewGridLayout()
        gridLayout.minimumItemSize = NSSize(width: collectionViewCoin.frame.width/4.2, height: 30.0)
        gridLayout.maximumItemSize = NSSize(width: collectionViewCoin.frame.width/4.2, height: 30.0)
        gridLayout.maximumNumberOfColumns = 4
        collectionViewCoin.collectionViewLayout = gridLayout
    }
    
    func initTickCollectionView() {
        collectionViewTick.register(NSNib(nibNamed: "ItemTick", bundle: nil), forItemWithIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ItemTick"))
        
        let gridLayout = NSCollectionViewGridLayout()
        gridLayout.minimumItemSize = NSSize(width: collectionViewTick.frame.width/2.2, height: 50.0)
        gridLayout.maximumItemSize = NSSize(width: collectionViewTick.frame.width/2.2, height: 50.0)
        gridLayout.maximumNumberOfColumns = 2
        collectionViewTick.collectionViewLayout = gridLayout
    }
    
    //각 사이트 생성자에서 코인 로드가 완료 되면 호출
    @objc func finishSetCoins() {
        collectionViewCoin.reloadData()
        updateTick()
        
        initStatusBarConfigureView()
    }
    
    //Update tick in popover view
    @objc func updateTick() {
        lbUpdateTime.stringValue = Const.DEFAULT_LOADING_TEXT
        
        Api.getUpbitTicks(selectedCoins: MyValue.selectedCoins, complete: { isSuccess, result in
            self.ticks.removeAll()
            self.ticks.append(contentsOf: result)
            
            self.collectionViewTick.reloadData()
            
            self.lbUpdateTime.stringValue = Date().todayString(format: "yyyy.MM.dd HH:mm:ss")
            
            if !isSuccess {
                self.lbUpdateTime.stringValue = self.lbUpdateTime.stringValue + " last update is failed"
            }
        })
    }
    
    @IBAction func changeUpdatePer(_ sender: NSPopUpButton) {
        MyValue.updatePer = sender.titleOfSelectedItem ?? Const.DEFAULT_UPDATE_PER.stirng
    }
    
    @IBAction func changeMySite(_ sender: NSPopUpButton) {
        guard let currentTab = currentTab else { return }
        
        let currentTabCoins = currentTab.coins.map { $0.marketAndCode }
        
        MyValue.mySite = SiteType(rawValue: sender.titleOfSelectedItem!) ?? .upbit

        //Update coin list for selected site
        btStatusCoin.removeAllItems()
        btStatusCoin.addItems(withTitles: currentTabCoins)

        //Current my coin is not tradable in changed market. So change my coin to first coin of tradable coins in my market.
        if currentTabCoins.count > 0,
           !currentTabCoins.contains(MyValue.myCoin) {
            btStatusCoin.selectItem(at: 0)

            MyValue.myCoin = currentTab.coins[0].marketAndCode
        }
    }
    
    @IBAction func changeMyCoin(_ sender: NSPopUpButton) {
        MyValue.myCoin = sender.titleOfSelectedItem!//currentTab. MyValue.mySite.coins.filter { $0.coin }// Coin.valueOf(name: sender.titleOfSelectedItem!)
    }
    
    //Refresh data
    @IBAction func clickRefresh(_ sender: NSButton) {
        updateTick()
    }
    
    @IBAction func clickMinimode(_ sender: Any) {
        MyValue.isSimpleMode = !MyValue.isSimpleMode

        if(MyValue.isSimpleMode) {
            viewStatusSetting.isHidden = true
            lbLine.isHidden = true
            
            btMinimode.image = NSImage.init(named: self.isDarkMode() ? "ic_fullscreen_white" : "ic_fullscreen_black")
        }
        else {
            for view in stackViewRoot.arrangedSubviews {
                if(view != viewDonate && view != viewDonateToggle){
                    view.isHidden = false
                }
            }
            
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
//        let address = Coin.donateAddress(index: sender.tag)
//
//        let pasteboard = NSPasteboard.general
//        pasteboard.declareTypes([NSPasteboard.PasteboardType.string], owner: nil)
//        pasteboard.setString(address, forType: NSPasteboard.PasteboardType.string)
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
            spinAnimation.timingFunction = CAMediaTimingFunction (name: .linear)
            
            btRefresh.layer?.anchorPoint = CGPoint(x: btRefresh.bounds.width/2, y: btRefresh.bounds.height/2)
            btRefresh.layer?.add(spinAnimation, forKey: "transform.rotation.z")
        } else {
            btRefresh.layer?.removeAllAnimations()
        }
    }
}


// MARK: - NSCollectionViewDataSource
extension VCPopover: NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collectionViewCoin {
            return currentTab?.coins.count ?? 0
        }
        else if collectionView == collectionViewTick {
            return ticks.count
        }

        return 0
    }
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        if collectionView == collectionViewCoin {
            let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ItemCoin"), for: indexPath) as! ItemCoin
            guard let coins = currentTab?.coins else { return NSCollectionViewItem() }
            
            item.data = coins[indexPath.item]

            return item
        }
        else if collectionView == collectionViewTick {
            let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ItemTick"), for: indexPath) as! ItemTick
            item.updateView(tick: ticks[ indexPath.item])
            
            return item
        }

        return NSCollectionViewItem()
    }
}


// MARK: - NSCollectionViewDelegateFlowLayout
extension VCPopover: NSCollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
//        return NSSize(width: 150.0, height: 150.0)
//    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> NSSize {
        return .zero
    }
}
