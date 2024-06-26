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
import FirebaseRemoteConfig
import FirebaseDatabase

class VCPopover: NSViewController {
    @IBOutlet weak var stackViewRoot: NSStackView!
    
    @IBOutlet weak var btMinimode: NSButton!
    @IBOutlet weak var viewStatusSetting: NSView!
    
    @IBOutlet weak var btStatusSite: NSPopUpButton!
    @IBOutlet weak var btStatusCoin: NSPopUpButton!
    @IBOutlet weak var cbShowIcon: NSButton!
    @IBOutlet weak var cbShowMarket: NSButton!
    
    @IBOutlet weak var viewDingMessage: NSView!
    @IBOutlet weak var viewSendDingMessage: NSView!
    @IBOutlet weak var lbDingMessage: NSTextField!
    
    @IBOutlet weak var viewSelectCoins: NSView!
    @IBOutlet weak var segmentCoins: NSSegmentedControl!
    @IBOutlet weak var collectionViewCoin: NSCollectionView!
    @IBOutlet weak var collectionViewTick: NSCollectionView!
    
    @IBOutlet weak var tfSendMessage: NSTextField!
    @IBOutlet weak var btToggleSendMessage: NSButton!
    @IBOutlet weak var btSendMessage: NSButton!
    
    @IBOutlet weak var btDonate: NSButton!
    @IBOutlet weak var viewDonateToggle: NSView!
    @IBOutlet weak var viewDonate: NSView!
    
    @IBOutlet weak var cHeightTick: NSLayoutConstraint!
    @IBOutlet weak var cHeightSendMessage: NSLayoutConstraint!
    @IBOutlet weak var viewNetworkError: NSView!
    @IBOutlet weak var searchField: NSSearchField!
    
    var currentTab: Site?
    
    var sites: [Site] = [Site]() //default is upbit TODO 바낸으로 할까? 국가별로 하면 좋을거같다
    var ticks = [Tick]() //이 갯수는 선택한 코인의 개수와 동일하다. 값을 계속 업데이트 하는 방식으로 사용한다
    
    //이걸 하나로 묶어서 관리 할 수 있을거같다(얘는 팝오버 열릴때만 생성)
    private var socketUpbit: WebSocket!
    private var socketBinance: WebSocket!
    private var socketBinanceF: WebSocket!//선물
    
    var remoteConfig: RemoteConfig!
    var realtimeDatabase: DatabaseReference!
    var searchText: String = ""
    
