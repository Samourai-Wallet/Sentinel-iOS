//
//  SettingsViewController.swift
//  Sentinel
//
//  Created by Farzad Nazifi on 04.06.18.
//  Copyright © 2018 Samourai. All rights reserved.
//

import UIKit
import Locksmith

class SettingsViewController: UIViewController {
    required init?(coder aDecoder: NSCoder) { fatalError("...") }
    
    let sentinel: Sentinel
    @IBOutlet var settingsTableView: UITableView!
    
    var data: [(String, UIViewController?)] {
        var items: [(String, UIViewController?)] = [(NSLocalizedString("Street Price", comment: ""), StreetPriceViewController(sentinel: sentinel)),
                                                    (NSLocalizedString("Import Watchlist", comment: ""), ImportViewController(sentinel: sentinel)),
                                                    (NSLocalizedString("Export Watchlist", comment: ""), ExportViewController(sentinel: sentinel)),
                                                    (NSLocalizedString("Push Transaction", comment: ""), PushTXViewController(sentinel: sentinel)),
                                                    (NSLocalizedString("Set pincode", comment: ""), PincodeViewController(mode: .set)),
                                                    (NSLocalizedString("Enable Tor", comment: ""), NetworkViewController())]
        
        guard let dictionary = Locksmith.loadDataForUserAccount(userAccount: "account") else { return items }
        guard (dictionary["pinCodeHash"] as? String) != nil else { return items }
        
        items = Array(items.dropLast())
        items.append((NSLocalizedString("Remove pincode", comment: ""), PincodeViewController(mode: .remove)))
        items.append((NSLocalizedString("Scramble pincode", comment: ""), nil))
        
        return items
    }
    
    init(sentinel: Sentinel) {
        self.sentinel = sentinel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.settingsTableView.tableFooterView = UIView(frame: .zero)
        self.title = NSLocalizedString("Settings", comment: "")
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        navigationController?.navigationBar.tintColor = .white
        let close = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""), style: UIBarButtonItemStyle.plain, target: self, action: #selector(dissmiss))
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
    
    var sw: UISwitch {
        let sw = UISwitch()
        sw.isOn = UserDefaults.standard.bool(forKey: "isScrambled")
        sw.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        return sw
    }
    
    @objc func switchChanged(mySwitch: UISwitch) {
        UserDefaults.standard.set(mySwitch.isOn, forKey: "isScrambled")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = data[indexPath.row].0
        cell.textLabel?.textColor = UIColor.white
        cell.backgroundColor = #colorLiteral(red: 0.1529411765, green: 0.1725490196, blue: 0.2, alpha: 1)
        if indexPath.row == 0 {
            cell.detailTextLabel?.text = UserDefaults.standard.string(forKey: "PriceSourceCurrency")!
        }else{
            cell.detailTextLabel?.text = nil
        }
        
        if indexPath.row == 4 {
            cell.selectionStyle = .none
            cell.accessoryView = sw
        }else{
            cell.selectionStyle = .default
            cell.accessoryView = nil
        }
        return cell
    }
}

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = data[indexPath.row].1 else { return }
        show(vc, sender: self)
    }
}
