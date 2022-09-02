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
    @IBOutlet weak var lineRight: NSTextField!
    
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
        
        //lineRight.isHidden = index % 2 != 0
        //lineBottom.isHidden = isLastRow
        
        lineRight.isHidden = true
        //lineBottom.isHidden = true
    }
}
