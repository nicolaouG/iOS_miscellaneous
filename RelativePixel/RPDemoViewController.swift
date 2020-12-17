//
//  RPDemoViewController.swift
//  Test Project
//
//  Created by george on 01/06/2020.
//  Copyright © 2020 George Nicolaou. All rights reserved.
//

import UIKit

class RPDemoViewController: UIViewController {
    lazy var iv: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "united_logo")
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    lazy var label: UILabel = {
        let l = UILabel()
        l.text = "This is a label"
        l.textAlignment = .left
        return l
    }()
    
    lazy var tf: UITextField = {
        let tf = UITextField()
        tf.layer.borderColor = UIColor.black.cgColor
        tf.clipsToBounds = true
        return tf
    }()
    
    lazy var button: UIButton = {
        let b = UIButton()
        b.clipsToBounds = true
        b.backgroundColor = .systemBlue
        return b
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(iv)
        view.addSubview(label)
        view.addSubview(tf)
        view.addSubview(button)
        
//        setupNormalConstraints()
        setupRelativeConstraints()
    }
    
    func setupNormalConstraints() {
        button.layer.cornerRadius = 6
        button.setAttributedTitle(NSAttributedString(string: "Button", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20), NSAttributedString.Key.foregroundColor : UIColor.white]), for: .normal)
        tf.layer.borderWidth = 1
        tf.layer.cornerRadius = 4
        tf.attributedPlaceholder = NSAttributedString(string: "This is a text field", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20)])
        label.font = UIFont.systemFont(ofSize: 20)

        iv.snp.makeConstraints({
            $0.width.height.equalTo(80)
            $0.centerY.equalToSuperview().multipliedBy(0.5)
            $0.centerX.equalToSuperview()
        })
        
        label.font = UIFont.systemFont(ofSize: 20)
        label.snp.makeConstraints({
            $0.bottom.equalToSuperview().multipliedBy(0.5).offset(-4)
            $0.centerX.equalToSuperview()
        })

        tf.snp.makeConstraints({
            $0.width.equalTo(200)
            $0.height.equalTo(50)
            $0.top.equalTo(label.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
        })
        
        button.snp.makeConstraints({
            $0.left.right.equalToSuperview().inset(20)
            $0.height.equalTo(50)
            $0.centerY.equalToSuperview().multipliedBy(1.5)
            $0.centerX.equalToSuperview()
        })
    }
    
    func setupRelativeConstraints() {
        button.layer.cornerRadius = CGFloat(rp.width.value(of: 6))
        button.setAttributedTitle(NSAttributedString(string: "Button", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: CGFloat(rp.width.value(of: 20))), NSAttributedString.Key.foregroundColor : UIColor.white]), for: .normal)
        tf.layer.borderWidth = CGFloat(rp.width.value(of: 1))
        tf.layer.cornerRadius = CGFloat(rp.width.value(of: 4))
        tf.attributedPlaceholder = NSAttributedString(string: "This is a text field", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: CGFloat(rp.width.value(of: 20)))])
        label.font = UIFont.systemFont(ofSize: CGFloat(rp.width.value(of: 20)))

        iv.snp.makeConstraints({
            $0.width.height.equalTo(rp.width.value(of: 80))
            $0.centerY.equalToSuperview().multipliedBy(0.5)
            $0.centerX.equalToSuperview()
        })
        
        label.snp.makeConstraints({
            $0.bottom.equalToSuperview().multipliedBy(0.5).offset(rp.width.value(of: -4))
            $0.centerX.equalToSuperview()
        })

        tf.snp.makeConstraints({
            $0.width.equalTo(rp.width.value(of: 200))
            $0.height.equalTo(rp.width.value(of: 50))
            $0.top.equalTo(label.snp.bottom).offset(rp.width.value(of: 8))
            $0.centerX.equalToSuperview()
        })
        
        button.snp.makeConstraints({
            $0.left.right.equalToSuperview().inset(rp.width.value(of: 20))
            $0.height.equalTo(rp.width.value(of: 50))
            $0.centerY.equalToSuperview().multipliedBy(1.5)
            $0.centerX.equalToSuperview()
        })
    }
}
