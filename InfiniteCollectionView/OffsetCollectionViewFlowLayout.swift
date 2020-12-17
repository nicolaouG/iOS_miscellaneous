//
//  OffsetCollectionViewFlowLayout.swift
//  Eshop
//
//  Created by george on 22/10/2020.
//  Copyright © 2020 George Nicolaou. All rights reserved.
//

import UIKit

public class OffsetCollectionViewFlowLayout: UICollectionViewFlowLayout {
    public var itemDimensions: CGSize = .zero {
        didSet {
            cache = []
            lastRow = 0
            lastColumn = 0
            xOffsets = []
            yOffsets = []
            invalidateLayout()
        }
    }
    
    public var columns = 0
    public var rows = 0
    
    private var lastRow = 0
    private var lastColumn = 0

    public var cache = [UICollectionViewLayoutAttributes]()
    
    private var xOffsets = [CGFloat]()
    private var yOffsets = [CGFloat]()
    
    
    public init(columns: Int, rows: Int) {
        super.init()
        self.columns = columns
        self.rows = rows
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public override func prepare() {
        guard cache.isEmpty else { return }

        for i in 0 ..< rows {
            xOffsets.append(-CGFloat(i) * (itemDimensions.width / 2))
            yOffsets.append(CGFloat(i) * (itemDimensions.height + minimumLineSpacing) + sectionInset.top)
        }

        calculateNewAttributes()
    }
    
    public func calculateNewAttributes(for indexPaths: [IndexPath] = []) {
        guard let collectionView = collectionView else { return }
        
        var row = lastRow
        var column = lastColumn

        if indexPaths.isEmpty {
            for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
                let indexPath = IndexPath(item: item, section: 0)
                
                let xOffset = xOffsets[row] + (CGFloat(column) * (itemDimensions.width + minimumInteritemSpacing)) + sectionInset.left
                let yOffset = yOffsets[row]
                let calculatedFrame = CGRect(origin: CGPoint(x: xOffset, y: yOffset), size: itemDimensions)
                
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = calculatedFrame
                cache.append(attributes)
                
                row = row < (rows - 1) ? (row + 1) : 0
                column = row == 0 ? (column + 1) : column
            }
        } else {
            indexPaths.forEach { (ip) in
                let xOffset = xOffsets[row] + (CGFloat(column) * (itemDimensions.width + minimumInteritemSpacing))
                let yOffset = yOffsets[row]
                let calculatedFrame = CGRect(origin: CGPoint(x: xOffset, y: yOffset), size: itemDimensions)
                
                let attributes = UICollectionViewLayoutAttributes(forCellWith: ip)
                attributes.frame = calculatedFrame
                cache.append(attributes)
                
                row = row < (rows - 1) ? (row + 1) : 0
                column = row == 0 ? (column + 1) : column
            }
        }
        
        lastRow = row
        lastColumn = column
    }

    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard cache.count == collectionView?.numberOfItems(inSection: 0) ?? 0 else { return nil }
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()

        for attributes in cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }

    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if cache.count > indexPath.item {
            return cache[indexPath.item]
        } else {
            return UICollectionViewLayoutAttributes()
        }
    }
}
