//
//  UIEdgeInsets+Extension.swift
//  Tracker
//
//  Created by Александр Зиновьев on 09.04.2023.
//

import UIKit

extension UIEdgeInsets {
    static let noCellSeparator = UIEdgeInsets(
        top: .zero, left: .zero, bottom: .zero, right: .greatestFiniteMagnitude)
    static let visibleCellSeparator = UIEdgeInsets(
        top: .zero, left: 16, bottom: .zero, right: 16)
}
