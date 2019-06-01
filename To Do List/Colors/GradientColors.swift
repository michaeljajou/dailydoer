//
//  GradientColors.swift
//  To Do List
//
//  Created by Michael Jajou on 12/29/18.
//  Copyright © 2018 Apptomistic. All rights reserved.
//

import UIKit

class QuoteGradientView: UIView {
    override open class var layerClass: AnyClass {
        return CAGradientLayer.classForCoder()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let gradientLayer = layer as! CAGradientLayer
        gradientLayer.colors = [UIColor.topQuoteGradient.cgColor, UIColor.bottomQuoteGradient.cgColor]
    }
}
