//
//  UIColor+Helpers.swift
//  Clocknator
//
//  Created by Paulo Mattos on 18/03/19.
//  Copyright © 2019 Paulo Mattos. All rights reserved.
//

import UIKit

extension UIColor {
    
    /// Creates `UIColor` using integer components.
    convenience init(red: UInt, green: UInt, blue: UInt, alpha: CGFloat = 1.0) {
        precondition(red <= 255 && green <= 255 && blue <= 255)
        precondition(alpha >= 0 && alpha <= 1.0)
        
        self.init(
            red: CGFloat(red)/255,
            green: CGFloat(green)/255,
            blue: CGFloat(blue)/255,
            alpha: alpha
        )
    }
}
