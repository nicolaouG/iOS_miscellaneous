//
//  RelativePixel.swift
//  TestProject
//
//  Created by george on 04/06/2020.
//  Copyright © 2020 George Nicolaou. All rights reserved.
//

import UIKit

public enum rp {
    case height, width, generic
    
    var baselineSize: CGSize {
        CGSize(width: 320, height: 568) /// iphone SE
    }
    
    var currentDeviceSize: CGSize {
        UIScreen.main.bounds.size
    }
    
    var hMultiplier: CGFloat {
        currentDeviceSize.height / baselineSize.height
    }
    
    var wMultiplier: CGFloat {
        currentDeviceSize.width / baselineSize.width
    }
    
    var gMultiplier: CGFloat {
        hMultiplier * wMultiplier
    }
    
    
    func value(of num: CGFloat) -> CGFloat {
        switch self {
        case .generic:
            return gMultiplier * num
        case .height:
            return hMultiplier * num
        case .width:
            return wMultiplier * num
        }
    }
}
