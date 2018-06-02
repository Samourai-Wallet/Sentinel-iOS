//
//  Font.swift
//  Sentinel
//
//  Created by Farzad Nazifi on 01.06.18.
//  Copyright © 2018 Samourai. All rights reserved.
//

import UIKit

extension UIFont {
    static func roboto(weight: UIFont.Weight? = .regular, size: CGFloat) -> UIFont {
        switch weight {
        case UIFont.Weight.black:
            return UIFont(name: "Roboto-Black", size: size)!
        case UIFont.Weight.bold:
            return UIFont(name: "Roboto-Bold", size: size)!
        case UIFont.Weight.medium:
            return UIFont(name: "Roboto-Medium", size: size)!
        case UIFont.Weight.heavy:
            return UIFont(name: "RobotoMono-Regular", size: size)!
        default:
            return UIFont(name: "Roboto-Regular", size: size)!
        }
    }
}
