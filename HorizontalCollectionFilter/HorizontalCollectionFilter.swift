//
//  HorizontalCollectionFilter.swift
//  Eshop
//
//  Created by george on 25/11/2020.
//  Copyright © 2020 George Nicolaou. All rights reserved.
//

import UIKit

/**
 Horizontal collection of labels with single or multiple selection, variable number of rows and paging capability.
 
 # Sample code:
 ```
 lazy var horizontalFilter: HorizontalCollectionFilter = {
     let v = HorizontalCollectionFilter()
     let cities = Cities.allCases.map({ $0.cityName() })
     v.dataSource = cities
     v.paging = false
     v.rows = 1
     v.filterDelegate = self
     v.selectionStyle = .single(allowsDeselect: false)
     v.frame = CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: v.collectionHeight))
     // for initial default selection
     DispatchQueue.main.async {
         v.collectionView(v.filterCollectionView, didSelectItemAt: IndexPath(item: 0, section: 0))
     }
     return v
 }()
 ```
 */
public class HorizontalCollectionFilter: UIView {
    public enum SelectionStyle {
        case single(allowsDeselect: Bool), multiple
    }
    
    public var filterDelegate: HorizontalCollectionFilterDelegate?
    
    public var selectionStyle: SelectionStyle = .multiple
    
    public var rows: Int = 1 {
        didSet {
            setupConstraints()
        }
    }
    
    public var paging: Bool = false {
        didSet {
            filterCollectionView.isPagingEnabled = paging
        }
    }
    
    public var dataSource: [String] = [] {
        didSet {
            filterCollectionView.reloadData()
        }
    }
    
    public private(set) var selectedIndexPaths: [IndexPath] = []
    public var collectionHeight: CGFloat = 0
    
    public lazy var cvLayout: UICollectionViewFlowLayout = {
        let l = UICollectionViewFlowLayout()
        l.scrollDirection = .horizontal
        l.itemSize = UICollectionViewFlowLayout.automaticSize
        l.estimatedItemSize = CGSize(width: 1, height: 1)
        l.minimumInteritemSpacing = 0
        l.minimumLineSpacing = 0
        l.sectionInset = .zero
        return l
    }()
    
    public lazy var filterCollectionView: UICollectionView = {
        let c = UICollectionView(frame: .zero, collectionViewLayout: cvLayout)
        c.register(FilterCollectionViewCell.self, forCellWithReuseIdentifier: "filterCVC")
        c.dataSource = self
        c.delegate = self
        c.alwaysBounceHorizontal = true
        c.allowsMultipleSelection = false
        c.isPagingEnabled = paging
        c.layer.zPosition = 100
        c.backgroundColor = MainApp.shared.theme.backgroundColor
        c.contentInset = .zero
        return c
    }()
    
    
    public init() {
        super.init(frame: .zero)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupView() {
        addSubview(filterCollectionView)
    }
    
    private func setupConstraints() {
        let cell = FilterCollectionViewCell()
        let totalHeight = cell.getCellHeight() + filterCollectionView.contentInset.top + filterCollectionView.contentInset.bottom + cvLayout.sectionInset.top + cvLayout.sectionInset.bottom
        let h = CGFloat(rows) * totalHeight
        
        filterCollectionView.snp.remakeConstraints({
            $0.edges.equalToSuperview()
            $0.height.equalTo(h).priority(990)
        })
        
        collectionHeight = h
    }
}



extension HorizontalCollectionFilter: UICollectionViewDataSource, UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "filterCVC", for: indexPath) as? FilterCollectionViewCell
        
        if dataSource.count > indexPath.item {
            cell?.titleLabel.text = dataSource[indexPath.item]
        }
        cell?.isFilterSelected = selectedIndexPaths.contains(indexPath)
        return cell ?? FilterCollectionViewCell()
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? FilterCollectionViewCell {
            switch selectionStyle {
            case .single(let allowsDeselect):
                if allowsDeselect {
                    cell.isFilterSelected.toggle()
                } else {
                    cell.isFilterSelected = true
                }
                for index in 0..<collectionView.numberOfItems(inSection: 0) {
                    guard index != indexPath.item else { continue }
                    (collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? FilterCollectionViewCell)?.isFilterSelected = false
                }
                selectedIndexPaths = cell.isFilterSelected ? [indexPath] : []

            case .multiple:
                cell.isFilterSelected.toggle()
                if cell.isFilterSelected && !selectedIndexPaths.contains(indexPath) {
                    selectedIndexPaths.append(indexPath)
                } else {
                    selectedIndexPaths.removeAll(where: {$0 == indexPath})
                }
            }

            filterDelegate?.didSelect(cell: cell, withIndex: indexPath.item)
        }
    }
}
