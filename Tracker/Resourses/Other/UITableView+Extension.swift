import UIKit

protocol TableViewCellSeparatorProtocol where Self: UITableViewCell {
    
    // Separator properties
    var separatorView: UIView { get }
    var separatorInsets: UIEdgeInsets { get }
    var separatorColor: UIColor { get set }
    var separatorHeight: CGFloat { get set }
    var showsSeparator: Bool { get set }
    
    // Method to update separator appearance based on position in table view
    func updateSeparatorLayout(isFirstRow: Bool, isLastRow: Bool)
}

extension TableViewCellSeparatorProtocol {
    func updateSeparatorLayout(isFirstRow: Bool, isLastRow: Bool) {
        let isFirstAndLastRow = isFirstRow && isLastRow
        
        // Hide separator for single cell or last cell
        if isFirstAndLastRow || isLastRow {
            separatorView.isHidden = true
            return
        }
        
        separatorView.isHidden = !showsSeparator
        separatorView.backgroundColor = separatorColor
        separatorView.frame = CGRect(x: self.separatorInsets.left,
                                     y: self.contentView.bounds.height - self.separatorHeight,
                                     width: self.contentView.bounds.width - self.separatorInsets.left - self.separatorInsets.right,
                                     height: self.separatorHeight)
    }
    
    func handleContextMenuActivation(isHighlighted: Bool) {
        UIView.animate(withDuration: 0.3) {
            if isHighlighted {
                self.separatorView.alpha = .zero
            }  else {
                self.separatorView.alpha = 1
            }
        }
    }
}

extension UITableViewCell {
    // MARK: - Public
    func setSeparatorInset(in tableView: UITableView, at indexPath: IndexPath) {
        if tableView.cellIsOnlyOne(at: indexPath) {
            tableView.separatorInset = UIEdgeInsets(
                top: .zero, left: .zero, bottom: .zero, right: tableView.bounds.width)
        } else if tableView.cellIsLast(at: indexPath) {
            tableView.separatorInset = UIEdgeInsets(
                top: .zero, left: .zero, bottom: .zero, right: tableView.bounds.width)
        } else {
            tableView.separatorInset = UIEdgeInsets(
                top: .zero, left: 16, bottom: .zero, right: 16)
        }
    }
    
    func setCorners(in tableView: UITableView, at indexPath: IndexPath, radius: CGFloat = .cornerRadius) {
        let corners: CACornerMask
        
        if tableView.cellIsOnlyOne(at: indexPath) {
            corners = CACornerMask(allCorners: true)
        } else if tableView.cellIsFirst(at: indexPath){
            corners = CACornerMask(topCorners: true)
        } else if tableView.cellIsLast(at: indexPath) {
            corners = CACornerMask(bottomCorners: true)
        } else {
            corners = []
        }
        
        set(corners, with: radius)
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

extension CACornerMask {
    init(topCorners: Bool = false, bottomCorners: Bool = false, allCorners: Bool = false) {
        if allCorners {
            self = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            var mask: CACornerMask = []
            if topCorners {
                mask.insert(.layerMinXMinYCorner)
                mask.insert(.layerMaxXMinYCorner)
            }
            if bottomCorners {
                mask.insert(.layerMinXMaxYCorner)
                mask.insert(.layerMaxXMaxYCorner)
            }
            self = mask
        }
    }
}
