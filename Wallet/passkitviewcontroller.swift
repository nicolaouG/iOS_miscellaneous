//
//  PassKitViewController.swift
//  Test
//
//  Created by george on 20/01/2021.
//

import UIKit
import PassKit

class PassKitViewController: UIViewController {
    
    lazy var addToWalletButton: PKAddPassButton = {
        var style: PKAddPassButtonStyle = .black
        if #available(iOS 13.0, *),
           self.view.traitCollection.userInterfaceStyle == .dark {
            style = .blackOutline
        }
        let b = PKAddPassButton(addPassButtonStyle: style)
        b.addTarget(self, action: #selector(walletButtonClick), for: .touchUpInside)
        return b
    }()
    
    lazy var alternativeWalletButton: UIButton = {
        let b = UIButton(type: .system)

        let shadow = NSShadow()
        shadow.shadowBlurRadius = 1
        shadow.shadowOffset = CGSize(width: 1, height: 1)
        shadow.shadowColor = UIColor.lightGray
        
        b.setAttributedTitle(NSAttributedString(string: NSLocalizedString("Added in wallet", comment: ""), attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium), NSAttributedString.Key.foregroundColor : UIColor.gray, NSAttributedString.Key.shadow : shadow]), for: .disabled)
        
        b.isEnabled = false
        b.isHidden = true
        return b
    }()
    
    lazy var spinner: UIActivityIndicatorView = {
        let s = UIActivityIndicatorView(style: .gray)
        s.hidesWhenStopped = true
        s.color = .systemBlue
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }
    
    
    func setupUI() {
        [addToWalletButton, alternativeWalletButton].forEach({
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            $0.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        })
        
        view.addSubview(spinner)
        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 40).isActive = true
    }
    
    func returnFromBackgroundObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    func cancelBackgroundObserver() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    @objc func willEnterForeground(){
//        getPassApiCall(identifier: "SearchWalletForPass")
    }

    
    @objc func walletButtonClick() {
        guard PKAddPassesViewController.canAddPasses() else {
            print("Device does not support adding passes")
            return
        }
//        getPassApiCall(identifier: "ShowPassKit")
    }
    
    func showPassKit(data: Data?){
        guard let passData = data else {
            print("No data available for pass.\nCannot create pass.")
            return
        }
        
        do {
            let customerPass = try PKPass(data: passData)
            guard let addPassVC = PKAddPassesViewController(pass: customerPass) else { return }
            self.present(addPassVC, animated: true, completion: nil)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func searchWallet(data: Data?) {
        guard let passData = data else { return }
        
        do {
            let pass = try PKPass(data: passData)
            let passLib = PKPassLibrary()
            
            if passLib.containsPass(pass) {
                self.hideWalletButton()
            } else {
                self.showWalletButton()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func hideWalletButton(){
        self.addToWalletButton.isHidden = true
        self.alternativeWalletButton.isHidden = false
    }
    
    func showWalletButton(){
        self.addToWalletButton.isHidden = false
        self.alternativeWalletButton.isHidden = true
    }
}
