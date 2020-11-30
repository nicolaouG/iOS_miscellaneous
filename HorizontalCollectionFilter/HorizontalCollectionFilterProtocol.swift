//
//  HorizontalCollectionFilterProtocol.swift
//  Eshop
//
//  Created by george on 25/11/2020.
//  Copyright © 2020 George Nicolaou. All rights reserved.
//

import Foundation

public protocol HorizontalCollectionFilterDelegate {
    func didSelect(cell: FilterCollectionViewCell, withIndex index: Int)
}

extension HorizontalCollectionFilterDelegate {
    func didSelect(cell: FilterCollectionViewCell, withIndex index: Int) {}
}
