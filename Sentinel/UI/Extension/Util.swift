//
//  Util.swift
//  Sentinel
//
//  Created by Farzad Nazifi on 02.06.18.
//  Copyright © 2018 Samourai. All rights reserved.
//

import UIKit

extension Int {
    func btc() -> Double {
        let result = Double(self) / 100000000
        if !result.isNormal {
            return 0
        }
        return result
    }
    
    func price(isFiatForced: Bool? = nil) -> (String, String) {
        var isFiat = UserDefaults.standard.bool(forKey: "isFiat")
        if isFiatForced != nil {
            isFiat = isFiatForced!
        }
        
        let price = UserDefaults.standard.double(forKey: "Price")
        let currency = String(UserDefaults.standard.string(forKey: "PriceSourceCurrency")!.split(separator: " ").last!)
    
        if isFiat {
            let val = round(100*abs(btc()*price))/100
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = currency
            formatter.locale = NSLocale.current
            formatter.negativePrefix = "\(formatter.negativePrefix!) "
            formatter.positivePrefix = "\(formatter.positivePrefix!) "
            guard let result = formatter.string(from: NSNumber(value: val)) else {
                return ("--", "")
            }
            return (String(result.split(separator: " ").last!), String(result.split(separator: " ").first!))
        }else{
            return ("\(btc())", "BTC")
        }
    }
}

internal typealias Scale = (dx: CGFloat, dy: CGFloat)

internal extension CIImage {
    internal func nonInterpolatedImage(withScale scale: Scale = Scale(dx: 1, dy: 1)) -> UIImage? {
        guard let cgImage = CIContext(options: nil).createCGImage(self, from: self.extent) else { return nil }
        let size = CGSize(width: self.extent.size.width * scale.dx, height: self.extent.size.height * scale.dy)
        
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.interpolationQuality = .none
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.draw(cgImage, in: context.boundingBoxOfClipPath)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return result
    }
}

extension UIDevice {
    struct Device {
        // iDevice detection code
        static let IS_IPAD             = UIDevice.current.userInterfaceIdiom == .pad
        static let IS_IPHONE           = UIDevice.current.userInterfaceIdiom == .phone
        static let IS_RETINA           = UIScreen.main.scale >= 2.0
        
        static let SCREEN_WIDTH        = Int(UIScreen.main.bounds.size.width)
        static let SCREEN_HEIGHT       = Int(UIScreen.main.bounds.size.height)
        static let SCREEN_MAX_LENGTH   = Int( max(SCREEN_WIDTH, SCREEN_HEIGHT) )
        static let SCREEN_MIN_LENGTH   = Int( min(SCREEN_WIDTH, SCREEN_HEIGHT) )
        
        static let IS_IPHONE_4_OR_LESS = IS_IPHONE && SCREEN_MAX_LENGTH  < 568
        static let IS_IPHONE_5         = IS_IPHONE && SCREEN_MAX_LENGTH == 568
        static let IS_IPHONE_6         = IS_IPHONE && SCREEN_MAX_LENGTH == 667
        static let IS_IPHONE_6P        = IS_IPHONE && SCREEN_MAX_LENGTH == 736
        static let IS_IPHONE_X         = IS_IPHONE && SCREEN_MAX_LENGTH == 812
    }
}
