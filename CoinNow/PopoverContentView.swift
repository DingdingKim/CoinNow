//
//  PopoverContentView.swift
//  CoinNow
//
//  Created by DingMac on 2017. 7. 15..
//  Copyright © 2017년 DingdingKim. All rights reserved.
//

import Foundation
import Cocoa


class PopoverContentView:NSView {
    var backgroundView:PopoverBackgroundView?
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        if let frameView = self.window?.contentView?.superview {
            if backgroundView == nil {
                backgroundView = PopoverBackgroundView(frame: frameView.bounds)
                backgroundView!.autoresizingMask = NSAutoresizingMaskOptions([.viewWidthSizable, .viewHeightSizable]);
                frameView.addSubview(backgroundView!, positioned: NSWindowOrderingMode.below, relativeTo: frameView)
            }
        }
    }
}

class PopoverBackgroundView:NSView {
    override func draw(_ dirtyRect: NSRect) {
        NSColor.black.withAlphaComponent(0.0).set()
        NSRectFill(self.bounds)
    }
}
