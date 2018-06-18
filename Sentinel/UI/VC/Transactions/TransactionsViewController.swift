//
//  TransactionsViewController.swift
//  Sentinel
//
//  Created by Farzad Nazifi on 01.06.18.
//  Copyright © 2018 Samourai. All rights reserved.
//

import UIKit
import RealmSwift

class TransactionsViewController: UIViewController {
    required init?(coder aDecoder: NSCoder) { fatalError("...") }
    
    let sentinel: Sentinel
    var wallet: Wallet?
    var notificationToken: NotificationToken? = nil
    var data: [String: [WalletTransaction]] = [:]
    var keys: [String] = []
    
    @IBOutlet var notrx: UILabel!
    @IBOutlet var transactionsTableView: UITableView!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.update), for: UIControlEvents.valueChanged)
        refreshControl.tintColor = .white
        return refreshControl
    }()
    
    init(sentinel: Sentinel, wallet: Wallet? = nil) {
        self.sentinel = sentinel
        self.wallet = wallet
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.transactionsTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 110, right: 0)
        
        self.transactionsTableView.contentOffset = CGPoint(x: 0, y: -50)
        notificationToken = sentinel.realm.objects(WalletTransaction.self).observe({ (change) in
            self.loadItems(wallet: self.wallet)
        })
        
        self.transactionsTableView.register(UINib(nibName: "TransactionTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        self.transactionsTableView.tableFooterView = UIView(frame: .zero)
        self.transactionsTableView.refreshControl = refreshControl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let selected = transactionsTableView.indexPathForSelectedRow else {
            return
        }
        
        self.transactionsTableView.deselectRow(at: selected, animated: true)
    }
    
    func loadItems(wallet: Wallet?) {
        var transactions: Results<WalletTransaction>
        if let wallet = wallet {
            transactions = sentinel.realm.objects(WalletTransaction.self).filter("wallet == %@", wallet).sorted(byKeyPath: "time", ascending: true)
        } else {
            transactions = sentinel.realm.objects(WalletTransaction.self).sorted(byKeyPath: "time", ascending: true)
        }        
        
        var items: [String: [WalletTransaction]] = [:]
        
        transactions.forEach { (transaction) in
            let date = Date(timeIntervalSince1970: TimeInterval(transaction.time))
            let df = DateFormatter()
            df.dateFormat = "MM-dd-yyyy"
            let dateString = df.string(from: date)
            if (items[dateString] != nil) {
                items[dateString]!.append(transaction)
            }else{
                items[dateString] = [transaction]
            }
        }
        
        self.data = items
        
        let df = DateFormatter()
        df.dateFormat = "MM-dd-yyyy"
        self.keys = Array(self.data.keys).sorted { (ds1, ds2) -> Bool in
            let d1 = df.date(from: ds1)!
            let d2 = df.date(from: ds2)!
            return d1 > d2
        }
        
        self.transactionsTableView.reloadData()
    }
    
    @objc func update() {
        refreshControl.beginRefreshing()
        _ = sentinel.update().done {
            self.refreshControl.endRefreshing()
        }
    }
}

extension TransactionsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = self.data[self.keys[section]]?.count {
            return count
        }
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let count = self.data.count
        if count == 0 {
            tableView.isHidden = true
            notrx.isHidden = false
        }else{
            tableView.isHidden = false
            notrx.isHidden = true
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let df = DateFormatter()
        df.dateFormat = "MM-dd-yyyy"
        if df.string(from: Date()) == keys[section] {
            return "Today"
        }else{
            return keys[section]
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TransactionTableViewCell
        cell.setData(walletTransaction: (self.data[keys[indexPath.section]]?.reversed()[indexPath.row])!)
        return cell
    }
}

extension TransactionsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let trans = TrxViewController(walletTransaction: (self.data[keys[indexPath.section]]?.reversed()[indexPath.row])!)
        self.navigationController?.pushViewController(trans, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as! UITableViewHeaderFooterView).backgroundView?.backgroundColor = #colorLiteral(red: 0.1333333333, green: 0.1529411765, blue: 0.1764705882, alpha: 1)
        (view as! UITableViewHeaderFooterView).textLabel?.textColor = UIColor.lightGray
        (view as! UITableViewHeaderFooterView).textLabel?.font = UIFont.systemFont(ofSize: 13)
    }
}
