//
//  OtherCollectionViewCell.swift
//  CompositionalLayout
//
//  Created by Александр Зиновьев on 01.04.2023.
//

import UIKit

class EmojiCollectionViewCell: UICollectionViewCell {
    static let identifier = String(describing: EmojiCollectionViewCell.self)
    // MARK: - Public
    func configureSelection() {
        contentView.backgroundColor = .myBackground
    }
    
    func configureDeselection() {
        contentView.backgroundColor = .clear
    }
    
    func configure(with info: CreateTrackerModel) {
        text.text = info.title
    }
    
        
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: .zero)
        initialise()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private properties
    private let text: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        view.textAlignment = .center
        return view
    }()
}

// MARK: Private methods
private extension EmojiCollectionViewCell {
    func initialise() {
        contentView.addSubview(text)
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        
        NSLayoutConstraint.activate([
            text.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            text.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
