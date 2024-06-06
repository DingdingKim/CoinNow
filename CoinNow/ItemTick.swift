//
//  ItemTick.swift
//  CoinNow
//
//  Created by DingMac on 2022/06/22.
//  Copyright © 2022 DingdingKim. All rights reserved.
//

import Cocoa

class ItemTick: NSCollectionViewItem {
    @IBOutlet weak var lbCoin: NSTextField!
    @IBOutlet weak var lbExchange: NSTextField!
    @IBOutlet weak var lbMarket: NSTextField!
    @IBOutlet weak var lbPrice: NSTextField!
    @IBOutlet weak var lbUpdateTime: NSTextField!
    @IBOutlet weak var lineBottom: NSTextField!
    @IBOutlet weak var constraintsPriceRight: NSLayoutConstraint!
    @IBOutlet weak var btnDelete: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.wantsLayer = true
    }
    
    //Called when coin price data is updated
    func updateView(tick: Tick, index: Int, isLastRow: Bool) {
        lbCoin.stringValue = "\(tick.coin.code)/\(tick.coin.market)"// tick.coin.name
        lbPrice.stringValue = tick.displayCurrentPrice
        lbExchange.stringValue = tick.coin.site.rawValue
        lbMarket.stringValue = "\(tick.coin.code)/\(tick.coin.market)"
        lbUpdateTime.stringValue = tick.displayUpdateTime
        
        lbPrice.textColor = tick.changeState.textColor
        btnDelete.tag = index
    }
    
    @IBAction func clickDelete(_ sender: NSButton) {
        guard sender.tag != -1 else { return }
        
        for (index, coin) in MyValue.selectedCoins.enumerated() {
            if index == sender.tag {
                MyValue.selectedCoins.remove(at: index)
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "VCPopover.updateSelectedCoins"),
                                                object: nil,
                                                userInfo: ["coin": coin, "isAdded": false])
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "VCPopover.updateCollectionViewCoin"),
                                                object: nil,
                                                userInfo: nil)
                break
            }
        }
    }
}
