//
//  WalletsViewController.swift
//  Sentinel
//
//  Created by Farzad Nazifi on 02.06.18.
//  Copyright © 2018 Samourai. All rights reserved.
//

import UIKit

class WalletsViewController: UIViewController {
    @IBOutlet var walletsTableView: UITableView!

    required init?(coder aDecoder: NSCoder) { fatalError("...") }

    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.walletsTableView.register(UINib(nibName: "WalletsTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
    }
}

extension WalletsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! WalletsTableViewCell
//        cell.setData()
        return cell
    }
    
    
}
