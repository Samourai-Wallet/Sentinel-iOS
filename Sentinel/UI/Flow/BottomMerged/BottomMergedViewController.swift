//
//  BottomMerged.swift
//  Sentinel
//
//  Created by Farzad Nazifi on 02.06.18.
//  Copyright © 2018 Samourai. All rights reserved.
//

import UIKit
import Lottie

class BottomMergedViewController: UIViewController, UIScrollViewDelegate {
    required init?(coder aDecoder: NSCoder) { fatalError("...") }
    
    let sentinel: Sentinel
    let animationView = LOTAnimationView(name: "data")
    let homeFlowViewController: HomeFlowViewController
    
    @IBOutlet var leftContainer: UIView!
    @IBOutlet var rightContainer: UIView!
    @IBOutlet var animationContainer: UIView!
    @IBOutlet var bottomScrollView: UIScrollView!

    init(sentinel: Sentinel, homeFlowViewController: HomeFlowViewController) {
        self.sentinel = sentinel
        self.homeFlowViewController = homeFlowViewController
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.transition(to: leftContainer, duration: 0, child: WalletsViewController(sentinel: sentinel, homeFlowViewController: homeFlowViewController), completion: nil)
        self.transition(to: rightContainer, duration: 0, child: TransactionsViewController(sentinel: sentinel), completion: nil)
        
        animationView.frame = CGRect(x: 0, y: 0, width: 120, height: 44)
        animationContainer.addSubview(animationView)
        animationView.setProgressWithFrame(10)
    }
    
    @IBAction func animationContainerTapped(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: sender.view!)
        
        guard location.x < (sender.view?.frame.width)!/2 else {
            bottomScrollView.setContentOffset(CGPoint(x: bottomScrollView.frame.width, y: 0), animated: true)
            return
        }
        
        bottomScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let progress = scrollView.contentOffset.x / scrollView.frame.width
        var frame = 130
        if progress < 0 {
            frame = 10 - Int(abs(progress)*10)
        }else if progress <= 1 && progress >= 0 {
            frame = 10 + Int(progress*120)
        }else {
            frame = 120 + Int(abs(progress)*10)
        }
        
        if !(frame <= 0 || frame >= 140) {
            animationView.setProgressWithFrame(NSNumber(integerLiteral: frame))
        }
    }
}
