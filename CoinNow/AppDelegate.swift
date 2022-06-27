//
//  AppDelegate.swift
//  CoinNow
//
//  Created by DingMac on 2017. 7. 2..
//  Copyright © 2017년 DingdingKim. All rights reserved.
//

import Cocoa
import Starscream
import SwiftyJSON

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let statusItem = NSStatusBar.system.statusItem(withLength: -1)
    private let popover = NSPopover()
    
    private static var timer = Timer()
    
    private var socketUpbit: WebSocket!
    private var socketBinance: WebSocket!
    
    private let server = WebSocketServer()
    
    var isSocketConnectedUpbit: Bool = false {
        didSet {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "socketStateChanged"), object: nil, userInfo: ["isConnected" : isSocketConnectedUpbit, "siteType": SiteType.upbit])
        }
    }
    
    var isSocketConnectedBinance: Bool = false {
        didSet {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "socketStateChanged"), object: nil, userInfo: ["isConnected" : isSocketConnectedBinance, "siteType": SiteType.binance])
        }
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("--------applicationDidFinishLaunching")
        //MyValue.clear() //For test
        
        initStatusItem()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        print("--------applicationWillTerminate")
        disconnectSockets()
        
        terminateTimer()
    }
    
    func disconnectSockets(_ siteType: SiteType? = nil) {
        print("--------disconnectSockets")
        
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
        }
        else {
            if socketUpbit != nil {
                socketUpbit.forceDisconnect()
            }
            
            if socketBinance != nil {
                socketBinance.forceDisconnect()
            }
        }
    }
    
    //Set item at status bar(toggle popover)
    func initStatusItem() {
        print("--------initStatusItem")
        popover.delegate = self
        popover.behavior = .transient//close popover when click outside
        
        statusItem.button?.action = #selector(AppDelegate.togglePopover(_:))
        statusItem.button?.imagePosition = .imageLeft
        statusItem.button?.image = MyValue.isHiddenStatusbarIcon ? nil : NSImage(named: "statusbar_icon")
        
        popover.contentViewController = VCPopover(nibName: "VCPopover", bundle: nil)
        
        updateStatusText("Loading..")
        updateUpdatePer()
    }

    @objc public func updateUpdatePer() {
        print("--------updateUpdatePer")
        
        if MyValue.updatePer == .realTime {
            initWebSocket(MyValue.mySiteType)
        }
        else {
            disconnectSockets()
            
            initUpdatePerTimer()
        }
    }
    
    //Set label that show my coin state at status bar
    @objc public func updateStatusItem() {
        print("--------updateStatusItem")
        statusItem.button?.image = MyValue.isHiddenStatusbarIcon ? nil : NSImage(named: "statusbar_icon")
        
        guard !MyValue.myCoin.isEmpty else { return }
        
        //내 코인을 포함시켜야하니까 다시 write
        if MyValue.updatePer == .realTime {
            writeToSocket(MyValue.mySiteType)
        }
        else {
            Api.getMyCoinTick(marketAndCode: MyValue.myCoin, complete: { isSuccess, price in
                guard let price = price else {
                    self.updateStatusText("Update fail")
                    return
                }
                
                self.updateStatusText(MyValue.isHiddenStatusbarMarket ? price : "\(MyValue.myCoin.split(separator: "-")[1]) \(price)")
            })
        }
    }
    
    public func updateStatusText(_ text: String) {
        self.statusItem.button?.title = text
    }
    
    //set timer sec that for update status bar title
    // default: realtime(websocket)
    func initUpdatePerTimer() {
        print("--------setTimerSec")
        terminateTimer()
        
        //0초에 실행되는 효과
        updateStatusItem()
        
        debugPrint("setTimerSec : Timer!")
        AppDelegate.timer = Timer.scheduledTimer(timeInterval: MyValue.updatePer.sec,
                                                 target: self,
                                                 selector: #selector(updateStatusItem),
                                                 userInfo: nil,
                                                 repeats: true)
    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
        print("--------togglePopover")
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
        print("--------terminateTimer")
        AppDelegate.timer.invalidate()
    }
    
    //TODO 생긴게 맘에 안든다
    func initWebSocket(_ siteType: SiteType? = nil) {
        print("--------initWebSocket")
        
        if let siteType = siteType {
            if siteType == .upbit {
                var request = URLRequest(url: URL(string: Const.WEBSOCKET_UPBIT)!)
                request.timeoutInterval = 5
                
                disconnectSockets(.upbit)
                
                socketUpbit = WebSocket(request: request)
                socketUpbit.delegate = self
                socketUpbit.connect()
            }
            else if siteType == .binance {
                var request = URLRequest(url: URL(string: Const.WEBSOCKET_BINANCE)!)
                request.timeoutInterval = 5
                
                disconnectSockets(.binance)
                
                socketBinance = WebSocket(request: request)
                socketBinance.delegate = self
                socketBinance.connect()
            }
        }
        else {
            var requestUpbit = URLRequest(url: URL(string: Const.WEBSOCKET_UPBIT)!)
            requestUpbit.timeoutInterval = 5
            
            disconnectSockets(.upbit)
            
            socketUpbit = WebSocket(request: requestUpbit)
            socketUpbit.delegate = self
            socketUpbit.connect()
            
            var requestBinance = URLRequest(url: URL(string: Const.WEBSOCKET_BINANCE)!)
            requestBinance.timeoutInterval = 5
            
            disconnectSockets(.binance)
            
            socketBinance = WebSocket(request: requestBinance)
            socketBinance.delegate = self
            socketBinance.connect()
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
            var marketAndCodes = popover.isShown ? MyValue.selectedCoins.filter({ $0.site == .upbit })
                                                                        .map { $0.marketAndCode } : []
            
            //상태바 코인도 포함시켜서 요청한다. 같은 코드 두개보내면 응답을 아예 안하기 때문에 확인하고 넣기
            //TODO Set으로 만들면 중복안되고 괜찮을거같은데 검토해보쟈
            if MyValue.mySiteType == .upbit, !marketAndCodes.contains(MyValue.myCoin) {
                marketAndCodes.append(MyValue.myCoin)
            }
            
            let marketAndCodesString = marketAndCodes.joined(separator: "\",\"")
            let param = "[{\"ticket\":\"test\"},{\"type\":\"ticker\",\"codes\":[\"\(marketAndCodesString)\"]}]"
            print("하이 업빗: \(param)")
            
            socketUpbit.write(string: param) {
                print("업빗 전송 완료")
            }
        }
        
        if siteType == .binance {
            guard socketBinance != nil, isSocketConnectedBinance else {
                initWebSocket(.binance)
                
                print("연결안됨. 바낸 소켓 다시 세팅");
                return
            }
            
            //팝오버가 안보이면 내꺼만 가져오고 보이면 선택코인 다가져와
            var marketAndCodes = popover.isShown ? MyValue.selectedCoins.filter({ $0.site == .binance })
                                                                        .map {
                                                                            return $0.code + $0.market + "@ticker"
                                                                        } : []
            
            //상태바 코인도 포함시켜서 요청한다. 같은 코드 두개보내면 응답을 아예 안하기 때문에 확인하고 넣기
            //TODO Set으로 만들면 중복안되고 괜찮을거같은데 검토해보쟈
            if MyValue.mySiteType == .binance, !marketAndCodes.contains(MyValue.myCoin) {
                marketAndCodes.append(MyValue.myCoin)
            }
            //wss://stream.binance.com:9443/ws/btcusdt@ticker/etcusdt@ticker
            
            let marketAndCodesString = marketAndCodes.joined(separator: "\",\"")
            let param = "{\"method\": \"SUBSCRIBE\",\"params\":[\"\(marketAndCodesString.lowercased())\"],\"id\": 1}"
            print("하이 바낸: \(param)")
            //{"method": "SUBSCRIBE","params":["etcusdt@ticker", "btcusdt@ticker"],"id": 312}
            
            socketBinance.write(string: param) {
                print("바낸 전송 완료")
            }
        }
    }
}

