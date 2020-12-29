//
//  sdfdvwsfdd.swift
//  Eshop
//
//  Created by george on 25/11/2020.
//  Copyright © 2020 George Nicolaou. All rights reserved.
//

import UIKit

public class FilterCollectionViewCell: UICollectionViewCell {
    public lazy var titleLabel: PaddingLabel = {
        let l = PaddingLabel(top: textPadding.top, bottom: textPadding.bottom, left: textPadding.left, right: textPadding.right)
        l.numberOfLines = 1
        l.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)
        l.clipsToBounds = true
        l.textAlignment = .center
        l.layer.borderWidth = 0.5
        l.layer.borderColor = MainApp.shared.theme.textColor.cgColor
        return l
    }()
    
    public var isFilterSelected: Bool {
        didSet {
            titleLabel.backgroundColor = isFilterSelected ? MainApp.shared.theme.textColor : MainApp.shared.theme.backgroundColor
            titleLabel.textColor = isFilterSelected ? MainApp.shared.theme.backgroundColor : MainApp.shared.theme.textColor
        }
    }
    
    public var textPadding: UIEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
    public var labelPadding: UIEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *),
           previousTraitCollection?.hasDifferentColorAppearance(comparedTo: traitCollection) ?? false {
            titleLabel.layer.borderColor = MainApp.shared.theme.textColor.cgColor
        }
    }
    
    public convenience init(textPadding: UIEdgeInsets, labelPadding: UIEdgeInsets) {
        self.init(frame: .zero)
        self.textPadding = textPadding
        self.labelPadding = labelPadding
        isFilterSelected = false
        setupView()
    }

    public override init(frame: CGRect) {
        isFilterSelected = false
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        guard !subviews.contains(titleLabel) else { return }
        addSubview(titleLabel)
        
        let height = getLabelSize().height
        
        titleLabel.snp.makeConstraints({ make in
            make.top.equalToSuperview().offset(labelPadding.top)
            make.bottom.equalToSuperview().offset(-labelPadding.bottom)
            make.left.equalToSuperview().offset(labelPadding.left)
            make.right.equalToSuperview().offset(-labelPadding.right)
            make.height.equalTo(height).priority(990) // 24
        })
        
        titleLabel.layer.cornerRadius = height / 2
    }
    
    public func getLabelSize() -> CGSize {
        guard let font = titleLabel.font else { return .zero }
        let someText = "hello"
        let size = someText.size(withAttributes: [NSAttributedString.Key.font : font])
        let heightPaddings = titleLabel.topInset + titleLabel.bottomInset
        let widthPaddings = titleLabel.leftInset + titleLabel.rightInset
        return CGSize(width: size.width + widthPaddings, height: size.height + heightPaddings)
    }
    
    public func getCellHeight() -> CGFloat {
        let labelH = getLabelSize().height
        let labelPaddings = labelPadding.top + labelPadding.bottom
        return labelH + labelPaddings
    }
    
    public func getCellWidth() -> CGFloat {
        let labelW = getLabelSize().width
        let labelPaddings = labelPadding.left + labelPadding.right
        return labelW + labelPaddings
    }
}
