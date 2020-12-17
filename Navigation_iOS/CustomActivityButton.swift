//
//  CustomActivityButton.swift
//  DemoNavigationProject
//
//  Created by george on 22/05/2020.
//  Copyright © 2020 George Nicolaou. All rights reserved.
//

import UIKit

class CustomActivityButton: UIButton {
    lazy var activityIndicator : UIActivityIndicatorView = {
        let a: UIActivityIndicatorView
        if #available(iOS 13.0, *) {
            a = UIActivityIndicatorView(style: .large)
        } else {
            a = UIActivityIndicatorView(style: .gray)
        }
        a.layer.zPosition = 50
        a.hidesWhenStopped = true
        a.translatesAutoresizingMaskIntoConstraints = false
        a.isUserInteractionEnabled = false
        return a
    }()

    public var isLoading: Bool {
        get {
            return activityIndicator.isAnimating
        }
    }
    
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupView() {
        addSubview(activityIndicator)
        addTarget(self, action:  #selector(startLoading), for: .touchUpInside)
        
        [activityIndicator.topAnchor.constraint(equalTo: topAnchor),
         activityIndicator.leftAnchor.constraint(equalTo: leftAnchor),
         activityIndicator.rightAnchor.constraint(equalTo: rightAnchor),
         activityIndicator.bottomAnchor.constraint(equalTo: bottomAnchor)
        ].forEach({ $0.isActive = true })
    }
    
    @objc public func startLoading() {
        superview?.endEditing(true)
        setTitle("", for: state)
        isUserInteractionEnabled = false
        activityIndicator.startAnimating()
    }
    public func stopLoading() {
        activityIndicator.stopAnimating()
        setTitle(title(for: state), for: state)
        isUserInteractionEnabled = true
    }
}
