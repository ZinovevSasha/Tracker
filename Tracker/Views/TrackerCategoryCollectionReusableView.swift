import UIKit

class TrackerCategoryHeaderView: UICollectionReusableView {
    static let identifier = String(describing: TrackerCategoryHeaderView.self)
    // MARK: - Public
    func configure(with info: TrackerCategory) {
        categoryLabel.text = info.header
    }
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: .zero)
        initialise()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
    
    // MARK: - Private properties
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
}

// MARK: - Private methods
private extension TrackerCategoryHeaderView {
    func initialise() {
        addSubview(categoryLabel)
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            categoryLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            categoryLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            categoryLabel.topAnchor.constraint(equalTo: topAnchor),
            categoryLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
}
