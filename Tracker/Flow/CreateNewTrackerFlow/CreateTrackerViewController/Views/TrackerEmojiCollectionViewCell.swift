import UIKit

final class TrackerEmojiCollectionViewCell: UICollectionViewCell {
    // MARK: - Public
    func configure(with info: String) {
        text.text = info
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
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .bold32
        view.textAlignment = .center
        return view
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: .zero)
        initialise()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
}

// MARK: Private methods
private extension TrackerEmojiCollectionViewCell {
    func initialise() {
        contentView.addSubview(text)
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
