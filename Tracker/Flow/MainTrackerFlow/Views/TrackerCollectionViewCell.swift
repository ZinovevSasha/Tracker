import UIKit

protocol TrackerCollectionViewCellDelegate: AnyObject {
    func didMarkTrackerCompleted(for cell: TrackerCollectionViewCell)
    func didAttachTracker(for cell: TrackerCollectionViewCell)
    func didDeleteTracker(for cell: TrackerCollectionViewCell)
    func didUpdateTracker(for cell: TrackerCollectionViewCell)
    func didUnattachTracker(for cell: TrackerCollectionViewCell)
}

final class TrackerCollectionViewCell: UICollectionViewCell {
    // MARK: - Public
    func configure(with info: Tracker?) {
        guard let info = info else { return }
        let color = UIColor(hexString: info.color)
        emojiLabel.text = info.emoji
        trackerNameLabel.text = info.name
        attachedSighView.isHidden = !info.isAttached
        trackerContainerView.backgroundColor = color
        addButton.backgroundColor = color
        isAttached = info.isAttached
    }
            
    func configure(with trackedDays: Int?, isCompleted: Bool?) {
        guard let trackedDays = trackedDays, let isCompleted = isCompleted else { return }
        trackedDaysLabel.text = Localized.Main.numberOf(days: trackedDays)
        if isCompleted {
            buttonState = .selected
        } else {
            buttonState = .unselected
        }
    }
    
    // MARK: - Delegate
    weak var delegate: TrackerCollectionViewCellDelegate?
    
    // MARK: - Private properties
    private let trackerContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = UIConstants.trackerCornerRadius
        view.layer.masksToBounds = true
        view.layer.borderWidth = UIConstants.trackerBorderWidth
        view.layer.borderColor = UIColor.myCellBorderColor?.cgColor
        view.backgroundColor = .myBlue
        return view
    }()
    
    private let trackerNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .myWhite
        label.font = .medium12
        label.numberOfLines = .zero
        label.textAlignment = .left
        return label
    }()
        
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = .zero
        label.font = .medium16
        label.textAlignment = .left
        return label
    }()
    
    private let emojiContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .myTranspatent
        view.layer.cornerRadius = UIConstants.emojiContainerSize / 2
        view.layer.masksToBounds = true
        return view
    }()
    
    private let trackedDaysLabel: UILabel = {
        let label = UILabel()
        label.textColor = .myBlack
        return label
    }()
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = UIConstants.buttonSize / 2
        button.layer.masksToBounds = true
        return button
    }()
    
    private let attachedSighView: UIImageView = {
        let imageView = UIImageView(image: .pin)
        imageView.isHidden = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // MARK: UIConstants
    private enum UIConstants {
        static let trackerCornerRadius: CGFloat = 16
        static let trackerBorderWidth: CGFloat = 1
        static let trackerMainBodyHeight: CGFloat = 90
        static let emojiContainerInset: CGFloat = 12
        static let trackerNameLabelInset: CGFloat = 12
        static let trackerNameLabelHeight: CGFloat = 34
        static let emojiContainerSize: CGFloat = 24
        static let emojiHeight: CGFloat = 22
        static let emojiWidth: CGFloat = 16
        static let emojiLeadingInset: CGFloat = 4
        static let emojiTopInset: CGFloat = 1
        static let stackInsetLeading: CGFloat = 12
        static let stackInsetTrailing: CGFloat = -12
        static let stackHeight: CGFloat = 58
        static let stackViewSpacing: CGFloat = 8
        static let buttonSize: CGFloat = 34
    }
    
    // MARK: - Button State
    private var buttonState = State.unselected {
        didSet {
            configureButton()
        }
    }
    
    private var isAttached: Bool = false
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
    
    // MARK: - Private @objc target action methods
    @objc private func handleAddButtonTap() {
        delegate?.didMarkTrackerCompleted(for: self)
    }
}

// MARK: - Private methods
private extension TrackerCollectionViewCell {
    func setupUI() {
        emojiContainerView.addSubviews(emojiLabel)
        trackerContainerView.addSubviews(emojiContainerView, trackerNameLabel, attachedSighView)
        contentView.addSubviews(trackerContainerView, trackedDaysLabel, addButton)
        addButton.addTarget(self, action: #selector(handleAddButtonTap), for: .touchUpInside)
        let contextMenu = UIContextMenuInteraction(delegate: self)
        trackerContainerView.addInteraction(contextMenu)
    }
    
    func setupLayout() {
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

        let attachSignConstraints = [
            attachedSighView.trailingAnchor.constraint(equalTo: trackerContainerView.trailingAnchor, constant: -12),
            attachedSighView.topAnchor.constraint(equalTo: trackerContainerView.topAnchor, constant: 18)
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
            attachSignConstraints +
            labelConstraints +
            buttonConstraints
        )
    }
    
    func configureButton() {
        switch buttonState {
        case .selected:
            let image = UIImage.done?.withRenderingMode(.alwaysOriginal).withTintColor(.myWhite ?? .white)
            addButton.setImage(image, for: .normal)
            addButton.alpha = 0.3
        case .unselected:
            let image = UIImage.plus?.withRenderingMode(.alwaysOriginal).withTintColor(.myWhite ?? .white)
            addButton.setImage(image, for: .normal)
            addButton.alpha = 1            
        }
    }
}

extension TrackerCollectionViewCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        let title = isAttached ? "Unattach" : "Attach"
        let attachAction = UIAction(title: title) { [weak self] _ in
            guard let self = self else { return }
            if isAttached {
                isAttached = false
                self.delegate?.didUnattachTracker(for: self)
            } else {
                isAttached = true
                self.delegate?.didAttachTracker(for: self)
            }
        }
        let modifyAction = UIAction(title: "Update") { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.didUpdateTracker(for: self)
        }
        let deleteAction = UIAction(title: "Delete", attributes: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.didDeleteTracker(for: self)
        }
        let menu = UIMenu(title: "", children: [attachAction, modifyAction, deleteAction])
        
        return UIContextMenuConfiguration(
            identifier: nil, previewProvider: nil) { _ in
            return menu
        }
    }
}
