//
//  CreateNewCategoryViewController.swift
//  Tracker
//
//  Created by Александр Зиновьев on 09.04.2023.
//

import UIKit

protocol CreateNewCategoryViewControllerDelegate: AnyObject {
    func categoryNameDidEntered(categoryName name: String)
}

final class CreateNewCategoryViewController: FrameViewController {
    // MARK: - Delegate
    weak var delegate: CreateNewCategoryViewControllerDelegate?
    
    // MARK: - Private properties
    private let textField = TrackerUITextField(text: "Введите название категории")
    
    // MARK: Lifecicle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialise()
        setConstraints()
    }
    
    // MARK: - Category name
    private var categoryName: String?
    
    // MARK: - Init
    init(categories: [TrackerCategory]) {
        // Super init from base class(with title and buttons at bottom)
        super.init(
            title: "Новая категория",
            buttonCenter: ActionButton(colorType: .grey, title: "Готово")
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
    
    // @objc
    override func handleButtonCenterTap() {
        if let categoryName {
            delegate?.categoryNameDidEntered(categoryName: categoryName)
            dismiss(animated: true)
        } else {
            buttonCenter?.shakeSelf()
        }
    }
}

// MARK: - Private Methods
private extension CreateNewCategoryViewController {
    func initialise() {
        container.addSubview(textField)
        textField.delegate = self
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            textField.topAnchor.constraint(equalTo: container.topAnchor, constant: .topInsetFromTitle),
            textField.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
    }
}

// MARK: - TrackerUITextFieldDelegate
extension CreateNewCategoryViewController: TrackerUITextFieldDelegate {
    func textDidEntered(in: TrackerUITextField, text: String) {
        if text.isEmpty {
            categoryName = nil
            buttonCenter?.colorType = .grey
        } else {
            categoryName = text
            buttonCenter?.colorType = .black
        }
    }
}
