//
//  UITableView+Extension.swift
//  Tracker
//
//  Created by Александр Зиновьев on 09.04.2023.
//

import UIKit

extension UITableViewCell {
    // MARK: - Public
    func setCellCorners(in tableView: UITableView, at indexPath: IndexPath, radius: CGFloat = .cornerRadius) {
        let corners: CACornerMask
        
        if tableView.cellIsOnlyOne(at: indexPath) {
            corners = CACornerMask(all: true)
        } else if tableView.cellIsFirst(at: indexPath){
            corners = CACornerMask(top: true)
        } else if tableView.cellIsLast(at: indexPath) {
            corners = CACornerMask(bottom: true)
        } else {
            corners = []
        }
        
        set(corners, with: radius)
    }
    
    func setSeparatorInset(in tableView: UITableView, at indexPath: IndexPath) {
        if tableView.cellIsOnlyOne(at: indexPath) || tableView.cellIsLast(at: indexPath) {
            self.separatorInset = .noCellSeparator
        } else {
            self.separatorInset = .visibleCellSeparator
        }
    }
    
    // MARK: - Private
    private func set(_ corners: CACornerMask, with radius: CGFloat) {
        self.contentView.layer.cornerRadius = radius
        self.contentView.layer.maskedCorners = [corners]
    }
}

extension UITableView {
    // MARK: - Public
    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(
            withIdentifier: T.reuseIdentifier,
            for: indexPath
        ) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
        }
        
        return cell
    }
    
    func register<T: UITableViewCell>(cellClass: T.Type) {
        register(cellClass, forCellReuseIdentifier: T.reuseIdentifier)
    }
    
    func cellIsFirst(at indexPath: IndexPath) -> Bool {
        return indexPath.row == 0
    }

    func cellIsLast(at indexPath: IndexPath) -> Bool {
        return indexPath.row == numberOfRows(inSection: indexPath.section) - 1
    }

    func cellIsOnlyOne(at indexPath: IndexPath) -> Bool {
        return numberOfRows(inSection: indexPath.section) == 1
    }
}

extension CALayer {
    func setCorner(_ corners: CACornerMask, radius: CGFloat) {
        self.cornerRadius = radius
        self.maskedCorners = corners
    }
}

extension CACornerMask {
    init(top: Bool = false, bottom: Bool = false, all: Bool = false) {
        if all {
            self = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            var mask: CACornerMask = []
            if top {
                mask.insert(.layerMinXMinYCorner)
                mask.insert(.layerMaxXMinYCorner)
            }
            if bottom {
                mask.insert(.layerMinXMaxYCorner)
                mask.insert(.layerMaxXMaxYCorner)
            }
            self = mask
        }
    }
}