extension AppDelegate: WebSocketDelegate {
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        let siteType: SiteType = (client.request.url == socketUpbit.request.url) ? .upbit : .binance
        
        switch event {
        case .connected( _):
            if socketUpbit != nil, siteType == .upbit {
                self.isSocketConnectedUpbit = true
            }
            else if socketBinance != nil, siteType == .binance {
                self.isSocketConnectedBinance = true
            }
            
            //틱정보 받아오도록 웹소켓 전송
            writeToSocket(siteType)
            
        case .disconnected( _, _):
            if socketUpbit != nil, siteType == .upbit {
                self.isSocketConnectedUpbit = false
            }
            else if socketBinance != nil, siteType == .binance {
                self.isSocketConnectedBinance = false
            }
            
        case .text(let data):
            let data = WSocket(from: siteType, data: JSON.init(parseJSON: data))
            
            //VCPopover뷰 업데이트 하라고 소리쳐~
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "receiveTick"), object: nil, userInfo: ["tick" : data])
            
            //받은게 상태바 코인이면 상태바 업뎃
            if data.code == MyValue.myCoin {
                updateStatusText(MyValue.isHiddenStatusbarMarket ? data.displayCurrentPrice : "\(MyValue.myCoin.split(separator: "-")[1]) \(data.displayCurrentPrice)")
            }
            
        case .binary(let data):
            let data = WSocket(from: siteType, data: JSON(data))
            
            //VCPopover뷰 업데이트 하라고 소리쳐~
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "receiveTick"), object: nil, userInfo: ["tick" : data])
            
            //받은게 상태바 코인이면 상태바 업뎃
            if data.code == MyValue.myCoin {
                updateStatusText(MyValue.isHiddenStatusbarMarket ? data.displayCurrentPrice : "\(MyValue.myCoin.split(separator: "-")[1]) \(data.displayCurrentPrice)")
            }
            
        case .cancelled:
            if socketUpbit != nil, client.request.url == socketUpbit.request.url {
                self.isSocketConnectedUpbit = false
            }
            else if socketBinance != nil, client.request.url == socketBinance.request.url {
                self.isSocketConnectedBinance = false
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
        } else if let e = error {
            print("websocket encountered an error: \(e.localizedDescription)")
        } else {
            print("websocket encountered an error")
        }
    }
}

extension AppDelegate: NSPopoverDelegate {
    func popoverDidClose(_ notification: Notification) {
        print("popoverDidClose: \(popover.isShown)")
        
        //소켓이면 내꺼만 가지고 오게 다시 쓰기
        if MyValue.updatePer == .realTime {
            writeToSocket(MyValue.mySiteType)
        }
        //타이머 업데이트라면 소켓은 다시 제거한다
        else {
            disconnectSockets()
        }
    }
    
    func popoverDidShow(_ notification: Notification) {
        //소켓이 아니었다면(타이머) 소켓을 다시 만들고 연결한다
        if MyValue.updatePer != .realTime {
            print("**********popoverDidShow: ==== realtime")
            
            initWebSocket()
        }
        //소켓이었다면 선택된 코인들의 정보도 받을 수 있게(평소에는 내 코인 하나만 가져왔으니까) write
        else {
            print("**********popoverDidShow: ==== realtime이 아니다")
            
            //둘 다
            writeToSocket(.upbit)
            writeToSocket(.binance)
        }
    }
}
