import UIKit

final class CollectionReusableView: UICollectionReusableView {
    // MARK: Public
    func configure(with info: String) {
        text.text = info
    }
    
    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: .zero)
        initialise()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Private properties
    private let text: UILabel = {
        let view = UILabel()
        view.font = .bold19
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
}

// MARK: Private methods
private extension CollectionReusableView {
    func initialise() {
        addSubview(text)
        
        NSLayoutConstraint.activate([
            text.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            text.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
