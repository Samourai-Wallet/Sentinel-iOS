//
//  SettingsViewController.swift
//  Sentinel
//
//  Created by Farzad Nazifi on 04.06.18.
//  Copyright © 2018 Samourai. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    required init?(coder aDecoder: NSCoder) { fatalError("...") }
    
    @IBOutlet var settingsTableView: UITableView!

    var data = ["Stree price source",
                ""]
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        
    }
    
    
    
    
    
}

//extension SettingsViewController: UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! WalletsTableViewCell
//        cell.setData(wallet: sentinel.wallet(forRow: indexPath.row))
//        return cell
//    }
//}
