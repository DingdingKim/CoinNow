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
    @IBOutlet weak var cbShowIcon: NSButton!
    @IBOutlet weak var cbShowMarket: NSButton!
    
    @IBOutlet weak var lbLine: NSTextField!
    
    @IBOutlet weak var lbUpdateTime: NSTextField!
    @IBOutlet weak var btRefresh: NSButton!
    
    @IBOutlet weak var viewSelectCoins: NSView!
    @IBOutlet weak var collectionViewCoin: NSCollectionView!
    @IBOutlet weak var collectionViewTick: NSCollectionView!
    
    @IBOutlet weak var btDonate: NSButton!
    @IBOutlet weak var viewDonateToggle: NSView!
    @IBOutlet weak var viewDonate: NSView!
    
    var currentTab: Site?
    
    var sites: [Site] = [Site]() //default is upbit TODO 바낸으로 할까? 국가별로 하면 좋을거같다
    var ticks = [Tick]()
    
    override func viewDidLoad() {
        //MyValue.clear() //For test
        
        //Need to update in outside
        NotificationCenter.default.addObserver(self, selector: #selector(VCPopover.updateTick), name: NSNotification.Name(rawValue: "VCPopover.updateSelectedCoins"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(VCPopover.finishSetCoins), name: NSNotification.Name(rawValue: "VCPopover.finishSetCoins"), object: nil)
        
        NSRunningApplication.current.activate(options: NSApplication.ActivationOptions.activateIgnoringOtherApps)
        
        initView()
        initData()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        setDarkMode()
        
        NSRunningApplication.current.activate(options: .activateIgnoringOtherApps)
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
    
    //Setup popup view
    func initView() {
        viewDonateToggle.isHidden = true
        viewDonate.isHidden = true
        
        //For animation..
        btRefresh.wantsLayer = true
        collectionViewCoin.customBackgroundColor = NSColor.black.withAlphaComponent(0.1)
        
        initTickCollectionView()
    }
    
    //코인정보 다 가지고 온 다음에 호출되어야한다
    func initStatusBarConfigureView() {
        guard let mySite = sites.filter({ $0.siteType == MyValue.mySiteType }).first else { return }
        
        btStatusUpdatePer.addItems(withTitles: Array(Const.dicUpdatePerSec.keys))
        btStatusSite.addItems(withTitles: SiteType.allCases.map{ $0.rawValue })
        btStatusCoin.addItems(withTitles: mySite.coins.map { $0.marketAndCode })

        btStatusUpdatePer.selectItem(withTitle: MyValue.updatePer)
        btStatusSite.selectItem(withTitle: MyValue.mySiteType.rawValue)
        btStatusCoin.selectItem(withTitle: MyValue.myCoin)
        
        cbShowIcon.state = MyValue.isShowStatusbarIcon ? .on : .off
    }
    
    func initCoinCollectionView() {
        collectionViewCoin.dataSource = self
        collectionViewCoin.delegate = self
        collectionViewCoin.register(NSNib(nibNamed: "ItemCoin", bundle: nil), forItemWithIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ItemCoin"))
        
        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        collectionViewCoin.collectionViewLayout = flowLayout
    }
    
    func initTickCollectionView() {
        collectionViewTick.dataSource = self
        collectionViewTick.delegate = self
        collectionViewTick.register(NSNib(nibNamed: "ItemTick", bundle: nil), forItemWithIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ItemTick"))
        
        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        collectionViewTick.collectionViewLayout = flowLayout
    }
    
    //각 사이트 생성자에서 코인 로드가 완료 되면 호출
    @objc func finishSetCoins() {
        initStatusBarConfigureView()
        initCoinCollectionView()
        
        collectionViewCoin.reloadData()
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
    
    @IBAction func changeMySite(_ sender: NSPopUpButton) {
        guard let currentTab = currentTab else { return }
        
        let currentTabCoins = currentTab.coins.map { $0.marketAndCode }
        
        MyValue.mySiteType = SiteType(rawValue: sender.titleOfSelectedItem!) ?? .upbit

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
        MyValue.myCoin = sender.titleOfSelectedItem!
    }
    
    @IBAction func changeUpdatePer(_ sender: NSPopUpButton) {
        MyValue.updatePer = sender.titleOfSelectedItem ?? Const.DEFAULT_UPDATE_PER.stirng
    }
    
    @IBAction func clickRefresh(_ sender: NSButton) {
        updateTick()
    }
    
    @IBAction func clickMinimode(_ sender: Any) {
        MyValue.isSimpleMode = !MyValue.isSimpleMode

        if(MyValue.isSimpleMode) {
            viewStatusSetting.isHidden = true
            viewSelectCoins.isHidden = true
            lbLine.isHidden = true
            
            btMinimode.image = NSImage.init(named: "ic_fullscreen")
        }
        else {
            for view in stackViewRoot.arrangedSubviews {
                if(view != viewDonate && view != viewDonateToggle){
                    view.isHidden = false
                }
            }
            
            btMinimode.image = NSImage.init(named: "ic_fullscreen_exit")
        }
    }
    
    @IBAction func clickDonate(_ sender: NSButton) {
        //close
        if(sender.tag == 0){
            btDonate.image = NSImage.init(named: "ic_expand_less")
            viewDonate.isHidden = false
            sender.tag = 1
        }
        else {
            btDonate.image = NSImage.init(named: "ic_expand_more")
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
    }
    
    //Show market in status bar(BTC 1000 or 1000)
    @IBAction func clickShowStatusbarMarket(_ sender: NSButton) {
        MyValue.isShowStatusbarMarket = sender.state == .on
    }
    
    //Terminate App
    @IBAction func clickQuit(_ sender: NSButton) {
        (NSApplication.shared.delegate as! AppDelegate).terminateTimer()
        NSApp.terminate(self)
    }
    
    func setDarkMode() {
        lbLine.backgroundColor = NSColor.white.withAlphaComponent(0.3)
        (NSApplication.shared.delegate as! AppDelegate).updateStatusItem(willShowLoadingText: false)
        lbLine.backgroundColor = NSColor.darkGray.withAlphaComponent(0.3)
    }
}

// MARK: - NSCollectionViewDataSource
extension VCPopover: NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collectionViewCoin, currentTab?.marketAndCoins.count ?? 0 > 0 {
            return currentTab?.marketAndCoins[section].coins.count ?? 0
        }
        else if collectionView == collectionViewTick {
            return ticks.count
        }

        return 0
    }
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        if collectionView == collectionViewCoin, currentTab?.marketAndCoins.count ?? 0 > 0 {
            return currentTab?.marketAndCoins.count ?? 1
        }
        
        return 1
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        if collectionView == collectionViewCoin {
            let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ItemCoin"), for: indexPath) as! ItemCoin
            guard let coins = currentTab?.marketAndCoins[indexPath.section].coins else { return NSCollectionViewItem() }
            
            item.data = coins[indexPath.item]

            return item
        }
        else if collectionView == collectionViewTick {
            guard indexPath.item < ticks.count else { return NSCollectionViewItem() }
            
            let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ItemTick"), for: indexPath) as! ItemTick
            item.updateView(tick: ticks[ indexPath.item], index: indexPath.item, isLastRow: ticks.count / 2 <= indexPath.item)
            
            return item
        }

        return NSCollectionViewItem()
    }
    
    func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind, at indexPath: IndexPath) -> NSView {
        guard let view = collectionView.makeSupplementaryView(ofKind: NSCollectionView.elementKindSectionHeader,
                                                              withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "HeaderCoin"),
                                                              for: indexPath) as? HeaderCoin else { return NSView() }
        guard let marketCoins = currentTab?.marketAndCoins else { return view }
        
        view.updateView(data: marketCoins[indexPath.section])
        
        return view
    }
}

// MARK: - NSCollectionViewDelegateFlowLayout
extension VCPopover: NSCollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        if collectionView == collectionViewCoin {
            return NSSize(width: collectionView.frame.width / 5.3, height: 30.0)
        }
        else if collectionView == collectionViewTick {
            return NSSize(width: collectionView.frame.width / 2.1, height: 40.0)
        }
        return .zero
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> NSSize {
        if collectionView == collectionViewCoin {
            return NSSize(width: 0.0, height: 20.0)
        }
        
        return .zero
    }
}
