import UIKit

class SearchCollectionViewCell: UICollectionViewCell {
    static let identifier = String(describing: SearchCollectionViewCell.self)
    // MARK: Public
    func configure(with info: CreateTrackerModel) {
        textField.placeholder = info.title
    }
    
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
private extension SearchCollectionViewCell {
    func initialise() {
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
