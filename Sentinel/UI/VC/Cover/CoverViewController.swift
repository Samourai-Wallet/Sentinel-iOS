//
//  CoverViewController.swift
//  Sentinel
//
//  Created by Farzad Nazifi on 6/21/18.
//  Copyright © 2018 Samourai. All rights reserved.
//

import UIKit

class CoverViewController: UIViewController {
    required init?(coder aDecoder: NSCoder) { fatalError("...") }
    
    let bg: UIView!
    
    init(bg: UIView) {
        self.bg = bg
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.addSubview(bg)
        view.sendSubview(toBack: bg)
    }
}
