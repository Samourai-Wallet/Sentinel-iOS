//
//  ExportViewController.swift
//  Sentinel
//
//  Created by Farzad Nazifi on 6/6/18.
//  Copyright © 2018 Samourai. All rights reserved.
//

import UIKit

class ExportViewController: UIViewController, UITextFieldDelegate {
    required init?(coder aDecoder: NSCoder) { fatalError("...") }
    
    let sentinel: Sentinel
    
    var export: String?
    var exportAction: UIAlertAction!
    
    @IBOutlet var qrImageView: UIImageView!
    
    init(sentinel: Sentinel) {
        self.sentinel = sentinel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Exoport wallet"
        
        let alert = UIAlertController(title: "Export Password", message: "Please enter a pssword", preferredStyle: UIAlertControllerStyle.alert)

        exportAction = UIAlertAction(title: "Export", style: UIAlertActionStyle.default) { (action: UIAlertAction) in
            self.sentinel.exportWallet(password: alert.textFields!.first!.text!).done { (json) in
                self.export = json
                let shareItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(self.share))
                self.navigationItem.rightBarButtonItems = [shareItem]
                self.qrImageView.image = QRCode(self.export!)?.image
                }.catch { (err) in
                    print(err.localizedDescription)
            }
        }
        exportAction.isEnabled = false
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.navigationController?.popViewController(animated: true)
        }
        
        alert.addTextField { (textField: UITextField) in
            textField.delegate = self
            textField.textContentType = .password
            textField.placeholder = "Password here"
        }
        
        alert.addAction(exportAction)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.text!.count > 5 {
            exportAction.isEnabled = true
        }else{
            exportAction.isEnabled = false
        }
        return true
    }
    
    @objc func share() {
        let activityViewController = UIActivityViewController(activityItems: [self.export!], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook ]
        self.present(activityViewController, animated: true, completion: nil)
    }
}
