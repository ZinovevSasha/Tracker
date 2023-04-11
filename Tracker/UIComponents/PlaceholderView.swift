//
//  PlaceholderView.swift
//  Tracker
//
//  Created by Александр Зиновьев on 01.04.2023.
//

import UIKit

final class PlaceholderView: UIView {
    // MARK: - Public
    func hide() {
        self.isHidden = true
    }
    
    func unhide() {
        self.isHidden = false
    }
    
    func setImageAndText(placeholder: UIImage.Placeholder, text: String) {
        placeholderImageView.image = placeholder.image
        placeholderText.text = text
    }
    
    // MARK: - UIConstants
    private enum UIConstants {
        static let placeholderText: CGFloat = 12
        static let textToImageOffset: CGFloat = 8
        static let imageSize: CGFloat = 80
        static let halfImageSize = imageSize / 2
    }
    
    // MARK: - Private properties
    private let placeholderImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .center
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let placeholderText: UILabel = {
        let label = UILabel()
        label.font = .medium12
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init
    init(placeholder: UIImage.Placeholder, text: String) {
        placeholderImageView.image = placeholder.image
        placeholderText.text = text
        super.init(frame: .zero)
        initialise()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
}

// MARK: - Private methods
private extension PlaceholderView {
    func initialise() {
        addSubviews(placeholderText, placeholderImageView)
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
        placeholderImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
        placeholderImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
        placeholderImageView.heightAnchor.constraint(equalToConstant: UIConstants.imageSize),
        placeholderImageView.widthAnchor.constraint(equalToConstant: UIConstants.imageSize),
        
        placeholderText.centerXAnchor.constraint(equalTo: centerXAnchor),
        placeholderText.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
        placeholderText.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
        placeholderText.topAnchor.constraint(
            equalTo: placeholderImageView.bottomAnchor,
            constant: UIConstants.textToImageOffset)
        ])
    }
}
