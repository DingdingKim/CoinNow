//
//  ModelMarket.swift
//  CoinNow
//
//  Created by DingMac on 2017. 7. 8..
//  Copyright © 2017년 DingdingKim. All rights reserved.
//

import Foundation
import Cocoa

@IBDesignable
class ModelMarket: NSView {
    @IBOutlet var view: NSView!
    
    @IBOutlet weak var stackViewCoins: NSStackView! //Root view of coin textfield
    @IBOutlet weak var lbTitle: NSTextField! //Market name
    @IBOutlet weak var lbLine: NSTextField! // Seperator
    
    init(frame frameRect: NSRect, title: String) {
        super.init(frame: frameRect)

        initView()
        
        lbTitle.stringValue = title
        
        if UserDefaults.standard.string(forKey: "AppleInterfaceStyle") ?? "Light" == "Dark" {
            lbLine.backgroundColor = NSColor.white.withAlphaComponent(0.3)
        }
        else {
            lbLine.backgroundColor = NSColor.gray.withAlphaComponent(0.3)
        }
    }
    
    required init?(coder: NSCoder) {
        //View created by xib
        super.init(coder: coder)

        initView()
    }
    
    func initView() {
        Bundle.main.loadNibNamed("ModelMarket", owner: self, topLevelObjects: nil)
        self.view.frame = self.bounds
        self.addSubview(self.view)
    }
    
    //Called when coin price data is updated
    func updateCoinState(arrData: [InfoCoin]) {
        for data in arrData {
            let indexOfCoin = data.coin.index()
            
            if let lbCoin = stackViewCoins.arrangedSubviews[indexOfCoin] as? NSTextField {
                switch data.currentPrice {
                case CoinPrice.fail.rawValue:
                    lbCoin.stringValue = CoinPrice.fail.text() //"fail"
                case CoinPrice.noValue.rawValue:
                    lbCoin.stringValue = CoinPrice.noValue.text() //"-"
                default:
                   lbCoin.stringValue =  data.currentPrice.withCommas()
                }
            }
        }
    }
    
    //Called when change state of checkbox
    func setVisibilityLabel(position: Int, isHidden: Bool) {
        if let lbCoin = stackViewCoins.arrangedSubviews[position] as? NSTextField {
            lbCoin.isHidden = isHidden
        }
    }
    
    //For first model
    func hideSeparator() {
        lbLine.isHidden = true
    }
}


