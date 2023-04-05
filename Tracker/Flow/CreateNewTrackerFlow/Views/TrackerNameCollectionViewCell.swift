import UIKit

protocol TrackerNameCollectionViewCellDelegate: AnyObject {
    func textChanged(_ text: String)
}

final class TrackerNameCollectionViewCell: UICollectionViewCell {
    static let identifier = String(describing: TrackerNameCollectionViewCell.self)
    // MARK: Public
    func configure(with info: Text) {
        textField.placeholder = info.title
    }
    
    weak var delegate: TrackerNameCollectionViewCellDelegate?
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: .zero)
        initialise()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private properties    
    private let textField: UITextField = {
        let view = UITextField()
        view.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: view.frame.height))
        view.leftViewMode = .always
        view.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: view.frame.height))
        view.rightViewMode = .always
        view.backgroundColor = .myBackground
        view.textColor = .myBlack
        view.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
}

// MARK: Private methods
private extension TrackerNameCollectionViewCell {
    func initialise() {
        textField.delegate = self
        contentView.addSubview(textField)
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: contentView.topAnchor),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            textField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}

extension TrackerNameCollectionViewCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        delegate?.textChanged(updatedText)
        return true
    }
}
