import UIKit

protocol FrameViewControllerProtocol {
    var container: UIView { get }
    var buttonLeft: ActionButton? { get }
    var buttonRight: ActionButton? { get }
    var buttonCenter: ActionButton? { get }
    func handleButtonLeftTap()
    func handleButtonRightTap()
    func handleButtonCenterTap()
}

class FrameViewController: UIViewController, FrameViewControllerProtocol {
    // MARK: - Public
    // Container to show data you want in between
    // only container and buttons are Public
    let container = UIView()
    
    // type of button
    let buttonLeft: ActionButton?
    let buttonRight: ActionButton?
    let buttonCenter: ActionButton?
    
    // MARK: - Private
    // Title of screen
    private let screenTitle: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .medium16
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// Buttons at the bottom
    private let screenButtons: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    // MARK: - Init
    init(title: String, buttonLeft: ActionButton?, buttonRight: ActionButton?) {
        self.screenTitle.text = title
        self.buttonLeft = buttonLeft
        self.buttonRight = buttonRight
        self.buttonCenter = nil
        super.init(nibName: nil, bundle: nil)
    }
    
    init(title: String, buttonCenter: ActionButton?) {
        self.screenTitle.text = title
        self.buttonLeft = nil
        self.buttonRight = nil
        self.buttonCenter = buttonCenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIConstants
    private enum UIConstants {
        static let leading: CGFloat = 16
        static let trailing: CGFloat = -16
        static let bottom: CGFloat = -24
        static let nameLabelTopInset: CGFloat = 27
        static let containerToTitleInset: CGFloat = 14
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setConstraints()
    }
        
    @objc func handleButtonLeftTap() {}
    @objc func handleButtonRightTap() {}
    @objc func handleButtonCenterTap() {}
}
    
private extension FrameViewController {
    func setupViews() {
        buttonLeft?.addTarget(self, action: #selector(handleButtonCenterTap), for: .touchUpInside)
        buttonRight?.addTarget(self, action: #selector(handleButtonCenterTap), for: .touchUpInside)
        buttonCenter?.addTarget(self, action: #selector(handleButtonCenterTap), for: .touchUpInside)
        view.backgroundColor = .myWhite
        view.addSubview(screenTitle)
        view.addSubview(container)
        view.addSubview(screenButtons)
        container.translatesAutoresizingMaskIntoConstraints = false
        
        if let buttonLeft, let buttonRight  {
            screenButtons.addArrangedSubview(buttonLeft)
            screenButtons.addArrangedSubview(buttonRight)
            buttonLeft.heightAnchor.constraint(equalToConstant: .buttonsHeight)
        }
        if let buttonCenter {
            screenButtons.addArrangedSubview(buttonCenter)
            buttonCenter.heightAnchor.constraint(equalToConstant: .buttonsHeight)
        }
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            screenTitle.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: UIConstants.nameLabelTopInset),
            screenTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            container.topAnchor.constraint(
                equalTo: screenTitle.bottomAnchor,
                constant: UIConstants.containerToTitleInset),
            container.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: UIConstants.leading),
            container.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: UIConstants.trailing),
            container.bottomAnchor.constraint(equalTo: screenButtons.topAnchor),
            
            screenButtons.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: UIConstants.leading),
            screenButtons.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: UIConstants.trailing),
            screenButtons.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: UIConstants.bottom),            
            screenButtons.heightAnchor.constraint(equalToConstant: .buttonsHeight)
        ])
    }
}
