//
//  TrackerCollectionViewCell.swift
//  Tracker
//
//  Created by Александр Зиновьев on 28.03.2023.
//

import UIKit

protocol TrackerCollectionViewCellDelegate: AnyObject {
    func plusButtonTapped(for cell: TrackerCollectionViewCell)
}

enum ButtonState {
    case selected
    case unselected
    
    mutating func toggle() {
        switch self {
        case .selected:
            self = .unselected
        case .unselected:
            self = .selected
        }
    }
}

final class TrackerCollectionViewCell: UICollectionViewCell {
    static let identifier = String(describing: TrackerCollectionViewCell.self)
    // MARK: - Public
    func configure(with info: Tracker) {
        let color = UIColor(named: info.color)
        emojiLabel.text = info.emoji
        trackerNameLabel.text = info.name
        trackerContainerView.backgroundColor = color
        addButton.backgroundColor = color
    }
    
    func configure(with trackedDays: Int) {
        trackedDaysLabel.text = "\(trackedDays) days"
    }
    
    // MARK: - Delegate
    weak var delegate: TrackerCollectionViewCellDelegate?
    
    // MARK: - Private properties
    private let trackerContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = UIConstants.trackerCornerRadius
        view.layer.masksToBounds = true
        view.layer.borderWidth = UIConstants.trackerBorderWidth
        view.layer.borderColor = UIColor.myCellBorderColor.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .myBlue
        return view
    }()
    
    private let trackerNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .myWhite
        label.numberOfLines = .zero
        label.font = UIFont.systemFont(ofSize: UIConstants.trackerNameLabelFontSize)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
        
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = .zero
        label.font = UIFont.systemFont(ofSize: UIConstants.emojiFontSize, weight: .medium)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emojiContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = UIConstants.emojiContainerSize / 2
        view.layer.masksToBounds = true
        view.backgroundColor = .myTranspatent
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let trackedDaysLabel: UILabel = {
        let label = UILabel()
        label.textColor = .myBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = UIConstants.buttonSize / 2
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: UIConstants
    private enum UIConstants {
        static let trackerCornerRadius: CGFloat = 16
        static let trackerBorderWidth: CGFloat = 1
        static let trackerMainBodyHeight: CGFloat = 90
        static let emojiContainerInset: CGFloat = 12
        static let trackerNameLabelInset: CGFloat = 12
        static let trackerNameLabelHeight: CGFloat = 34
        static let trackerNameLabelFontSize: CGFloat = 14
        static let emojiContainerSize: CGFloat = 24
        static let emojiHeight: CGFloat = 22
        static let emojiWidth: CGFloat = 16
        static let emojiLeadingInset: CGFloat = 4
        static let emojiTopInset: CGFloat = 1
        static let emojiFontSize: CGFloat = 14
        static let stackInsetLeading: CGFloat = 12
        static let stackInsetTrailing: CGFloat = -12
        static let stackHeight: CGFloat = 58
        static let stackViewSpacing: CGFloat = 8
        static let buttonSize: CGFloat = 34
    }
    
    // MARK: - Button State
    private var buttonState = ButtonState.unselected {
        didSet {
            configureButton()
        }
    }
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: .zero)
        initialise()
        setConstraints()
        configureButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
    
    // MARK: - Private @objc target action methods
    @objc private func handleAddButtonTap() {
        delegate?.plusButtonTapped(for: self)
        buttonState.toggle()
    }
}

// MARK: - Private methods
private extension TrackerCollectionViewCell {
    func initialise() {
        emojiContainerView.addSubview(emojiLabel)
        trackerContainerView.addSubviews(emojiContainerView, trackerNameLabel)
        contentView.addSubviews(trackerContainerView, trackedDaysLabel, addButton)
        addButton.addTarget(self, action: #selector(handleAddButtonTap), for: .touchUpInside)
    }
    
    func setConstraints() {
        let trackerContainerViewConstraints = [
            trackerContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            trackerContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            trackerContainerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            trackerContainerView.heightAnchor.constraint(equalToConstant: UIConstants.trackerMainBodyHeight)
        ]
        
        let emojiContainerConstraints = [
            emojiContainerView.leadingAnchor.constraint(
                equalTo: trackerContainerView.leadingAnchor,
                constant: UIConstants.emojiContainerInset),
            emojiContainerView.topAnchor.constraint(
                equalTo: trackerContainerView.topAnchor,
                constant: UIConstants.emojiContainerInset),
            emojiContainerView.heightAnchor.constraint(equalToConstant: UIConstants.emojiContainerSize),
            emojiContainerView.widthAnchor.constraint(equalToConstant: UIConstants.emojiContainerSize)
        ]
        
        let emojiConstraints = [
            emojiLabel.centerXAnchor.constraint(equalTo: emojiContainerView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiContainerView.centerYAnchor)
        ]
        
        let trackNameConstraints = [
            trackerNameLabel.leadingAnchor.constraint(
                equalTo: trackerContainerView.leadingAnchor,
                constant: UIConstants.trackerNameLabelInset),
            trackerNameLabel.trailingAnchor.constraint(
                equalTo: trackerContainerView.trailingAnchor,
                constant: -UIConstants.trackerNameLabelInset),
            trackerNameLabel.bottomAnchor.constraint(
                equalTo: trackerContainerView.bottomAnchor,
                constant: (-UIConstants.trackerNameLabelInset)),
            trackerNameLabel.heightAnchor.constraint(equalToConstant: UIConstants.trackerNameLabelHeight)
        ]
        
        let buttonConstraints = [
            addButton.heightAnchor.constraint(equalToConstant: UIConstants.buttonSize),
            addButton.widthAnchor.constraint(equalToConstant: UIConstants.buttonSize),
            addButton.topAnchor.constraint(equalTo: trackerContainerView.bottomAnchor, constant: 8),
            addButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            addButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ]
        
        let labelConstraints = [
            trackedDaysLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            trackedDaysLabel.topAnchor.constraint(equalTo: trackerContainerView.bottomAnchor, constant: 16)
        ]
        
        NSLayoutConstraint.activate(
            trackerContainerViewConstraints +
            emojiContainerConstraints +
            emojiConstraints +
            trackNameConstraints +
            labelConstraints +
            buttonConstraints
        )
    }
    
    func configureButton() {
        switch buttonState {
        case .selected:
            let image = UIImage.done?.withRenderingMode(.alwaysOriginal).withTintColor(.myWhite)
            addButton.setImage(image, for: .normal)
//            addButton.imageView?.layer.transform = CATransform3DMakeScale(1,1,1)
            addButton.alpha = 0.3
        case .unselected:
            let image = UIImage.plus?.withRenderingMode(.alwaysOriginal).withTintColor(.myWhite)
            addButton.setImage(image, for: .normal)
//            addButton.imageView?.layer.transform = CATransform3DMakeScale(0.6, 0.6, 0.6)
            addButton.alpha = 1
        }
    }
}
