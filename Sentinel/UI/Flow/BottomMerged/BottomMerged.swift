//
//  BottomMerged.swift
//  Sentinel
//
//  Created by Farzad Nazifi on 02.06.18.
//  Copyright © 2018 Samourai. All rights reserved.
//

import UIKit

class BottomMergedViewController: UIViewController {
    required init?(coder aDecoder: NSCoder) { fatalError("...") }

    let sentinel: Sentinel
    let homeFlowViewController: HomeFlowViewController
    @IBOutlet var leftContainer: UIView!
    @IBOutlet var rightContainer: UIView!
    
    init(sentinel: Sentinel, homeFlowViewController: HomeFlowViewController) {
        self.sentinel = sentinel
        self.homeFlowViewController = homeFlowViewController
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.transition(to: leftContainer, duration: 0, child: WalletsViewController(sentinel: sentinel, homeFlowViewController: homeFlowViewController), completion: nil)
        self.transition(to: rightContainer, duration: 0, child: TransactionsViewController(sentinel: sentinel), completion: nil)
    }
}
