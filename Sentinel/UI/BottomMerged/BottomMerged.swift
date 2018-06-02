//
//  BottomMerged.swift
//  Sentinel
//
//  Created by Farzad Nazifi on 02.06.18.
//  Copyright © 2018 Samourai. All rights reserved.
//

import UIKit

class BottomMergedViewController: UIViewController {
    @IBOutlet var leftContainer: UIView!
    @IBOutlet var rightContainer: UIView!
    required init?(coder aDecoder: NSCoder) { fatalError("...") }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.transition(to: leftContainer, duration: 0, child: WalletsViewController(), completion: nil)
        self.transition(to: rightContainer, duration: 0, child: TransactionsViewController(), completion: nil)
    }
}
