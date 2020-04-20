//
//  NetworkViewController.swift
//  Sentinel
//
//  Created by Gigi on 20.04.20.
//  Copyright © 2020 Samourai. All rights reserved.
//

import UIKit

class NetworkViewController: UIViewController {

    
    @IBOutlet weak var buttonTor: UIButton!
    @IBOutlet weak var buttonRenew: UIButton!
    @IBOutlet weak var labelStatus: UILabel!
    @IBOutlet weak var viewStreetLight: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("Network", comment: "")
        
        torDidStop()
    }
    
    private func torDidConnect() {
        labelStatus.text = NSLocalizedString("Enabled", comment: "")
        viewStreetLight.backgroundColor = UIColor.green
        buttonRenew.isHidden = false
        buttonTor.setTitle(NSLocalizedString("DISABLE", comment: ""), for: .normal)
    }
    
    private func torDidStop() {
        labelStatus.text = NSLocalizedString("Disabled", comment: "")
        viewStreetLight.backgroundColor = UIColor.red
        buttonRenew.isHidden = true
        buttonTor.setTitle(NSLocalizedString("ENABLE", comment: ""), for: .normal)
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
