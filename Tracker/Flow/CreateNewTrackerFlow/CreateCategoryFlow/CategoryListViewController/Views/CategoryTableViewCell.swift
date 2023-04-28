import UIKit

final class CategoryTableViewCell: UITableViewCell {
    // MARK: - Public
    func configure(with info: String, setImage: Bool) {
        categoryName.text = info
        if setImage {
            selectedCategory.image = .checkmarkBlue
        }
    }
    
    func configureImage() {
        selectedCategory.image = .checkmarkBlue
    }
    
    // MARK: - Private properties
    private let categoryName: UILabel = {
        let view = UILabel()
        view.textColor = .myBlack
        view.font = .regular17
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let selectedCategory: UIImageView = {
        let view = UIImageView()
        view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alignment = .center
        view.distribution = .fill
        return view
    }()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialise()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
}

// MARK: - Private methods
private extension CategoryTableViewCell {
    func initialise() {
        stackView.addSubviews(categoryName, selectedCategory)
        contentView.addSubviews(stackView)
        contentView.backgroundColor = .myBackground
        selectionStyle = .none
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: .leadingInset),
            stackView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: .trailingInset),
            stackView.topAnchor.constraint(
                equalTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor)
        ])
    }
}
