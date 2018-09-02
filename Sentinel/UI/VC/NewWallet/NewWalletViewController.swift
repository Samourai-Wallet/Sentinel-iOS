//
//  NewWalletViewController.swift
//  Sentinel
//
//  Created by Farzad Nazifi on 02.06.18.
//  Copyright © 2018 Samourai. All rights reserved.
//

import UIKit
import QRCodeReader

protocol NewWalletViewControllerDelegate {
    func newAccontAdded()
}

class NewWalletViewController: UIViewController, UITextFieldDelegate {
    required init?(coder aDecoder: NSCoder) { fatalError("...") }
    
    let sentinel: Sentinel
    let wallet: Wallet?
    
    var delegate: NewWalletViewControllerDelegate?
    
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var addressTextField: UITextField!
    @IBOutlet var qrScanButton: UIButton!
    
    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
        }
        return QRCodeReaderViewController(builder: builder)
    }()
    
    init(sentinel: Sentinel, wallet: Wallet? = nil) {
        self.sentinel = sentinel
        self.wallet = wallet
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let wallet = wallet else {
            return
        }
        
        self.nameTextField.text = wallet.name
        self.addressTextField.text = wallet.address
        self.addressTextField.isEnabled = false
        self.addressTextField.delegate = self
        self.addressTextField.alpha = 0.8
        self.qrScanButton.isHidden = true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createAction(_ sender: Any) {
        guard let wallet = wallet else {
            _ = sentinel.addWallet(name: nameTextField.text, addr: addressTextField.text).done {
                self.delegate?.newAccontAdded()
                self.dismiss(animated: true, completion: nil)
                }.catch { (err) in
                    let alertController = UIAlertController(title: NSLocalizedString("Failed", comment: ""), message: err.localizedDescription, preferredStyle: .alert)
                    let cancel = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel) { (action) in
                    }
                    alertController.addAction(cancel)
                    self.present(alertController, animated: true)
            }
            return
        }
        
        _ = sentinel.renameWallet(wallet: wallet, name: nameTextField.text).done {
            self.dismiss(animated: true, completion: nil)
            }.catch({ (err) in
                let alertController = UIAlertController(title: NSLocalizedString("Failed", comment: ""), message: err.localizedDescription, preferredStyle: .alert)
                let cancel = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel) { (action) in
                }
                alertController.addAction(cancel)
                self.present(alertController, animated: true)
            })
    }
    
    @IBAction func scanAction(_ sender: AnyObject) {
        readerVC.delegate = self
        readerVC.modalPresentationStyle = .formSheet
        present(readerVC, animated: true, completion: nil)
    }
}

extension NewWalletViewController: QRCodeReaderViewControllerDelegate {
    
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        dismiss(animated: true, completion: nil)
        self.addressTextField.text = result.value.replacingOccurrences(of: "bitcoin:", with: "")
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        dismiss(animated: true, completion: nil)
    }
}
