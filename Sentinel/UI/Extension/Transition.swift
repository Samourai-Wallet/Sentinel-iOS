//
//  Transition.swift
//  Sentinel
//
//  Created by Farzad Nazifi on 01.06.18.
//  Copyright © 2018 Samourai. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func transition(to containerView: UIView? = nil, duration: Double = 0.25, child: UIViewController, completion: ((Bool) -> Void)? = nil) {
        
        let container = ((containerView != nil) ? containerView! : view!)
        
        let current = childViewControllers.last
        addChildViewController(child)
        
        let newView = child.view!
        newView.translatesAutoresizingMaskIntoConstraints = true
        newView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        newView.frame = container.bounds
        
        func add() {
            container.addSubview(newView)
            
            UIView.animate(withDuration: duration, delay: 0, options: [.transitionCrossDissolve], animations: { }, completion: { done in
                child.didMove(toParentViewController: self)
                completion?(done)
            })
        }
        
        if let existing = current {
            if existing == child {
                existing.willMove(toParentViewController: nil)
                
                transition(from: existing, to: child, duration: duration, options: [.transitionCrossDissolve], animations: { }, completion: { done in
                    existing.removeFromParentViewController()
                    child.didMove(toParentViewController: self)
                    completion?(done)
                })
            }else{
                add()
            }
        } else {
            add()
        }
    }
}
