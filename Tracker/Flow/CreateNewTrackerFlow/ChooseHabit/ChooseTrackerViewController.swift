import UIKit

final class ChooseTrackerViewController: UIViewController {
    // MARK: Private properties
    private let nameOfScreenLabel: UILabel = {
        let label = UILabel()
        label.text = Localized.Choosing.title
        label.font = .medium16
        label.textAlignment = .center
        return label
    }()
    
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = UIConstants.stackViewSpacing
        return view
    }()
    
    let habitButton = ActionButton(
        colorType: .black,
        title: Localized.Choosing.habit)
    
    let irregularEventButton = ActionButton(
        colorType: .black,
        title: Localized.Choosing.irregular)
    
    // MARK: UIConstants
    private enum UIConstants {
        static let nameLabelTopInset: CGFloat = 27
        static let stackViewSpacing: CGFloat = 16
        static let buttonsCornerRadius: CGFloat = 16
        static let stackLeadingInset: CGFloat = 20
        static let stackTrailingInset: CGFloat = -20
        static let buttonsHeight: CGFloat = 60
    }
    
    ///// ASK: where it should be stored?
    var initialInteractivePopGestureRecognizerDelegate: UIGestureRecognizerDelegate?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        // we must set the delegate to nil whether we are popping or pushing to..
        // ..this view controller, thus we set it in viewWillAppear()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        // and every time we leave this view controller we must set the delegate back..
        // ..to what it was originally
        self.navigationController?.interactivePopGestureRecognizer?.delegate = initialInteractivePopGestureRecognizerDelegate
    }
    
    // MARK: - Private @objc target action methods
    @objc private func habitButtonTaped() {
        pushCreateTrackerViewController(kind: .habit)
    }
    
    @objc private func irregularEventButtonTapped() {
        pushCreateTrackerViewController(kind: .ocasional)
    }
    
    private func pushCreateTrackerViewController(kind: Tracker.Kind) {
        let viewModel = CreateTrackerViewModelImpl(trackerKind: kind, tracker: nil, date: nil)
        let vc = CreateTrackerViewController(viewModel: viewModel)
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - Private methods
private extension ChooseTrackerViewController {
    func setupUI() {
        // Add targets
        habitButton.addTarget(
            self, action: #selector(habitButtonTaped), for: .touchUpInside)
        irregularEventButton.addTarget(
            self, action: #selector(irregularEventButtonTapped), for: .touchUpInside)
        
        // Add subviews
        stackView.addSubviews(habitButton, irregularEventButton)
        view.addSubviews(nameOfScreenLabel, stackView)
        view.backgroundColor = .myWhite
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
            nameOfScreenLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: UIConstants.nameLabelTopInset),
            nameOfScreenLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: UIConstants.stackLeadingInset),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: UIConstants.stackTrailingInset),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}
