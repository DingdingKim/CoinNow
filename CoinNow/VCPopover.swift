//
//  VCPopover.swift
//  DDCurrentCoinState
//
//  Created by DingMac on 2017. 6. 25..
//  Copyright © 2017년 DingdingKim. All rights reserved.
//

import Cocoa
import Starscream
import SwiftyJSON

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
    
    @IBOutlet weak var cHeightTick: NSLayoutConstraint!
    
    var currentTab: Site?
    
    var sites: [Site] = [Site]() //default is upbit TODO 바낸으로 할까? 국가별로 하면 좋을거같다
    var ticks = [Tick]() //이 갯수는 선택한 코인의 개수와 동일하다. 값을 계속 업데이트 하는 방식으로 사용한다
    
    override func viewDidLoad() {
        print("**********viewDidLoad")
        
        //MyValue.clear() //For test
        
        //Need to update in outside
        NotificationCenter.default.addObserver(self, selector: #selector(VCPopover.updateSelectedCoins), name: NSNotification.Name(rawValue: "VCPopover.updateSelectedCoins"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(VCPopover.finishSetCoins), name: NSNotification.Name(rawValue: "VCPopover.finishSetCoins"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(VCPopover.updateTick), name: NSNotification.Name(rawValue: "receiveTick"), object: nil)
        
        NSRunningApplication.current.activate(options: NSApplication.ActivationOptions.activateIgnoringOtherApps)
        
        initView()
        initData()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        print("**********viewWillAppear")
        
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
        
        for coin in MyValue.selectedCoins {
            self.ticks.append(Tick(coin: coin, currentPrice: -1))
        }
    }
    
    //Setup popup view
    func initView() {
        print("**********initView")
        
        viewDonateToggle.isHidden = true
        viewDonate.isHidden = true
        
        collectionViewCoin.customBackgroundColor = NSColor.black.withAlphaComponent(0.1)
        //collectionViewTick.customBackgroundColor = NSColor.white.withAlphaComponent(0.5)
        
        initCoinCollectionView()
        initTickCollectionView()
    }
    
    //코인정보 다 가지고 온 다음에 호출되어야한다
    func initStatusBarConfigureView() {
        guard let mySite = sites.filter({ $0.siteType == MyValue.mySiteType }).first else { return }
        
        btStatusUpdatePer.addItems(withTitles: Array(UpdatePer.allCases.map { $0.rawValue }))
        btStatusSite.addItems(withTitles: SiteType.allCases.map{ $0.rawValue })
        btStatusCoin.addItems(withTitles: mySite.coins.map { $0.marketAndCode })

        btStatusUpdatePer.selectItem(withTitle: MyValue.updatePer.rawValue)
        btStatusSite.selectItem(withTitle: MyValue.mySiteType.rawValue)
        btStatusCoin.selectItem(withTitle: MyValue.myCoin)
        
        cbShowMarket.state = MyValue.isHiddenStatusbarMarket ? .off : .on
        cbShowIcon.state = MyValue.isHiddenStatusbarIcon ? .off : .on
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
        collectionViewTick.wantsLayer = true
        
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
        print("**********finishSetCoins")
        
        initStatusBarConfigureView()
        
        //TODO 이게 왜 여기 있어야하지? 왜넣었어 딩딩아?
//        //소켓이 아니었다면(타이머) 소켓을 다시 만들고 연결한다
//        if MyValue.updatePer != .realTime {
//            print("**********finishSetCoins: ==== realtime이 아니다")
//            appDelegate.initWebSocket()
//        }
//        //소켓이었다면 선택된 코인들의 정보도 받을 수 있게(평소에는 내 코인 하나만 가져왔으니까) write
//        else {
//            appDelegate.writeToSocket()
//        }
        
        collectionViewCoin.reloadData()
    }
    
    //Update tick in popover view
    @objc func updateTick(_ notification: Notification) {
        guard let data = notification.userInfo?["tick"] as? WSocket else { return }
        
        for (index, tick) in ticks.enumerated() {
            if tick.coin.site == data.siteType, tick.coin.marketAndCode == (data.marketAndCode) {
                self.ticks[index].currentPrice = data.trade_price
                self.ticks[index].changeState = data.changeState
                
                break
            }
        }
        
        self.collectionViewTick.reloadData()
    }
    
    @objc func updateSelectedCoins() {
        var isContainUpbit = false
        var isContainBinance = false
        
        //요청 전 틱 리스트를 다시 만들어준다
        self.ticks.removeAll()
        
        for coin in MyValue.selectedCoins {
            if coin.site == .upbit {
                isContainUpbit = true
            }
            else if coin.site == .binance {
                isContainBinance = true
            }
            self.ticks.append(Tick(coin: coin, currentPrice: -1))
        }
        
        let tickCollectionviewHeight = CGFloat(ceil(Double(ticks.count) / 2.0) * 40)
        
        //max height : 400
        if tickCollectionviewHeight < 400 {
            cHeightTick.constant = tickCollectionviewHeight
        }
        
        collectionViewTick.reloadData()
        
        //바뀐 코인리스트를 가지고 틱을 가지고 오도록 웹소켓에 write
        
        if isContainUpbit {
            appDelegate.writeToSocket(.upbit)
        }
        else if isContainBinance {
            appDelegate.writeToSocket(.binance)
        }
    }
    
    @IBAction func changeMySite(_ sender: NSPopUpButton) {
        MyValue.mySiteType = SiteType(rawValue: sender.titleOfSelectedItem!) ?? .upbit
        
        guard let mySite = sites.filter({ $0.siteType == MyValue.mySiteType }).first else { return }
        
        let mySiteCoins = mySite.coins.map { $0.marketAndCode }

        //Update coin list for selected site
        btStatusCoin.removeAllItems()
        btStatusCoin.addItems(withTitles: mySiteCoins)

        //Current my coin is not tradable in changed market. So change my coin to first coin of tradable coins in my market.
        //사이트 바뀌면 무조건 바꾸는걸로 수정했다
        /*
        if mySiteCoins.count > 0,
           !mySiteCoins.contains(MyValue.myCoin) {
            btStatusCoin.selectItem(at: 0)

            MyValue.myCoin = mySiteCoins[0]
        }
         */
        
        MyValue.myCoin = mySiteCoins[0]
    }
    
    @IBAction func changeMyCoin(_ sender: NSPopUpButton) {
        MyValue.myCoin = sender.titleOfSelectedItem!
    }
    
    @IBAction func changeUpdatePer(_ sender: NSPopUpButton) {
        MyValue.updatePer = UpdatePer(rawValue: sender.titleOfSelectedItem!) ?? Const.DEFAULT_UPDATE_PER
    }
    
    @IBAction func clickRefresh(_ sender: NSButton) {
        //TODO 완전히 코인목록부터 다시 싹 가져오게 하는거도 좋을거같다
        //updateTick()
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
                if(view != viewDonate && view != viewDonateToggle) {
                    view.isHidden = false
                }
            }
            
            btMinimode.image = NSImage.init(named: "ic_fullscreen_exit")
        }
    }
    
    @IBAction func clickSiteTab(_ sender: NSSegmentedControl) {
        currentTab = sites[sender.selectedSegment]
        collectionViewCoin.reloadData()
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
        MyValue.isHiddenStatusbarIcon = sender.state == .off
    }
    
    //Show market in status bar(BTC 1000 or 1000)
    @IBAction func clickShowStatusbarMarket(_ sender: NSButton) {
        MyValue.isHiddenStatusbarMarket = sender.state == .off
    }
    
    //Terminate App
    @IBAction func clickQuit(_ sender: NSButton) {
        appDelegate.terminateTimer()
        NSApp.terminate(self)
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
        guard let marketCoins = currentTab?.marketAndCoins, indexPath.section < marketCoins.count else { return view }
        
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
