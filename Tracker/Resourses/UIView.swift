//
//  UIView.swift
//  Tracker
//
//  Created by Александр Зиновьев on 28.03.2023.
//

import UIKit

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }
}
