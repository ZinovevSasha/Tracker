import UIKit

final class PlaceholderView: UIView {
    // MARK: - Public
    var state: PlaceholderState = .star {
        didSet {
            updateAppearance()
        }
    }
    
    enum PlaceholderState {
        case invisible, star, noResult, noStatistic, recomendation
    }
    
    // MARK: - UIConstants
    private enum UIConstants {
        static let placeholderText: CGFloat = 12
        static let textToImageOffset: CGFloat = 8
        static let imageSize: CGFloat = 80
        static let halfImageSize = imageSize / 2
    }
    
    // MARK: - Private properties
    private let placeholderImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .center
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let placeholderText: UILabel = {
        let label = UILabel()
        label.font = .medium12
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init
    init() {
        super.init(frame: .zero)
        initialise()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
}

// MARK: - Private methods
private extension PlaceholderView {
    func initialise() {
        addSubviews(placeholderText, placeholderImageView)
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
        placeholderImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
        placeholderImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
        placeholderImageView.heightAnchor.constraint(equalToConstant: UIConstants.imageSize),
        placeholderImageView.widthAnchor.constraint(equalToConstant: UIConstants.imageSize),
        
        placeholderText.centerXAnchor.constraint(equalTo: centerXAnchor),
        placeholderText.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
        placeholderText.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
        placeholderText.topAnchor.constraint(
            equalTo: placeholderImageView.bottomAnchor,
            constant: UIConstants.textToImageOffset)
        ])
    }
    
    func updateAppearance() {
        switch state {
        case .invisible:
            setAlphaToZero()
        case .star:
            setState(image: .star, text: "Что будем отслеживать?")
        case .noResult:
            setState(image: .noResult, text: "Ничего не найдено")
        case .noStatistic:
            setState(image: .noStatistic, text: "Анализировать пока нечего")
        case .recomendation:
            setState(image: .star, text: "Привычки и события\n можно объединить по смыслу")
        }
    }
    
    func setState(image: UIImage.Placeholder, text: String) {
        setAlphaToZero()
        setImageAndText(placeholder: image, text: text)
        setAlphaToOne()
    }
    
    func setImageAndText(placeholder: UIImage.Placeholder, text: String) {
        placeholderImageView.image = placeholder.image
        placeholderText.text = text
    }
    
    func setAlphaToOne() {
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
        }
    }
    
    func setAlphaToZero() {
        UIView.animate(withDuration: 0.3) {
            self.alpha = .zero
        }
    }
}
