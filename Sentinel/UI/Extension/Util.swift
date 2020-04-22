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
            let val = abs(btc()*price)
            let formatter = NumberFormatter()
            formatter.maximumFractionDigits = 2
            formatter.numberStyle = .currency
            formatter.currencyCode = currency
            formatter.locale = NSLocale.current
            formatter.negativePrefix = "\(formatter.negativePrefix!) "
            formatter.positivePrefix = "\(formatter.positivePrefix!) "
            guard let result = formatter.string(from: NSNumber(value: val)) else {
                return ("--", "")
            }
            
            if result.split(separator: " ").count > 1 {
                return (String(result.split(separator: " ").last!), String(result.split(separator: " ").first!))
            }

            return (String(result.split(separator: " ").first!.dropFirst()), String(result.split(separator: " ").last!))
        }else{
            let val = abs(btc())
            let formatter = NumberFormatter()
            formatter.maximumFractionDigits = 10
            formatter.minimumIntegerDigits = 1
            formatter.locale = NSLocale.current
            return (formatter.string(from: NSNumber(value: val))!, "BTC")
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

extension UIViewController {
    func alert(title: String, message: String, close: String, action: (()  -> Void)? = nil) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let done = UIAlertAction(title: close, style: .default) { (a) in
            if let action = action {
                action()
            }
        }
        alertVC.addAction(done)
        present(alertVC, animated: true, completion: nil)
    }
}

extension UIBarButtonItem {
    static func menuButton(_ target: Any?, action: Selector, imageName: String) -> UIBarButtonItem {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: imageName), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(target, action: action, for: .touchUpInside)

        let menuBarItem = UIBarButtonItem(customView: button)
        menuBarItem.customView?.translatesAutoresizingMaskIntoConstraints = false
        menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 24).isActive = true
        menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 24).isActive = true

        return menuBarItem
    }
}
