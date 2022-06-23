//
//  HeaderCoin.swift
//  CoinNow
//
//  Created by DingMac on 2022/06/23.
//  Copyright © 2022 DingdingKim. All rights reserved.
//

import Cocoa

class HeaderCoin: NSView {
    @IBOutlet weak var lbMarket: NSTextField!
 
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.3).cgColor
    }
    
    func updateView(data: (market: String, coins: [Coin])) {
        lbMarket.stringValue = data.market
    }
}
