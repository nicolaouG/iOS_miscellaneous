//
//  PinterestCollectionViewLayout.swift
//  TestProject
//
//  Created by george on 13/05/2020.
//  Copyright © 2020 george. All rights reserved.
//

import UIKit

protocol PinterestCollectionViewLayoutDelegate: class {
    func collectionView(_ collectionView:UICollectionView, heightForItemAt indexPath:IndexPath) -> CGFloat
}

class PinterestCollectionViewLayout: UICollectionViewLayout {
    weak var delegate: PinterestCollectionViewLayoutDelegate?
    
    /// Configurable properties
    var numberOfColumns = 2
    var cellPadding: CGFloat = 5
    var defaultCellHeight: CGFloat = 100
    
    /// Cache of attributes to prevent multiple calculations
    private var cache = [UICollectionViewLayoutAttributes]()
    
    private var contentHeight: CGFloat = 0
    
    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else { return 0 }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func prepare() {
        /// Calculate once
        guard cache.isEmpty == true, let collectionView = collectionView else {
            return
        }
        /// Pre-Calculate the X Offset for every column and add an array to increment the currently max Y Offset for each column
        let columnWidth = contentWidth / CGFloat(numberOfColumns)
        var xOffset = [CGFloat]()
        for column in 0 ..< numberOfColumns {
            xOffset.append(CGFloat(column) * columnWidth)
        }
        var column = 0
        var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
        
        /// Iterate through the list of items in the first section
        for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            
            /// get the height from the delegate and calculate the cell frame.
            let photoHeight = delegate?.collectionView(collectionView, heightForItemAt: indexPath) ?? defaultCellHeight
            let height = cellPadding * 2 + photoHeight
            let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)
            
            /// Update the collection view content height
            contentHeight = max(contentHeight, frame.maxY)
            yOffset[column] = yOffset[column] + height
            
            column = column < (numberOfColumns - 1) ? (column + 1) : 0
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        
        /// Loop through the cache and look for items in the rect
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
    
    override func invalidateLayout() {
        super.invalidateLayout()
        cache = []
    }
}
