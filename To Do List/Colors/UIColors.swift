//
//  UIColors.swift
//  To Do List
//
//  Created by Michael Jajou on 12/28/18.
//  Copyright © 2018 Apptomistic. All rights reserved.
//

import UIKit

import UIKit

extension UIColor {
    
    static let tealBlue = UIColor(rgb: 0x36BDD3)
    static let orangeTint = UIColor(rgb: 0xFFB022)
    static let hotPink = UIColor(rgb: 0xED5499)
    static let coolGreen = UIColor(rgb: 0x58ED59)
    static let cellShadowColor = UIColor(rgb: 0x534E48)
    static let completeItemBG = UIColor(rgb: 0x56AEFC)
    static let topQuoteGradient = UIColor(rgb: 0xFE629A)
    static let bottomQuoteGradient = UIColor(rgb: 0xFF8383)
    static let addItemBG = UIColor(rgb: 0xEDEDF2)
    
    static let progressLeft = UIColor(rgb: 0x0dac3f)
    static let progressRight = UIColor(rgb: 0x44d749)
    
    static let trashRed = UIColor(rgb: 0xe73131)
    
    static let addItemColor = UIColor(rgb: 0x39CE47)
    
    convenience init(red: Int, green: Int, blue: Int, a: CGFloat = 1.0) {
        
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: a
        )
        
        
    }
    
    convenience init(rgb: Int, a: CGFloat = 1.0) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF,
            a: a
        )
    }
    
    static func rgb(r: CGFloat, g: CGFloat, b: CGFloat) -> UIColor {
        return UIColor(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
    
}
