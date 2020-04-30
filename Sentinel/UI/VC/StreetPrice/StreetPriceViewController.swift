//
//  StreetPriceViewController.swift
//  Sentinel
//
//  Created by Farzad Nazifi on 05.06.18.
//  Copyright © 2018 Samourai. All rights reserved.
//

import UIKit

class StreetPriceViewController: UIViewController {
    required init?(coder aDecoder: NSCoder) { fatalError("...") }
    
    let sentinel: Sentinel
    
    @IBOutlet var streetPriceTableView: UITableView!
    
    let exchanges = ["Localbitcoins.com",
                     "Bitfinex"]
    let currencies = [["USD", "EUR", "GBP", "CNY", "RUR"],
                      ["USD"]]
    
    init(sentinel: Sentinel) {
        self.sentinel = sentinel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.streetPriceTableView.tableFooterView = UIView(frame: .zero)
    }
}

extension StreetPriceViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return exchanges.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencies[section].count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return exchanges[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = currencies[indexPath.section][indexPath.row]
        cell.textLabel?.textColor = UIColor.white
        cell.backgroundColor = #colorLiteral(red: 0.1529411765, green: 0.1725490196, blue: 0.2, alpha: 1)
        
        if UserDefaults.standard.string(forKey: "PriceSourceCurrency") == "\(exchanges[indexPath.section]) \(currencies[indexPath.section][indexPath.row])" {
            cell.accessoryType = .checkmark
        }else {
            cell.accessoryType = .none
        }
        return cell
    }
}

extension StreetPriceViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let defaults = UserDefaults.standard
        defaults.set("\(exchanges[indexPath.section]) \(currencies[indexPath.section][indexPath.row])", forKey: "PriceSourceCurrency")
        tableView.reloadData()
        sentinel.update()
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as! UITableViewHeaderFooterView).backgroundView?.backgroundColor = #colorLiteral(red: 0.1333333333, green: 0.1529411765, blue: 0.1764705882, alpha: 1)
        (view as! UITableViewHeaderFooterView).textLabel?.textColor = UIColor.lightGray
        (view as! UITableViewHeaderFooterView).textLabel?.font = UIFont.systemFont(ofSize: 13)
    }
}
