//
//  ScheduleTableViewCell.swift
//  Tracker
//
//  Created by Александр Зиновьев on 04.04.2023.
//

import UIKit

protocol CategoryTableViewCellDelegate: AnyObject {
  
}

final class CategoryTableViewCell: UITableViewCell {
    // MARK: - Public
    func configure(with info: String) {
        categoryName.text = info
    }
    
    weak var delegate: CategoryTableViewCellDelegate?
    
    // MARK: - Private properties
    private let categoryName: UILabel = {
        let view = UILabel()
        view.textColor = .myBlack
        view.font = .regular17
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let selectedCategory: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alignment = .center
        view.distribution = .fill
        return view
    }()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialise()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
}

// MARK: - Private methods
private extension CategoryTableViewCell {
    func initialise() {
        stackView.addArrangedSubviews(categoryName, selectedCategory)
        contentView.addSubview(stackView)
        contentView.backgroundColor = .myBackground
        separatorInset = .visibleCellSeparator
        selectionStyle = .none
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 16),
            stackView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -16),
            stackView.topAnchor.constraint(
                equalTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor)
        ])
    }
}
