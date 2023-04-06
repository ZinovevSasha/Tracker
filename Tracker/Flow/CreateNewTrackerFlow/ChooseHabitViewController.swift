import UIKit

final class ChooseTrackerViewController: UIViewController {
    // MARK: Private properties
    private let nameOfScreenLabel: UILabel = {
        let label = UILabel()
        label.text = "Создание трекера"
        label.font = UIFont.systemFont(ofSize: UIConstants.textFontSize)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = UIConstants.stackViewSpacing
        return view
    }()
    
    private let habitButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont.systemFont(
            ofSize: UIConstants.textFontSize,
            weight: .medium
        )
        button.tintColor = UIColor.myWhite
        button.backgroundColor = .myBlack
        button.setTitle("Привычка", for: .normal)
        button.layer.cornerRadius = UIConstants.textFontSize
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let irregularEventButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont.systemFont(
            ofSize: UIConstants.textFontSize,
            weight: .medium
        )
        button.tintColor = UIColor.myWhite
        button.backgroundColor = .myBlack
        button.setTitle("Нерегулярные событие", for: .normal)
        button.layer.cornerRadius = UIConstants.buttonsCornerRadius
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: UIConstants
    private enum UIConstants {
        static let nameLabelTopInset: CGFloat = 27
        static let stackViewSpacing: CGFloat = 16
        static let buttonsCornerRadius: CGFloat = 16
        static let stackLeadingInset: CGFloat = 20
        static let stackTrailingInset: CGFloat = -20
        static let buttonsHeight: CGFloat = 60
        static let textFontSize: CGFloat = 16
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialise()
        setConstraints()
    }
    
    // MARK: - Private @objc target action methods
    @objc private func habitButtonTaped() {
        let vc = TrackerCreationViewController()
        present(vc, animated: true)
    }
    
    @objc private func irregularEventButtonTapped() {
        print("irregularEventButtonTapped")
    }
}

// MARK: - Private methods
private extension ChooseTrackerViewController {
    func initialise() {
        habitButton.addTarget(self, action: #selector(habitButtonTaped), for: .touchUpInside)
        irregularEventButton.addTarget(self, action: #selector(irregularEventButtonTapped), for: .touchUpInside)
        stackView.addArrangedSubviews(habitButton, irregularEventButton)
        view.addSubviews(nameOfScreenLabel, stackView)
        view.backgroundColor = .myWhite
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            nameOfScreenLabel.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: UIConstants.nameLabelTopInset),
            nameOfScreenLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            habitButton.heightAnchor.constraint(equalToConstant: UIConstants.buttonsHeight),
            irregularEventButton.heightAnchor.constraint(
                equalToConstant: UIConstants.buttonsHeight),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: UIConstants.stackLeadingInset),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: UIConstants.stackTrailingInset),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}
