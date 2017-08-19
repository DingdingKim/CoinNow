//
//  ModelSite.swift
//  CoinNow
//
//  Created by DingMac on 2017. 7. 8..
//  Copyright © 2017년 DingdingKim. All rights reserved.
//

import Foundation
import Cocoa

@IBDesignable
class ModelSite: NSView {
    @IBOutlet var view: NSView!
    
    @IBOutlet weak var stackView: NSStackView!
    
    @IBOutlet weak var lbTitle: NSTextField!
    
    @IBOutlet weak var lbBtc: NSTextField!
    @IBOutlet weak var lbEth: NSTextField!
    @IBOutlet weak var lbDash: NSTextField!
    @IBOutlet weak var lbLtc: NSTextField!
    @IBOutlet weak var lbEtc: NSTextField!
    @IBOutlet weak var lbXrp: NSTextField!
    @IBOutlet weak var lbBch: NSTextField!
    
    @IBOutlet weak var lbLine: NSTextField!
    
    var arrLbCoin:[NSTextField] = []
    
    init(frame frameRect: NSRect, title: String) {
        // 뷰를 코드로 생성 할 때 사용되는 생성자
        super.init(frame: frameRect)
        
        Bundle.main.loadNibNamed("ModelSite", owner: self, topLevelObjects: nil)
        self.view.frame = self.bounds
        self.addSubview(self.view)

        arrLbCoin = [lbBtc, lbEth, lbDash, lbLtc, lbEtc, lbXrp, lbBch]
        
        lbTitle.stringValue = title
        
        if(UserDefaults.standard.string(forKey: "AppleInterfaceStyle") ?? "Light" == "Dark") {
            lbLine.backgroundColor = NSColor.white.withAlphaComponent(0.3)
        }
        else {
            lbLine.backgroundColor = NSColor.gray.withAlphaComponent(0.3)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        Bundle.main.loadNibNamed("ModelSite", owner: self, topLevelObjects: nil)
        self.view.frame = self.bounds
        self.addSubview(self.view)
    }
    
    //코인값이 변경되면 호출
    func updateCoinState(arrData: [InfoCoin]) {
        for data in arrData {
            let indexOfCoin = data.coin.getIndex()
            
            arrLbCoin[indexOfCoin].stringValue = (data.currentPrice == 0) ? "-" : data.currentPrice.withCommas()
        }
    }
    
    //전부 로딩으로 바꾸기
    func setLoadingState() {
        lbBtc.stringValue = Const.DEFAULT_LOADING_TEXT
        lbEth.stringValue = Const.DEFAULT_LOADING_TEXT
        lbDash.stringValue = Const.DEFAULT_LOADING_TEXT
        lbLtc.stringValue = Const.DEFAULT_LOADING_TEXT
        lbEtc.stringValue = Const.DEFAULT_LOADING_TEXT
        lbXrp.stringValue = Const.DEFAULT_LOADING_TEXT
        lbBch.stringValue = Const.DEFAULT_LOADING_TEXT
    }
    
    //체크박스 상태가 바뀔때마다 호출
    func setVisibilityLabel(position: Int, isHidden: Bool) {
        arrLbCoin[position].isHidden = isHidden
    }
    
    //For first model
    func hideSeparator() {
        lbLine.isHidden = true
    }
}


