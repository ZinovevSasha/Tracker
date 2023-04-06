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
    
    func shakeSelf() {
        let shakingAnimation = CABasicAnimation(keyPath: "position")
        shakingAnimation.duration = 0.05
        shakingAnimation.repeatCount = 5
        shakingAnimation.autoreverses = true
        
        let fromPoint = CGPoint(x: self.center.x - 5, y: self.center.y)
        let toPoint = CGPoint(x: self.center.x + 5, y: self.center.y)
        
        shakingAnimation.fromValue = NSValue(cgPoint: fromPoint)
        shakingAnimation.toValue = NSValue(cgPoint: toPoint)
        
        self.layer.add(shakingAnimation, forKey: nil)
    }
}

extension UIStackView {
    func addArrangedSubviews(_ views: UIView...) {
        views.forEach { addArrangedSubview($0) }
    }
}
