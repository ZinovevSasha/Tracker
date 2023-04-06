//
//  CategoryCollectionViewCell.swift
//  CompositionalLayout
//
//  Created by Александр Зиновьев on 01.04.2023.
//

import UIKit

final class TrackerScheduleCollectionViewCell: UICollectionViewCell {
    static let identifier = String(describing: TrackerScheduleCollectionViewCell.self)
    // MARK: Public
    func configure(with info: Text) {
        textLabel.text = info.title
    }
    
    func configure(with supplementaryInfo: String) {
        supplementaryTextLabel.text = supplementaryInfo
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
    
    private let supplementaryTextLabel: UILabel = {
        let view = UILabel()
        view.textColor = .myGray
        view.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.alignment = .leading
        view.spacing = 2
        view.distribution = .fill
        return view
    }()
}

// MARK: Private methods
private extension TrackerScheduleCollectionViewCell {
    func initialise() {
        stackView.addArrangedSubview(textLabel)
        stackView.addArrangedSubview(supplementaryTextLabel)
        
        contentView.addSubview(stackView)
        contentView.addSubview(accessoryImageView)
        contentView.backgroundColor = .myBackground
        contentView.layer.cornerRadius = 16
        contentView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        contentView.layer.masksToBounds = true
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 16),
            stackView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 15),
            stackView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -14),
            stackView.trailingAnchor.constraint(equalTo: accessoryImageView.leadingAnchor, constant: -10),

            accessoryImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            accessoryImageView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -24)
        ])
    }
}
