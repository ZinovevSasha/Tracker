import UIKit

protocol CreateNewCategoryViewControllerDelegate: AnyObject {
    func categoryNameDidEntered(categoryName name: String)
}

final class CreateNewCategoryViewController: FrameViewController {
    // MARK: - Delegate
    weak var delegate: CreateNewCategoryViewControllerDelegate?
    
    // MARK: - Private properties
    private let textField = TrackerUITextField(text: "Введите название категории")
    private let containerForTextField = UIView()
    
    // MARK: Lifecicle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialise()
        setConstraints()
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
    func initialise() {
        containerForTextField.addSubview(textField)
        containerForTextField.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(containerForTextField)
        textField.delegate = self
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            containerForTextField.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            containerForTextField.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            containerForTextField.topAnchor.constraint(equalTo: container.topAnchor, constant: .topInsetFromTitle),
            containerForTextField.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            
            textField.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            textField.topAnchor.constraint(equalTo: container.topAnchor, constant: .topInsetFromTitle),
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
