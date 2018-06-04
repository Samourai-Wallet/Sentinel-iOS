//
//  WalletsViewController.swift
//  Sentinel
//
//  Created by Farzad Nazifi on 02.06.18.
//  Copyright © 2018 Samourai. All rights reserved.
//

import UIKit
import RealmSwift

class WalletsViewController: UIViewController {
    required init?(coder aDecoder: NSCoder) { fatalError("...") }
    
    let sentinel: Sentinel
    var notificationToken: NotificationToken? = nil
    @IBOutlet var walletsTableView: UITableView!
    @IBOutlet var noaddr: UILabel!

    init(sentinel: Sentinel, homeFlowViewController: HomeFlowViewController) {
        self.sentinel = sentinel
        super.init(nibName: nil, bundle: nil)
        homeFlowViewController.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.walletsTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 34, right: 0)

        notificationToken = sentinel.realm.objects(Wallet.self).observe({ (change) in
            self.walletsTableView.reloadData()
        })
        
        self.walletsTableView.register(UINib(nibName: "WalletsTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        self.walletsTableView.tableFooterView = UIView(frame: .zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selected = walletsTableView.indexPathForSelectedRow {
            self.walletsTableView.deselectRow(at: selected, animated: true)
        }
    }
}

extension WalletsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = sentinel.numberOfWallets
        if count == 0 {
            noaddr.isHidden = false
        }else{
            noaddr.isHidden = true
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! WalletsTableViewCell
        cell.setData(wallet: sentinel.wallet(forRow: indexPath.row))
        return cell
    }
}

extension WalletsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let qr = UIAlertAction(title: "Show QR", style: .default) { (action) in
                // when cancel is tapped
            }
            alertController.addAction(qr)
            
            let cancelAction = UIAlertAction(title: "Rename", style: .default) { (action) in
                // when cancel is tapped
            }
            alertController.addAction(cancelAction)
            
            let destroyAction = UIAlertAction(title: "Remove", style: .destructive) { (action) in
                // when destroy is tapped
            }
            alertController.addAction(destroyAction)
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                // when destroy is tapped
            }
            alertController.addAction(cancel)
            
            present(alertController, animated: true)
        }else{
            let wallet = WalletViewController(sentinel: sentinel, wallet: sentinel.wallet(forRow: indexPath.row))
            self.navigationController?.pushViewController(wallet, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
}

extension WalletsViewController: HomeFlowDelegate {
    func editStateChanged(isEditing: Bool) {
        self.walletsTableView.setEditing(isEditing, animated: true)
    }
}
