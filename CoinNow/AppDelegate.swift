//
//  AppDelegate.swift
//  CoinNow
//
//  Created by DingMac on 2017. 7. 2..
//  Copyright © 2017년 DingdingKim. All rights reserved.
//

import Cocoa
import Starscream

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let statusItem = NSStatusBar.system.statusItem(withLength: -1)
    private let popover = NSPopover()
    
    private static var timer = Timer()
    
    private var socket: WebSocket!
    private let server = WebSocketServer()
    var isSocketConnected: Bool = false {
        didSet {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "socketStateChanged"), object: nil, userInfo: ["isConnected" : isSocketConnected])
        }
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("--------applicationDidFinishLaunching")
        MyValue.clear() //For test
        
        initStatusItem()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        print("--------applicationWillTerminate")
        socket.forceDisconnect()
        
        terminateTimer()
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
            initWebSocket()
        }
        else {
            if socket != nil {
                socket.forceDisconnect()
                socket = nil
            }
            
            initUpdatePerTimer()
        }
    }
    
    //Set label that show my coin state at status bar
    @objc public func updateStatusItem() {
        //print("--------updateStatusItem")
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
    
    func initWebSocket() {
        print("--------initWebSocket")
        var request = URLRequest(url: URL(string: Const.WEBSOCKET_UPBIT)!)
        request.timeoutInterval = 5
        
        if socket != nil {
            socket.forceDisconnect()
            socket = nil
        }
        
        socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()
    }
    
    //업비트 웹소켓으로 틱 정보 가져옴
    func writeToSocket() {
        print("--------writeToSocket: \(popover.isShown), \(popover.isDetached)")
        guard socket != nil, isSocketConnected else {
            initWebSocket()
            
            print("연결안됨. 소켓 다시 세팅");
            return
        }
        
        //팝오버가 안보이면 내꺼만 가져오고 보이면 선택코인 다가져와
        var marketAndCodes = popover.isShown ? MyValue.selectedCoins.map { $0.marketAndCode } : []
        
        //상태바 코인도 포함시켜서 요청한다. 같은 코드 두개보내면 응답을 아예 안하기 때문에 확인하고 넣기
        //TODO Set으로 만들면 중복안되고 괜찮을거같은데 검토해보쟈
        if !marketAndCodes.contains(MyValue.myCoin) {
            marketAndCodes.append(MyValue.myCoin)
            print("내 코인도 가져가유~")
        }
        
        let marketAndCodesString = marketAndCodes.joined(separator: "\",\"")
        let param = "[{\"ticket\":\"test\"},{\"type\":\"ticker\",\"codes\":[\"\(marketAndCodesString)\"]}]"
        print("하이: \(param)")
        
        socket.write(string: param) {
            print("전송 완료")
        }
    }
    
    func disconnectSocket() {
        if socket != nil {
            socket.forceDisconnect()
            //socket = nil
            print("디스커넥트")
        }
    }
}

extension AppDelegate: WebSocketDelegate {
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            isSocketConnected = true
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "socketStateChanged"), object: nil, userInfo: ["isConnected" : isSocketConnected])
            
            //틱정보 받아오도록 웹소켓 전송
            writeToSocket()
            
            print("websocket is connected: \(headers)")
            
        case .disconnected(let reason, let code):
            isSocketConnected = false
            print("websocket is disconnected: \(reason) with code: \(code)")
            
        case .binary(let data):
            do {
                let data = try JSONDecoder().decode(WebSocketUpbit.self, from: data)
                //print("리시브: \(data.code)")
                
                //VCPopover뷰 업데이트 하라고 소리쳐~
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "receiveTick"), object: nil, userInfo: ["tick" : data])
                
                //받은게 상태바 코인이면 상태바 업뎃
                if data.code == MyValue.myCoin {
                    updateStatusText(MyValue.isHiddenStatusbarMarket ? data.displayCurrentPrice : "\(MyValue.myCoin.split(separator: "-")[1]) \(data.displayCurrentPrice)")
                }
            } catch {
                print("업비트 웹소켓 데이터 파싱 오류")
            }
            
        case .cancelled:
            isSocketConnected = false
            
        case .error(let error):
            isSocketConnected = false
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
            writeToSocket()
        }
        //타이머 업데이트라면 소켓은 다시 제거한다
        else {
            disconnectSocket()
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
            writeToSocket()
        }
    }
}
