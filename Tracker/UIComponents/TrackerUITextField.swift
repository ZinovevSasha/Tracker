import UIKit

protocol TrackerUITextFieldDelegate: AnyObject {
    func textDidEntered(in: TrackerUITextField, text: String)
}

final class TrackerUITextField: UIView {
    // MARK: - Delegate
    weak var delegate: TrackerUITextFieldDelegate?
    
    // MARK: - Private properties
    private var textField: UITextField = {
        let view = UITextField()
        // Style
        view.font = .regular17
        view.textColor = .myBlack
        view.backgroundColor = .myBackground
        view.layer.cornerRadius = .cornerRadius
        view.layer.masksToBounds = true
        
        // Insets
        let rect = CGRect(x: .zero, y: .zero, width: 16, height: view.frame.height)
        let insetView = UIView(frame: rect)
        view.leftView = insetView
        view.leftViewMode = .always
        view.rightView = insetView
        view.rightViewMode = .always
        
        // constraints
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Init
    init(text: String) {
        textField.placeholder = text
        super.init(frame: .zero)
        initialise()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private Methods
private extension TrackerUITextField {
    func initialise() {
        addSubview(textField)
        textField.delegate = self
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor),
            textField.topAnchor.constraint(equalTo: topAnchor),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor),
            textField.heightAnchor.constraint(equalToConstant: .cellHeight)
        ])
    }
}

// MARK: - UITextFieldDelegate
extension TrackerUITextField: UITextFieldDelegate {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        delegate?.textDidEntered(in: self, text: updatedText)
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
         // Hide the keyboard when the return button is pressed
         textField.resignFirstResponder()
         return true
     }
}
