//
//  GeometryParams.swift
//  Tracker
//
//  Created by Александр Зиновьев on 28.03.2023.
//

import Foundation

struct GeometryParams {
    let cellCount: Int
    let leftInset: CGFloat
    let rightInset: CGFloat
    let spacing: CGFloat
    let emptySpaceWidth: CGFloat
    
    init(
        cellCount: Int,
        leftInset: CGFloat,
        rightInset: CGFloat,
        spacing: CGFloat
    ) {
        self.cellCount = cellCount
        self.leftInset = leftInset
        self.rightInset = rightInset
        self.spacing = spacing
        self.emptySpaceWidth = leftInset + rightInset + CGFloat(cellCount - 1) * spacing
    }
}

