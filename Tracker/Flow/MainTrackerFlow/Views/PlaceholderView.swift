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
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialise()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
    
    // MARK: - UIConstants
    private enum UIConstants {
        static let placeholderText: CGFloat = 12
        static let textToImageOffset: CGFloat = 8
    }
    
    // MARK: - Private properties
    private let placeholderImageView: UIImageView = {
        let view = UIImageView()
        view.image = .placeholderTracker
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let placeholderText: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = UIFont.systemFont(ofSize: UIConstants.placeholderText, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
}

// MARK: - Private methods
private extension PlaceholderView {
    func initialise() {
        addSubviews(placeholderText, placeholderImageView)
        
        NSLayoutConstraint.activate([
        placeholderImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
        placeholderImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
        
        placeholderText.centerXAnchor.constraint(equalTo: centerXAnchor),
        placeholderText.topAnchor.constraint(
            equalTo: placeholderImageView.bottomAnchor,
            constant: UIConstants.textToImageOffset)
        ])
    }
}

