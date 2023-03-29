//
//  TrackerCollectionViewCell.swift
//  Tracker
//
//  Created by Александр Зиновьев on 28.03.2023.
//

import UIKit

final class TrackerCollectionViewCell: UICollectionViewCell {
    static let identifier = String(describing: TrackerCollectionViewCell.self)
    // MARK: - Public
    func configure(with info: Tracker) {
        emojiLabel.text = info.emoji
        trackerNameLabel.text = info.name
        trackedDaysLabel.text = "\(info.daysTracked) days"
        trackerContainerView.backgroundColor = info.color
        addButton.backgroundColor = info.color
    }
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: .zero)
        initialise()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
    
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
        static let emojiFontSize: CGFloat = 12
        static let stackInsetLeading: CGFloat = 12
        static let stackInsetTrailing: CGFloat = -12
        static let stackHeight: CGFloat = 58
        static let stackViewSpacing: CGFloat = 8
        static let buttonSize: CGFloat = 34
    }
    
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
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: UIConstants.trackerNameLabelFontSize)
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.28
        label.attributedText = NSMutableAttributedString(
            string: "",
            attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle]
        )
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
        
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: UIConstants.emojiFontSize)
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
        let image = UIImage(systemName: "plus")?.withRenderingMode(.alwaysOriginal).withTintColor(.myWhite)
        button.setImage(image, for: .normal)
        button.imageView?.layer.transform = CATransform3DMakeScale(0.6, 0.6, 0.6)
        button.layer.cornerRadius = UIConstants.buttonSize / 2
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.alignment = .center
        view.spacing = UIConstants.stackViewSpacing
        view.distribution = .fill
        return view
    }()
}

// MARK: - Private methods
private extension TrackerCollectionViewCell {
    func initialise() {
        emojiContainerView.addSubview(emojiLabel)
        trackerContainerView.addSubviews(emojiContainerView, trackerNameLabel)
        stackView.addArrangedSubview(trackedDaysLabel)
        stackView.addArrangedSubview(addButton)
        contentView.addSubviews(trackerContainerView, stackView)
        addButton.addTarget(self, action: #selector(handleAddButtonTap), for: .touchUpInside)
    }
    
    @objc func handleAddButtonTap() {
        print("tapped")
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
            emojiLabel.leadingAnchor.constraint(
                equalTo: emojiContainerView.leadingAnchor,
                constant: UIConstants.emojiLeadingInset),
            emojiLabel.topAnchor.constraint(
                equalTo: emojiContainerView.topAnchor,
                constant: UIConstants.emojiTopInset),
            emojiLabel.widthAnchor.constraint(equalToConstant: UIConstants.emojiWidth),
            emojiLabel.heightAnchor.constraint(equalToConstant: UIConstants.emojiHeight)
        ]
        
        let trackNameConstraints = [
            trackerNameLabel.leadingAnchor.constraint(
                equalTo: trackerContainerView.leadingAnchor,
                constant: UIConstants.trackerNameLabelInset),
            trackerNameLabel.bottomAnchor.constraint(
                equalTo: trackerContainerView.bottomAnchor,
                constant: (-UIConstants.trackerNameLabelInset)),
            trackerNameLabel.trailingAnchor.constraint(
                equalTo: trackerContainerView.trailingAnchor,
                constant: (-UIConstants.trackerNameLabelInset)),
            trackerNameLabel.heightAnchor.constraint(equalToConstant: UIConstants.trackerNameLabelHeight)
        ]

        let stackConstraints = [
            stackView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: UIConstants.stackInsetLeading),
            stackView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: UIConstants.stackInsetTrailing),
            stackView.topAnchor.constraint(equalTo: trackerContainerView.bottomAnchor),
            stackView.heightAnchor.constraint(equalToConstant: UIConstants.stackHeight)
        ]
        
        let buttonConstraints = [
            addButton.heightAnchor.constraint(equalToConstant: UIConstants.buttonSize),
            addButton.widthAnchor.constraint(equalToConstant: UIConstants.buttonSize)
        ]
        
        NSLayoutConstraint.activate(
            trackerContainerViewConstraints +
            emojiContainerConstraints +
            emojiConstraints +
            trackNameConstraints +
            stackConstraints +
            buttonConstraints
        )
    }
}
