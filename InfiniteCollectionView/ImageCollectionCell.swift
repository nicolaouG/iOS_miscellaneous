//
//  ImageCollectionCell.swift
//  Eshop
//
//  Created by george on 27/10/2020.
//  Copyright © 2020 George Nicolaou. All rights reserved.
//

import UIKit

public class ImageCollectionCell: UICollectionViewCell {
    lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 6
        return iv
    }()
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        addSubview(imageView)
        imageView.snp.makeConstraints({ make in
            make.edges.equalToSuperview()
        })
    }
}
