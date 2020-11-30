//
//  CustomPagingCollectionViewFlowLayout.swift
//  AMAPortal
//
//  Created by Stelios Ioannou on 05/06/2018.
//  Copyright © 2018 Stelios Ioannou. All rights reserved.
//

import UIKit

public class CustomPagingCollectionViewFlowLayout: UICollectionViewFlowLayout {

    public override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        /// when scrolling to the first or last cell (problem when more than 2 cells visible on screen)
        if proposedContentOffset.x < sectionInset.left { /// left
            return .zero
        }
        let maxRight = collectionViewContentSize.width - (collectionView?.bounds.width ?? 0)
        if proposedContentOffset.x > maxRight - sectionInset.right { /// right
            return CGPoint(x: maxRight, y: proposedContentOffset.y)
        }

        
//        let collectionViewSize: CGSize? = collectionView?.bounds.size
        let proposedContentOffsetCenterX: CGFloat = proposedContentOffset.x + (collectionView?.bounds.size.width ?? 0.0) * 0.5
        let proposedRect: CGRect? = collectionView?.bounds
        // Comment out if you want the collectionview simply stop at the center of an item while scrolling freely
        // proposedRect = CGRectMake(proposedContentOffset.x, 0.0, collectionViewSize.width, collectionViewSize.height);
        var candidateAttributes: UICollectionViewLayoutAttributes?
        for attributes: UICollectionViewLayoutAttributes? in layoutAttributesForElements(in: proposedRect ?? CGRect.zero) ?? [UICollectionViewLayoutAttributes?]() {
            // == Skip comparison with non-cell items (headers and footers) == //
            if attributes?.representedElementCategory != .cell {
                continue
            }
            // == First time in the loop == //
            if candidateAttributes == nil {
                candidateAttributes = attributes
                continue
            }
            if fabsf(Float((attributes?.center.x ?? 0.0) - proposedContentOffsetCenterX)) < fabsf(Float((candidateAttributes?.center.x ?? 0.0) - proposedContentOffsetCenterX)) {
                candidateAttributes = attributes
            }
        }
      
        return CGPoint(x: (candidateAttributes?.center.x ?? 0.0) - (collectionView?.bounds.size.width ?? 0.0) * 0.5, y: proposedContentOffset.y)
    }

}
