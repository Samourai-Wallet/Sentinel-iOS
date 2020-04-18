//
//  PushTXViewController.swift
//  Sentinel
//
//  Created by Farzad Nazifi on 10/11/18.
//  Copyright © 2018 Samourai. All rights reserved.
//

import UIKit
import Alamofire
import QRCodeReader

class PushTXViewController: UIViewController {
    let sentinel: Sentinel
    @IBOutlet var textView: UITextView!
    
    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
        }
        return QRCodeReaderViewController(builder: builder)
    }()
    
    required init?(coder aDecoder: NSCoder) { fatalError("...") }
    init(sentinel: Sentinel) {
        self.sentinel = sentinel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Push Transaction"
        let push = UIBarButtonItem(title: NSLocalizedString("Push", comment: ""), style: UIBarButtonItemStyle.plain, target: self, action: #selector(pushTrx))
        navigationItem.rightBarButtonItem = push
    }
    
    @objc func pushTrx() {
        navigationItem.rightBarButtonItem?.isEnabled = false
        guard verifyTrx(str: textView.text) else {
            self.alert(title: "Failed", message: "Failed to verify the transaction.", close: "OK!")
            navigationItem.rightBarButtonItem?.isEnabled = true
            return
        }
        
        var request = URLRequest(url: URL(string: "https://api.samouraiwallet.com/v2/pushtx/")!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = "tx=\(textView.text!)".data(using: .utf8)!
        AF.request(request).responseJSON { (response) in
            
            guard response.error == nil else {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                self.alert(title: "Error", message: "Failed to push the transaction. \(response.error!.localizedDescription)", close: "OK!")
                return
            }
            
            guard !(response.response?.statusCode == 200) else {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                self.alert(title: "Done", message: "Transaction pushed successfully.", close: "OK", action: self.close)
                return
            }
            
            guard let json = response.value as? [String: Any] else {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                return
            }

            self.alert(title: "Error", message: "Failed to push the transaction. \(json["error"] ?? "Unkown error")", close: "OK")
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    
    func close() {
        dismiss(animated: true, completion: nil)
    }
    
    func verifyTrx(str: String) -> Bool {
        // Hex
        guard isValidHexNumber(str: str) else {
            return false
        }
        
        guard (str.hasPrefix("01") || str.hasPrefix("02")) else {
            return false
        }
        
        return true
    }
    
    func isValidHexNumber(str: String) -> Bool {
        let chars = CharacterSet(charactersIn: "0123456789ABCDEF")
        
        guard str.uppercased().rangeOfCharacter(from: chars) != nil else {
            return false
        }
        return true
    }
    
    @IBAction func scanAction(_ sender: Any) {
        readerVC.delegate = self
        readerVC.modalPresentationStyle = .formSheet
        present(readerVC, animated: true, completion: nil)
    }
}

extension PushTXViewController: QRCodeReaderViewControllerDelegate {
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        dismiss(animated: true, completion: nil)
        self.textView.text = result.value
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        dismiss(animated: true, completion: nil)
    }
}
