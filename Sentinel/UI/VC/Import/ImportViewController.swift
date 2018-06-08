//
//  ImportViewController.swift
//  Sentinel
//
//  Created by Farzad Nazifi on 6/5/18.
//  Copyright © 2018 Samourai. All rights reserved.
//

import UIKit
import QRCodeReader

class ImportViewController: UIViewController, UITextFieldDelegate {
    required init?(coder aDecoder: NSCoder) { fatalError("...") }
    
    let sentinel: Sentinel
    var importItem: UIBarButtonItem!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var encryptedTextField: UITextField!
    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
        }
        return QRCodeReaderViewController(builder: builder)
    }()
    
    init(sentinel: Sentinel) {
        self.sentinel = sentinel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        importItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.importWallets))
        importItem.isEnabled = false
        self.navigationItem.rightBarButtonItems = [importItem]
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if passwordTextField.text!.count > 5 && encryptedTextField.text!.count > 5 {
            importItem.isEnabled = true
        }else{
            importItem.isEnabled = false
        }
        return true
    }
    
    @objc func importWallets() {
        sentinel.importWallet(input: encryptedTextField.text!, password: passwordTextField.text!).done {
            let alertController = UIAlertController(title: "Imported!", message: "Your wallet has been successfully imported.", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "OK", style: .cancel) { (action) in
                self.navigationController?.popViewController(animated: true)
            }
            alertController.addAction(cancel)
            self.present(alertController, animated: true)
            }.catch { (err) in
                let alertController = UIAlertController(title: "Failed", message: err.localizedDescription, preferredStyle: .alert)
                let cancel = UIAlertAction(title: "OK", style: .cancel) { (action) in
                }
                alertController.addAction(cancel)
                self.present(alertController, animated: true)
        }
    }
}

extension ImportViewController: QRCodeReaderViewControllerDelegate {
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        dismiss(animated: true, completion: nil)
        self.encryptedTextField.text = result.value
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        dismiss(animated: true, completion: nil)
    }
}
