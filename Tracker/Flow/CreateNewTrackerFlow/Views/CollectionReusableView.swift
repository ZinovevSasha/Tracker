//
//  CollectionReusableView.swift
//  CompositionalLayout
//
//  Created by Александр Зиновьев on 01.04.2023.
//

import UIKit

final class CollectionReusableView: UICollectionReusableView {
    static let identifier = String(describing: CollectionReusableView.self)
    // MARK: Public
    func configure(with info: String) {
        text.text = info
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
    private let text: UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
}

// MARK: Private methods
private extension CollectionReusableView {
    func initialise() {
        addSubview(text)
        
        NSLayoutConstraint.activate([
            text.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            text.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
