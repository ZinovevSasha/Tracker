import UIKit

final class EmojiCell: UICollectionViewCell, Highilable {
    // MARK: - Public
    func configure(with emoji: String) {
        text.text = emoji
    }
    
    var content: String? {
        text.text
    }
    
    func highlightUnhighlight() {
        cellState.toggle()
    }
    
    // MARK: - Cell State
    private var cellState = State.unselected {
        didSet {
            configureCell()
        }
    }
    
    // MARK: - Private properties
    private let text: UILabel = {
        let view = UILabel()
        view.font = .bold32
        view.textAlignment = .center
        return view
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
}

// MARK: Private methods
private extension EmojiCell {
    func setupUI() {
        contentView.addSubviews(text)
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        
        NSLayoutConstraint.activate([
            text.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            text.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configureCell() {
        switch cellState {
        case .selected:
            contentView.backgroundColor = .myLightGrey
        case .unselected:
            contentView.backgroundColor = .clear
        }
    }
}
