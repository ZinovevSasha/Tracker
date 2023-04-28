//
//  UIButton+Extension.swift
//  Tracker
//
//  Created by Александр Зиновьев on 13.04.2023.
//

import UIKit

class ExtendedButton: UIButton {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let extendedArea = UIEdgeInsets(top: -50, left: -50, bottom: -50, right: -50)
        let extendedBounds = bounds.inset(by: extendedArea)
        return extendedBounds.contains(point) ? self : nil
    }
    
    func setUpAppearance(forState state: UIControl.State, backgroundColor: UIColor, titleColor: UIColor, title: String, cornerRadius: CGFloat) {
        self.setBackgroundImage(UIImage(color: backgroundColor), for: state)
        self.setTitleColor(titleColor, for: state)
        self.setTitle(title, for: state)
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
    }
}
