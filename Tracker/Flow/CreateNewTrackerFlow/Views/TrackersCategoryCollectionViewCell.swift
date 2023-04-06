//
//  CategoryCollectionViewCell.swift
//  CompositionalLayout
//
//  Created by Александр Зиновьев on 01.04.2023.
//

import UIKit

final class TrackersCategoryCollectionViewCell: UICollectionViewCell {
    static let identifier = String(describing: TrackersCategoryCollectionViewCell.self)
    // MARK: Public
    func configure(with info: Text) {
        textLabel.text = info.title
    }
    
    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: .zero)
        initialise()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Private properties
    private let seperatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .myGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let accessoryImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage.chevron?
            .withTintColor(.myGray, renderingMode: .alwaysOriginal)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let textLabel: UILabel = {
        let view = UILabel()
        view.textColor = .myBlack
        view.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
}

// MARK: Private methods
private extension TrackersCategoryCollectionViewCell {
    func initialise() {
        contentView.addSubview(textLabel)
        contentView.addSubview(seperatorView)
        contentView.addSubview(accessoryImageView)
        
        contentView.backgroundColor = .myBackground
        contentView.layer.cornerRadius = 16
        contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        contentView.layer.masksToBounds = true
        
        let inset = CGFloat(10)
        NSLayoutConstraint.activate([
            textLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 27),
            textLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -26),
            textLabel.trailingAnchor.constraint(equalTo: accessoryImageView.leadingAnchor, constant: -inset),

            accessoryImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            accessoryImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            seperatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
            seperatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            seperatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -inset),
            seperatorView.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
}
