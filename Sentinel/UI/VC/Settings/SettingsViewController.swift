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
    
    let sentinel: Sentinel
    @IBOutlet var settingsTableView: UITableView!
    
    let data = ["Street pricee",
                "Import wallet",
                "Export wallet"]
    
    init(sentinel: Sentinel) {
        self.sentinel = sentinel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.settingsTableView.tableFooterView = UIView(frame: .zero)
        self.title = "Settings"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        navigationController?.navigationBar.tintColor = .white
        let close = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dissmiss))
        self.navigationItem.leftBarButtonItems = [close]
        
        guard (UserDefaults.standard.string(forKey: "PriceSourceCurrency") != nil) else {
            let defaults = UserDefaults.standard
            defaults.set("Localbitcoins.com USD", forKey: "PriceSourceCurrency")
            return
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        settingsTableView.reloadData()
        
        if let selected = settingsTableView.indexPathForSelectedRow {
            self.settingsTableView.deselectRow(at: selected, animated: true)
        }
    }
    
    @objc func dissmiss() {
        dismiss(animated: true, completion: nil)
    }
}

extension SettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = data[indexPath.row]
        cell.textLabel?.textColor = UIColor.white
        cell.backgroundColor = #colorLiteral(red: 0.1529411765, green: 0.1725490196, blue: 0.2, alpha: 1)
        
        if indexPath.row == 0 {
            cell.detailTextLabel?.text = UserDefaults.standard.string(forKey: "PriceSourceCurrency")!
        }else{
            cell.detailTextLabel?.text = nil
        }
        return cell
    }
}

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let streetPriceVC = StreetPriceViewController(sentinel: sentinel)
            show(streetPriceVC, sender: self)
        } else if indexPath.row == 1 {
            let importVC = ImportViewController(sentinel: sentinel)
            show(importVC, sender: self)
        } else if indexPath.row == 2 {
            let importVC = ExportViewController(sentinel: sentinel)
            show(importVC, sender: self)
        }
    }
}
