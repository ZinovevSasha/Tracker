import UIKit

final class MyTableViewCell: UITableViewCell {
    // MARK: - Public
    func configure(with info: RowData) {
        myTextLabel.text = info.title
        supplementaryTextLabel.text = info.subtitle
    }
    
    // MARK: - Private properties
    private let accessoryImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage.chevron?
            .withTintColor(.myGray ?? .gray, renderingMode: .alwaysOriginal)
        return view
    }()
    
    private let myTextLabel: UILabel = {
        let view = UILabel()
        view.textColor = .myBlack
        view.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        return view
    }()
    
    private let supplementaryTextLabel: UILabel = {
        let view = UILabel()
        view.textColor = .myGray
        view.font = .regular17
        return view
    }()
    
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .leading
        view.spacing = 2
        view.distribution = .fill
        return view
    }()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
}

// MARK: - Private methods
private extension MyTableViewCell {
    func setupUI() {
        contentView.addSubviews(stackView, accessoryImageView)
        contentView.backgroundColor = .myBackground
        selectionStyle = .none
        stackView.addSubviews(myTextLabel, supplementaryTextLabel)        
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: .leadingInset),
            stackView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 15),
            stackView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -14),
            stackView.trailingAnchor.constraint(equalTo: accessoryImageView.leadingAnchor, constant: -10),

            accessoryImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            accessoryImageView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -24)
        ])
    }
}
