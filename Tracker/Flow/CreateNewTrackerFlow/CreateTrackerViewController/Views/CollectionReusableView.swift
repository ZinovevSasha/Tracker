import UIKit

final class CollectionReusableView: UICollectionReusableView {
    // MARK: Public
    func configure(with info: String) {
        text.text = info
    }
    
    // MARK: Private properties
    private let text: UILabel = {
        let view = UILabel()
        view.font = .bold19
        return view
    }()
    
    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: .zero)
        initialise()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
}

// MARK: Private methods
private extension CollectionReusableView {
    func initialise() {
        addSubviews(text)
        
        NSLayoutConstraint.activate([
            text.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            text.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
