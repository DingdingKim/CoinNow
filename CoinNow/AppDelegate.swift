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
import Network

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let statusItem = NSStatusBar.system.statusItem(withLength: -1)
    let popover = NSPopover()
    
    var timer: Timer?
    
    //상태바 담당 소켓(얘는 앱 실행하는 동안 계속 열려있다(타이머 모드 제외))
    var socketStatusBar: WebSocket!
    
    let server = WebSocketServer()
    
    let monitor = NWPathMonitor()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("--------applicationDidFinishLaunching")
        //MyValue.clear() //For test
        
        initStatusItem()
        
        initNetworkMonitor()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        print("--------applicationWillTerminate")
        
        disconnectSockets()
        
        terminateTimer()
    }
    
    func disconnectSockets() {
        print("--------disconnectSockets")
        
        if socketStatusBar != nil {
            socketStatusBar.forceDisconnect()
            socketStatusBar = nil
        }
    }
    
    //Set item at status bar(toggle popover)
    func initStatusItem() {
        print("--------initStatusItem")
        
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
            initWebSocket()
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
            writeToSocket()
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
        statusItem.button?.title = text
    }
    
    //set timer sec that for update status bar title
    // default: realtime(websocket)
    func initUpdatePerTimer() {
        print("--------setTimerSec")
        terminateTimer()
        
        //0초에 실행되는 효과
        updateStatusItem()
        
        print("setTimerSec : Timer!")
        timer = Timer.scheduledTimer(timeInterval: MyValue.updatePer.sec,
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
        timer?.invalidate()
        timer = nil
    }
    
    func initWebSocket() {
        print("--------initWebSocket: \(MyValue.mySiteType)")
        
        var request = URLRequest(url: URL(string: MyValue.mySiteType == .upbit ? Const.WEBSOCKET_UPBIT : Const.WEBSOCKET_BINANCE)!)
        request.timeoutInterval = 5
        
        disconnectSockets()
        
        socketStatusBar = WebSocket(request: request)
        socketStatusBar.delegate = self
        socketStatusBar.connect()
    }
    
    func unSubscribeBinance(marketAndCode: String) {
        print("--------unSubscribeBinance: \(MyValue.mySiteType)")
        
        let splited = marketAndCode.split(separator: "-")
        let symbol = String(splited[1]) + String(splited[0])
        let param = "{\"method\": \"UNSUBSCRIBE\",\"params\":[\"\(symbol.lowercased())@ticker\"],\"id\": 1}"
        print("구독 해제: \(param)")

        socketStatusBar.write(string: param) {
            print("unSubscribeBinance 완료")
        }
    }
    
    //웹소켓으로 틱 정보 가져옴
    func writeToSocket() {
        guard let socketStatusBar = socketStatusBar else {
            print("연결안됨. 상태바 소켓 다시 세팅")
            
            initWebSocket()
            return
        }
        
        var param = ""
        
        if MyValue.mySiteType == .upbit {
            param = "[{\"ticket\":\"test\"},{\"type\":\"ticker\",\"codes\":[\"\(MyValue.myCoin)\"]}]"
        }
        else if MyValue.mySiteType == .binance {
            let splited = MyValue.myCoin.split(separator: "-")
            let symbol = String(splited[1]) + String(splited[0])
            
            param = "{\"method\": \"SUBSCRIBE\",\"params\":[\"\(symbol)@ticker\"],\"id\": 1}"
            
        }
        print("writeToSocket 상태바: \(param)")
        
        socketStatusBar.write(string: param) {
            print("writeToSocket 완료")
        }
    }
    
    func initNetworkMonitor() {
        let queue = DispatchQueue(label: "Network Monitor")
        
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { path in
            print("✅ Connection status: \(path.status == .satisfied)")
            
            let isConnected = path.status == .satisfied
            
            DispatchQueue.main.async {
                if isConnected {
                    self.initStatusItem()
                }
                else {
                    self.updateStatusText("Disconnected")
                }
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateConnectionStatus"),
                                                object: nil,
                                                userInfo: ["isConnected" : isConnected])
            }
        }
    }
}

extension AppDelegate: WebSocketDelegate {
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected( _):
            print("연결 성공: \(MyValue.mySiteType)")

            //틱정보 받아오도록 웹소켓 전송
            writeToSocket()

        case .disconnected( _, _):
            print("연결 끊어짐: \(MyValue.mySiteType)")

        case .text(let data):
            let data = WSocket(from: MyValue.mySiteType, data: JSON.init(parseJSON: data))

            print("Receive Binance: \(data.marketAndCode) / \(MyValue.myCoin)")
            
            //받은게 상태바 코인이면 상태바 업뎃
            if data.marketAndCode == MyValue.myCoin {
                updateStatusText(MyValue.isHiddenStatusbarMarket ?
                                    data.displayCurrentPrice : "\(MyValue.myCoin.split(separator: "-")[1]) \(data.displayCurrentPrice)")
            }

        case .binary(let data):
            let data = WSocket(from: MyValue.mySiteType, data: JSON(data))

            print("Receive Upbit: \(data.marketAndCode) / \(MyValue.myCoin)")
            if data.marketAndCode == MyValue.myCoin {
                updateStatusText(MyValue.isHiddenStatusbarMarket ?
                                    data.displayCurrentPrice : "\(MyValue.myCoin.split(separator: "-")[1]) \(data.displayCurrentPrice)")
            }

        case .cancelled:
            print("연결 취소됨")

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
