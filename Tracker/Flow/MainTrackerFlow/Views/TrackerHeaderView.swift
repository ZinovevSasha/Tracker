import UIKit

protocol TrackerHeaderViewDelegate: AnyObject {
    func datePickerValueChanged(date: Date)
    func handlePlusButtonTap()
}

final class TrackerHeaderView: UIView {
    // MARK: - Delegate
    weak var delegate: TrackerHeaderViewDelegate?
    
    // MARK: - Private properties
    private let plusButton: ExtendedButton = {
        let button = ExtendedButton(type: .system)
        button.setImage(.plus, for: .normal)
        button.tintColor = .myBlack
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let trackerLabel: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.font = .bold34
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        datePicker.locale = Locale(identifier: "ru")
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.tintColor = .systemBlue
        datePicker.backgroundColor = .myWhite
        datePicker.layer.cornerRadius = UIConstants.datePickerCornerRadius
        datePicker.layer.masksToBounds = true
        return datePicker
    }()
    
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.alignment = .center
        view.distribution = .fillProportionally
        return view
    }()
    
    // MARK: - UIConstants
    private enum UIConstants {
        static let trackerToPlusButtonOffset: CGFloat = 13
        static let trackerToDatePickerOffset: CGFloat = -12
        static let datePickerWidth: CGFloat = 100
        static let datePickerCornerRadius: CGFloat = 8
    }
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialise()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("")
    }
    
    // MARK: - Private @objc target action methods
    @objc private func datePickerValueChanged() {
        delegate?.datePickerValueChanged(date: datePicker.date)
    }
    
    @objc private func handlePlusButtonTap() {       
        delegate?.handlePlusButtonTap()
    }
}

// MARK: - Private methods
private extension TrackerHeaderView {
    func initialise() {
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        plusButton.addTarget(self, action: #selector(handlePlusButtonTap), for: .touchUpInside)
        stackView.addArrangedSubview(trackerLabel)
        stackView.addArrangedSubview(datePicker)
        addSubviews(plusButton, stackView)
    }
    
    func setConstraints() {
        let plusButtonConstraints = [
            plusButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            plusButton.topAnchor.constraint(equalTo: topAnchor)
        ]
        let datePickerConstraints = [
            datePicker.widthAnchor.constraint(equalToConstant: UIConstants.datePickerWidth)
        ]
        let stackConstraints = [
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(
                equalTo: plusButton.bottomAnchor,
                constant: UIConstants.trackerToPlusButtonOffset),
            stackView.heightAnchor.constraint(equalToConstant: 41)
        ]
        
        NSLayoutConstraint.activate(
            plusButtonConstraints +
            datePickerConstraints +
            stackConstraints
        )
    }
}