    var isSocketConnectedUpbit: Bool = false {
        didSet {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "socketStateChanged"),
                                            object: nil,
                                            userInfo: ["isConnected" : isSocketConnectedUpbit, "siteType": SiteType.upbit])
        }
    }
    
    var isSocketConnectedBinance: Bool = false {
        didSet {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "socketStateChanged"),
                                            object: nil,
                                            userInfo: ["isConnected" : isSocketConnectedBinance, "siteType": SiteType.binance])
        }
    }
    
    var isSocketConnectedBinanceF: Bool = false {
        didSet {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "socketStateChanged"),
                                            object: nil,
                                            userInfo: ["isConnected" : isSocketConnectedBinanceF, "siteType": SiteType.binanceF])
        }
    }
    
    override func viewDidLoad() {
        print("**********viewDidLoad")
        
        //MyValue.clear() //For test
        
        NotificationCenter.default.addObserver(self, 
                                               selector: #selector(VCPopover.updateSelectedCoins),
                                               name: NSNotification.Name(rawValue: "VCPopover.updateSelectedCoins"),
                                               object: nil)
        NotificationCenter.default.addObserver(self, 
                                               selector: #selector(VCPopover.finishSetCoins),
                                               name: NSNotification.Name(rawValue: "VCPopover.finishSetCoins"),
                                               object: nil)
        NotificationCenter.default.addObserver(self, 
                                               selector: #selector(VCPopover.updateTick), 
                                               name: NSNotification.Name(rawValue: "receiveTick"), 
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(VCPopover.updateConnectionStatus), 
                                               name: NSNotification.Name(rawValue: "updateConnectionStatus"), 
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(VCPopover.updateCollectionViewCoin), 
                                               name: NSNotification.Name(rawValue: "VCPopover.updateCollectionViewCoin"), 
                                               object: nil)
        
        NSRunningApplication.current.activate(options: NSApplication.ActivationOptions.activateIgnoringOtherApps)
        
        initView()
        initData()
        initRemoteConfig()
        initRealtimeDatabase()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        print("**********viewWillAppear")
        
        //팝업이 뜰때마다 소켓을 다시 연결
        initWebSocket(.upbit)
        initWebSocket(.binance)
        initWebSocket(.binanceF)
        
        updateView()
        
        NSRunningApplication.current.activate(options: .activateIgnoringOtherApps)
    }
    
    override func viewDidDisappear() {
        disconnectSockets()
    }
    
    func initData() {
        for siteType in SiteType.allCases {
            let site = Site(siteType: siteType)
            
            sites.append(site)
            
            if siteType == Const.DEFAULT_SITE_TYPE {
                currentTab = site
            }
        }
        
        for coin in MyValue.selectedCoins {
            ticks.append(Tick(coin: coin, currentPrice: -1, updateTime: 0))
        }
    }
    
    func initRemoteConfig() {
        remoteConfig = RemoteConfig.remoteConfig()
        
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        //remoteConfig.setDefaults(fromPlist: "RemoteConfigDefaults")
        
        remoteConfig.fetch { (status, error) -> Void in
            if status == .success {
                print("Config fetched!")
                self.remoteConfig.activate { changed, error in
                    if let message = self.remoteConfig["message"].stringValue {
                        DispatchQueue.main.async {
                            self.lbDingMessage.stringValue = message
                        }
                    }
                }
              }
            else {
                print("Config not fetched")
                print("Error: \(error?.localizedDescription ?? "No error available.")")
            }
        }
    }
    
    func initRealtimeDatabase() {
        realtimeDatabase = Database.database().reference()
    }
    
    func initView() {
        print("**********initView")
        
        //일단 숨겨놓는다
        viewDonateToggle.isHidden = true
        viewDonate.isHidden = true
        
        segmentCoins.selectedSegmentBezelColor = .controlAccentColor
        
        collectionViewCoin.customBackgroundColor = NSColor.black.withAlphaComponent(0.1)
        
        initCoinCollectionView()
        initTickCollectionView()
    }
    
    //코인정보 다 가지고 온 다음에 호출되어야한다
    func initStatusBarConfigureView() {
        guard let mySite = sites.filter({ $0.siteType == MyValue.mySiteType }).first else { return }
        
        btStatusSite.addItems(withTitles: SiteType.allCases.map{ $0.rawValue })
        btStatusCoin.addItems(withTitles: mySite.coins.map { $0.marketAndCode })

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
    
    func updateView() {
        let tickCollectionviewHeight = CGFloat(ceil(Double(ticks.count) / 2.0) * 40)
        
        if tickCollectionviewHeight < 400 {
            cHeightTick.constant = tickCollectionviewHeight
        }
        
        viewNetworkError.isHidden = Reachability.isConnectedToNetwork()
    }
    
    //각 사이트 생성자에서 코인 로드가 완료 되면 호출
    @objc func finishSetCoins(_ notification: Notification) {
        print("**********finishSetCoins")
        guard let data = notification.userInfo?["site"] as? Site else { return }
        
        if data.siteType == Const.DEFAULT_SITE_TYPE {
            //아무것도 없는 경우 업빗에서 가져온거에서 앞에 3개를 넣어준다
            if MyValue.selectedCoins.count == 0, data.marketAndCoins.count > 0, data.marketAndCoins[0].coins.count > 0 {
                MyValue.selectedCoins.append(contentsOf: data.marketAndCoins[0].coins.sorted(by: { $0.market > $1.market })[0...3])
                
                for coin in MyValue.selectedCoins {
                    ticks.append( (Tick(coin: coin, currentPrice: -1, updateTime: 0)))
                }
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "VCPopover.updateSelectedCoins"), object: nil)
            }
        }
        
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
                self.ticks[index].updateTime = data.timestamp
                
                break
            }
        }
        
        self.collectionViewTick.reloadData()
    }
    
    @objc func updateSelectedCoins(_ notification: Notification) {
        if let coin = notification.userInfo?["coin"] as? Coin,
           let isAdded = notification.userInfo?["isAdded"] as? Bool {
            
            //추가된것 등록하기
            if isAdded {
                ticks.append(Tick(coin: coin, currentPrice: -1, updateTime: 0))
                
                //바뀐 코인리스트를 가지고 틱을 가지고 오도록 웹소켓에 write
                writeToSocket(coin.site)
            }
            //삭제 된 것 제외하기
            else {
                for (index, tick) in ticks.enumerated() {
                    if coin.uniqueId == tick.coin.uniqueId {
                        ticks.remove(at: index)
                        
                        if coin.site == .upbit {
                            writeToSocket(coin.site)
                        }
                        else if coin.site == .binance || coin.site == .binanceF {
                            unSubscribeBinance(coin: coin)
                        }
                        break
                    }
                }
            }
        }
        // userInfo없는 경우는 최초에 기본 4개 선택 된 상태일 때다
        else {
            writeToSocket(MyValue.selectedCoins[0].site)
        }
        
        let tickCollectionviewHeight = CGFloat(ceil(Double(ticks.count) / 2.0) * 40)
        
        //max height : 400
        if tickCollectionviewHeight < 400 {
            cHeightTick.constant = tickCollectionviewHeight
        }
        
        collectionViewTick.reloadData()
    }
    
    // 전체 코인 선택 컬렉션 뷰 업데이트(즐겨찾기에서 삭제 한 경우 호출됨. 아..스유로하면 깔끔하게 될텐데 오랜만에 UIKit하려니 깝깝하네ㅋㅋ)
    @objc func updateCollectionViewCoin(_ notification: Notification) {
        //guard let data = notification.userInfo?["tick"] as? WSocket else { return }

        self.collectionViewCoin.reloadData()
    }
    
    //TODO 생긴게 맘에 안든다
    func initWebSocket(_ siteType: SiteType) {
        print("--------initWebSocket")
        
        if siteType == .upbit {
            print("--------initWebSocket 업비트")
            var request = URLRequest(url: URL(string: Const.WEBSOCKET_UPBIT)!)
            request.timeoutInterval = 5
            
            disconnectSockets(.upbit)
            
            socketUpbit = WebSocket(request: request)
            socketUpbit.delegate = self
            socketUpbit.connect()
        }
        else if siteType == .binance {
            print("--------initWebSocket 바낸")
            var request = URLRequest(url: URL(string: Const.WEBSOCKET_BINANCE)!)
            request.timeoutInterval = 5
            
            disconnectSockets(.binance)
            
            socketBinance = WebSocket(request: request)
            socketBinance.delegate = self
            socketBinance.connect()
        }
        else if siteType == .binanceF {
            print("--------initWebSocket 바낸(F)")
            var request = URLRequest(url: URL(string: Const.WEBSOCKET_BINANCE_F)!)
            request.timeoutInterval = 5
            
            disconnectSockets(.binanceF)
            
            socketBinanceF = WebSocket(request: request)
            socketBinanceF.delegate = self
            socketBinanceF.connect()
        }
    }
    
    func disconnectSockets(_ siteType: SiteType? = nil) {
        print("--------disconnectSockets: \(String(describing: siteType))")
        
        if let siteType = siteType {
            if siteType == .upbit {
                if socketUpbit != nil {
                    socketUpbit.forceDisconnect()
                }
            }
            else if siteType == .binance {
                if socketBinance != nil {
                    socketBinance.forceDisconnect()
                }
            }
            else if siteType == .binanceF {
                if socketBinanceF != nil {
                    socketBinanceF.forceDisconnect()
                }
            }
        }
        else {
            if socketUpbit != nil {
                socketUpbit.forceDisconnect()
            }
            
            if socketBinance != nil {
                socketBinance.forceDisconnect()
            }
            
            if socketBinanceF != nil {
                socketBinanceF.forceDisconnect()
            }
        }
    }
    
    func unSubscribeBinance(coin: Coin) {
        let splited = coin.marketAndCode.split(separator: "-")
        let symbol = String(splited[1]) + String(splited[0])
        
        let param = "{\"method\": \"UNSUBSCRIBE\",\"params\":[\"\(symbol.lowercased())@ticker\"],\"id\": 1}"
        print("구독해제: \(param)")

        //기존거 다 삭제하고 다시 받도록 한다
        if coin.site == .binanceF {
            socketBinanceF.write(string: param) {
                print("바낸 선물 전송 완료")
            }
        }
        else {
            socketBinance.write(string: param) {
                print("바낸 전송 완료")
            }
        }
    }
    
    //업비트 웹소켓으로 틱 정보 가져옴
    func writeToSocket(_ siteType: SiteType) {
        if siteType == .upbit {
            guard socketUpbit != nil, isSocketConnectedUpbit else {
                initWebSocket(.upbit)
                
                print("연결안됨. 업빗 소켓 다시 세팅");
                return
            }
            
            //팝오버가 안보이면 내꺼만 가져오고 보이면 선택코인 다가져와
            let marketAndCodes = MyValue.selectedCoins.filter({ $0.site == .upbit })
                                                                        .map { $0.marketAndCode }
            
            let marketAndCodesString = marketAndCodes.joined(separator: "\",\"")
            let param = "[{\"ticket\":\"popup\"},{\"type\":\"ticker\",\"codes\":[\"\(marketAndCodesString)\"]}]"
            print("writeToSocket 업빗: \(param)")
            
            socketUpbit.write(string: param) {
                print("업빗 전송 완료")
            }
        }
        
        else if siteType == .binance || siteType == .binanceF {
            if siteType == .binance {
                guard socketBinance != nil, isSocketConnectedBinance else {
                    initWebSocket(.binance)
                    
                    print("연결안됨. 바낸 소켓 다시 세팅");
                    return
                }
            }
            else if siteType == .binanceF {
                guard socketBinanceF != nil, isSocketConnectedBinanceF else {
                    initWebSocket(.binanceF)
                    
                    print("연결안됨. 바낸(선물) 소켓 다시 세팅");
                    return
                }
            }
            
            let marketAndCodes = MyValue.selectedCoins.filter({ $0.site == siteType })
                                                                        .map {
                                                                            return $0.code + $0.market + "@ticker"
                                                                        }
            
            //구독할게 없다
            guard marketAndCodes.count > 0 else { print( "구독할게없다"); return }
            
            let marketAndCodesString = marketAndCodes.joined(separator: "\",\"")
            let param = "{\"method\": \"SUBSCRIBE\",\"params\":[\"\(marketAndCodesString.lowercased())\"],\"id\": 1}"
            print("writeToSocket 바낸: \(param)")
            //wss://stream.binance.com:9443/ws/btcusdt@ticker/etcusdt@ticker
            //{"method": "SUBSCRIBE","params":["etcusdt@ticker", "btcusdt@ticker"],"id": 312}
            //{"method": "SUBSCRIBE","params":["btcusdt@ticker"],"id": 312}
            
            //기존거 다 삭제하고 다시 받도록 한다
            
            if siteType == .binanceF {
                socketBinanceF.write(string: param) {
                    print("바낸(선물) 전송 완료")
                }
            }
            else {
                socketBinance.write(string: param) {
                    print("바낸 전송 완료")
                }
            }
        }
    }
    
    //인터넷 연결상태 변경 시 호출
    @objc func updateConnectionStatus(_ notification: Notification?) {
        viewNetworkError.isHidden = notification?.userInfo?["isConnected"] as? Bool ?? true
        print("👋 하이: \(notification?.userInfo?["isConnected"] as? Bool ?? true)")
    }
    
    @IBAction func changeMySite(_ sender: NSPopUpButton) {
        MyValue.mySiteType = SiteType(rawValue: sender.titleOfSelectedItem!) ?? .upbit
        
        guard let mySite = sites.filter({ $0.siteType == MyValue.mySiteType }).first else { return }
        
        let mySiteCoins = mySite.coins.map { $0.marketAndCode }

        //Update coin list for selected site
        btStatusCoin.removeAllItems()
        btStatusCoin.addItems(withTitles: mySiteCoins)

        MyValue.myCoin = mySiteCoins[0]
    }
    
    @IBAction func changeMyCoin(_ sender: NSPopUpButton) {
        MyValue.myCoin = sender.titleOfSelectedItem!
    }
    
    @IBAction func clickMinimode(_ sender: Any) {
        MyValue.isSimpleMode = !MyValue.isSimpleMode

        if(MyValue.isSimpleMode) {
            viewStatusSetting.isHidden = true
            viewSelectCoins.isHidden = true
            viewDingMessage.isHidden = true
            
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
        disconnectSockets()
        
        NSApp.terminate(self)
    }
    
    @IBAction func clickDonate(_ sender: NSButton) {
        //close
        if(sender.tag == 0) {
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
    
    @IBAction func clickToggleSendMessage(_ sender: NSButton) {
        //닫힌상태에서 열기
        if(sender.tag == 0){
            btToggleSendMessage.image = NSImage.init(named: "ic_expand_less")
            cHeightSendMessage.constant = 50
            // hidden으로 조절하면 포커싱문제가 있어서 투명도로 조정했다
            viewSendDingMessage.layer?.opacity = 1
            //tfSendMessage.isEnabled = true
            sender.tag = 1
        }
        else {
            btToggleSendMessage.image = NSImage.init(named: "ic_expand_more")
            cHeightSendMessage.constant = 0
            viewSendDingMessage.layer?.opacity = 0
            //tfSendMessage.isEnabled = false
            sender.tag = 0
        }
    }
    
    @IBAction func clickSendMessage(_ sender: NSButton) {
        if !tfSendMessage.stringValue.isEmpty {
            realtimeDatabase.child(Date().todayString(format: "yyyy-MM-dd HH:mm:ss"))
                .child("userMessage")
                .setValue(tfSendMessage.stringValue, withCompletionBlock: { error,_ in
                    self.tfSendMessage.stringValue = ""
                    self.tfSendMessage.placeholderString = error == nil ? "전송 완료!👍" : "전송 실패!😭"
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.tfSendMessage.placeholderString = "개발자에게 한마디 😎"
                    }
                })
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
}

// MARK: - NSCollectionViewDataSource
extension VCPopover: NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collectionViewCoin, currentTab?.filteredTicks(searchText: searchText).count ?? 0 > 0 {
            return currentTab?.filteredTicks(searchText: searchText)[section].coins.count ?? 0
        }
        else if collectionView == collectionViewTick {
            return ticks.count
        }

        return 0
    }
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        if collectionView == collectionViewCoin, currentTab?.filteredTicks(searchText: searchText).count ?? 0 > 0 {
            return currentTab?.filteredTicks(searchText: searchText).count ?? 1
        }

        return 1
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        if collectionView == collectionViewCoin {
            let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ItemCoin"), for: indexPath) as! ItemCoin
            guard let coins = currentTab?.filteredTicks(searchText: searchText)[indexPath.section].coins else { return NSCollectionViewItem() }
            
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
        guard let marketCoins = currentTab?.filteredTicks(searchText: searchText), indexPath.section < marketCoins.count else { return view }
        
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

extension VCPopover: WebSocketDelegate {
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        var siteType: SiteType = .upbit
        
        if client.request.url == socketUpbit.request.url {
            siteType = .upbit
        }
        else if client.request.url == socketBinance.request.url {
            siteType = .binance
        }
        else if client.request.url == socketBinanceF.request.url {
            siteType = .binanceF
        }
        
        switch event {
        case .connected( _):
            if socketUpbit != nil, siteType == .upbit {
                self.isSocketConnectedUpbit = true
            }
            else if socketBinance != nil, siteType == .binance {
                self.isSocketConnectedBinance = true
            }
            else if socketBinanceF != nil, siteType == .binanceF {
                self.isSocketConnectedBinanceF = true
            }
            
            print("연결성공: \(siteType)")
            
            //틱정보 받아오도록 웹소켓 전송
            writeToSocket(siteType)
            
        case .disconnected( _, _):
            if socketUpbit != nil, siteType == .upbit {
                self.isSocketConnectedUpbit = false
            }
            else if socketBinance != nil, siteType == .binance {
                self.isSocketConnectedBinance = false
            }
            else if socketBinanceF != nil, siteType == .binanceF {
                self.isSocketConnectedBinanceF = false
            }
            
        case .text(let data):
            let data = WSocket(from: siteType, data: JSON.init(parseJSON: data))
            
            //VCPopover뷰 업데이트 하라고 소리쳐~
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "receiveTick"), object: nil, userInfo: ["tick" : data])
            //print("Receive Binance: \(data.marketAndCode) / \(MyValue.myCoin)")
            
        case .binary(let data):
            let data = WSocket(from: siteType, data: JSON(data))
            
            //VCPopover뷰 업데이트 하라고 소리쳐~
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "receiveTick"), object: nil, userInfo: ["tick" : data])
            //print("Receive Upbit: \(data.marketAndCode) / \(MyValue.myCoin)")
            
        case .cancelled:
            if socketUpbit != nil, client.request.url == socketUpbit.request.url {
                self.isSocketConnectedUpbit = false
            }
            else if socketBinance != nil, client.request.url == socketBinance.request.url {
                self.isSocketConnectedBinance = false
            }
            else if socketBinanceF != nil, client.request.url == socketBinanceF.request.url {
                self.isSocketConnectedBinanceF = false
            }
            
        case .error(let error):
            handleError(error)
            
        default:
            print("websocket: unknown event: \(event)")
        }
    }
    
    func handleError(_ error: Error?) {
        if let e = error as? WSError {
            print("websocket encountered an error: \(e.message)")
        }
        else if let e = error {
            print("websocket encountered an error: \(e.localizedDescription)")
        }
        else {
            print("websocket encountered an error")
        }
    }
}

extension VCPopover: NSSearchFieldDelegate {
    func controlTextDidChange(_ notification : Notification){
        guard let field = notification.object as? NSSearchField, field == self.searchField else { return }

        searchText = field.stringValue
        
        collectionViewCoin.reloadData()
    }
}
