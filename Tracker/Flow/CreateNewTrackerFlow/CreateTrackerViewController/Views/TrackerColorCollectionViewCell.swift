import UIKit

final class TrackerColorCollectionViewCell: UICollectionViewCell {
    // MARK: Public
    func configure(with info: String) {
        colorView.backgroundColor = UIColor(named: info)
    }
    
    func addOrRemoveBorders() {
        cellState.toggle()
    }
    
    // MARK: - Cell State
    private var cellState = State.unselected {
        didSet {
            configureCell()
        }
    }

    // MARK: Private properties
    private let text: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .bold32
        return view
    }()
    
    private let colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let highlightedImage: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
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
private extension TrackerColorCollectionViewCell {
    func initialise() {
        contentView.addSubview(colorView)
        contentView.addSubview(highlightedImage)
        
        NSLayoutConstraint.activate([
            highlightedImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            highlightedImage.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            
            colorView.heightAnchor.constraint(equalToConstant: 40),
            colorView.widthAnchor.constraint(equalToConstant: 40),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }
    
    func configureCell() {
        switch cellState {
        case .selected:
            let image = UIImage.borderCell?
                .withTintColor(colorView.backgroundColor ?? .clear, renderingMode: .alwaysOriginal)
            UIView.animate(withDuration: 0.3, delay: 0) {
                self.highlightedImage.image = image
            }
        case .unselected:
            highlightedImage.image = nil
        }
    }
}
