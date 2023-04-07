//
//  OtherCollectionViewCell.swift
//  CompositionalLayout
//
//  Created by Александр Зиновьев on 01.04.2023.
//

import UIKit

final class TrackerColorCollectionViewCell: UICollectionViewCell {
    static let identifier = String(describing: TrackerColorCollectionViewCell.self)
    // MARK: Public
    func configureSelection() {
        let image = UIImage.borderCell?
            .withTintColor(colorView.backgroundColor ?? .clear, renderingMode: .alwaysOriginal)
        highlightedImage.image = image
    }
    
    func configureDeselection() {
        highlightedImage.image = nil
    }
    
    func configure(with info: String) {
        colorView.backgroundColor = UIColor(named: info)
    }
    
    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: .zero)
        initialise()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selection
    private enum EmojiState {
        case selected
        case deselected
    }
    
    // MARK: Private properties
    private let text: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        return view
    }()
    
    private let colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let highlightedImage: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
}

// MARK: Private methods
private extension TrackerColorCollectionViewCell {
    func initialise() {
        contentView.addSubview(colorView)
        contentView.addSubview(highlightedImage)
        
        NSLayoutConstraint.activate([
            highlightedImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            highlightedImage.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            
            colorView.heightAnchor.constraint(equalToConstant: 40),
            colorView.widthAnchor.constraint(equalToConstant: 40),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }
}
