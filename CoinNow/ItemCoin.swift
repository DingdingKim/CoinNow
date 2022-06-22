//
//  ItemCoin.swift
//  CoinNow
//
//  Created by DingMac on 2022/06/21.
//  Copyright © 2022 DingdingKim. All rights reserved.
//

import Cocoa

class ItemCoin: NSCollectionViewItem {
    @IBOutlet weak var btnCoin: NSButton!
    
    var data: Coin! {
        didSet {
            updateView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.wantsLayer = true
    }
    
    func updateView() {
        btnCoin.title = data.marketAndCode
        btnCoin.state = data.isChecked ? .on : .off
    }
    
    @IBAction func clickCheckBox(_ sender: NSButton) {
        let selectedUniqueIds = MyValue.selectedCoins.map { $0.uniqueId }
        
        if sender.state == .on {
            if !selectedUniqueIds.contains(data.uniqueId) {
                MyValue.selectedCoins.append(data)
            }
        }
        else if sender.state == .off {
            for (index, selectedUniqueId) in selectedUniqueIds.enumerated() {
                if selectedUniqueId == data.uniqueId {
                    MyValue.selectedCoins.remove(at: index)
                    break
                }
            }
        }
    }
}
