import UIKit

final class TrackerHeader: UICollectionReusableView {
    static let identifier = String(describing: TrackerHeader.self)
    // MARK: - Public
    func configure(with header: String) {
        categoryLabel.text = header
    }
    
    // MARK: - Private properties
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = .bold19
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - UIConstants
    private enum UIConstants {
        static let categoryLabelLeadingInset: CGFloat = 28
        static let categoryLabelBottomInset: CGFloat = -12
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
}

// MARK: - Private methods
private extension TrackerHeader {
    func initialise() {
        addSubview(categoryLabel)
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            categoryLabel.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: UIConstants.categoryLabelLeadingInset
            ),
            categoryLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            categoryLabel.topAnchor.constraint(equalTo: topAnchor),
           
        ])
    }
}
