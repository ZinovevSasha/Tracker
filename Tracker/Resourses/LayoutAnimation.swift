//
//  LayoutAnimation.swift
//  Tracker
//
//  Created by Александр Зиновьев on 13.04.2023.
//

import UIKit

enum LayoutAnimation {
    static func animateConstraint(_ constraint: NSLayoutConstraint, toConstant constant: CGFloat, duration: TimeInterval) {
        constraint.constant = constant
        constraint.isActive = true
        
        UIView.animate(withDuration: duration) {
            constraint.firstItem?.superview?.layoutIfNeeded()
        }
    }
    
    static func animateView(_ view: UIView, toFrame frame: CGRect, duration: TimeInterval) {
        UIView.animate(withDuration: duration) {
            view.frame = frame
            view.superview?.layoutIfNeeded()
        }
    }

    static func animateView(_ view: UIView, toAlpha alpha: CGFloat, duration: TimeInterval) {
        UIView.animate(withDuration: duration) {
            view.alpha = alpha
        }
    }

    static func animateView(_ view: UIView, toTransform transform: CGAffineTransform, duration: TimeInterval) {
        UIView.animate(withDuration: duration) {
            view.transform = transform
        }
    }

    static func animateView(_ view: UIView, toBackgroundColor color: UIColor, duration: TimeInterval) {
        UIView.animate(withDuration: duration) {
            view.backgroundColor = color
        }
    }
}
