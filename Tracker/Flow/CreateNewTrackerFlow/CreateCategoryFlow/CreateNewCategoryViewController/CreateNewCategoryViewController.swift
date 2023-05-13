import UIKit

protocol CreateNewCategoryViewControllerDelegate: AnyObject {
    func categoryNameDidEntered(categoryName name: String)
    func isNameAvailable(name: String) -> Bool?
}

final class CreateNewCategoryViewController: FrameViewController {
    // MARK: - Delegate
    weak var delegate: CreateNewCategoryViewControllerDelegate?
    
    // MARK: - Private properties
    private let textField = TrackerUITextField(text: "Введите название категории")
    
    private var mainStackView: UIStackView = {
        let view = UIStackView()
        view.alignment = .fill
        view.axis = .vertical        
        return view
    }()
    
    private var warningCharactersLabel: UILabel = {
        let view = UILabel()
        view.text = "Такая категория уже есть ☹️"
        view.numberOfLines = .zero
        view.font = .regular17
        view.textColor = .myRed
        view.alpha = .zero
        view.textAlignment = .center
        return view
    }()
    
    // MARK: Lifecicle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
    }
    
    // MARK: - Category name
    private var categoryName: String?
    
    // MARK: - Init
    init() {
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
    func setupUI() {
        container.addSubviews(mainStackView)
        mainStackView.addSubviews(textField)
        mainStackView.setCustomSpacing(8, after: textField)
        textField.delegate = self
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            mainStackView.topAnchor.constraint(equalTo: container.topAnchor, constant: .topInsetFromTitle)
        ])
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            textField.topAnchor.constraint(equalTo: container.topAnchor, constant: .topInsetFromTitle)
        ])
    }
}

// MARK: - TrackerUITextFieldDelegate
extension CreateNewCategoryViewController: TrackerUITextFieldDelegate {
    func isChangeText(text: String, newLength: Int) -> Bool? {
        guard !text.isEmpty else {
            // if text isEmpty
            updateCategoryName(nil)
            buttonCenter?.colorType = .grey
            removeWarningLabel()
            return true
        }
        // if there is no such category name exist
        if delegate?.isNameAvailable(name: text) ?? false {
            updateCategoryName(text)
            buttonCenter?.colorType = .black
            removeWarningLabel()
        } else {
            updateCategoryName(nil)
            buttonCenter?.colorType = .grey
            addWarningLabel()
        }
        return true
    }
    
    // Private metods
    private func addWarningLabel() {
        mainStackView.addArrangedSubview(warningCharactersLabel)
        UIView.animate(withDuration: 0.3) {
            self.warningCharactersLabel.alpha = 1
        }
    }
    
    private func removeWarningLabel() {
        mainStackView.removeArrangedSubview(warningCharactersLabel)
        warningCharactersLabel.removeFromSuperview()
        UIView.animate(withDuration: 0.3) {
            self.warningCharactersLabel.alpha = 0
            self.view.layoutIfNeeded()
        }
    }
    
    private func updateCategoryName(_ text: String?) {
        categoryName = text
    }
}
