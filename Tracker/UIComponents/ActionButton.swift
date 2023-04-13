import UIKit

// MARK: - State
enum State {
    case selected
    case unselected
    
    mutating func toggle() {
        switch self {
        case .selected:
            self = .unselected
        case .unselected:
            self = .selected
        }
    }
}

final class ActionButton: UIButton {
    // MARK: - ButtonState
    enum ColorType {
        case black, red, grey
    }
    
    var colorType: ColorType = .black {
        didSet {
            updateAppearance()
        }
    }
    
    private var title: String?
    
    // MARK: - Init
    init(
        type: UIButton.ButtonType = .system,
        colorType: ColorType,
        title: String
    ) {
        super.init(frame: .zero)
        self.colorType = colorType
        self.title = title
        updateAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateAppearance() {
        layer.masksToBounds = true
        layer.cornerRadius = .cornerRadius
        titleLabel?.font = .medium16
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: .buttonsHeight).isActive = true
        
        
        switch colorType {
        case .black:
            backgroundColor = .myBlack
            setTitleColor(.myWhite, for: .normal)
            setTitle(title, for: .normal)
        case .red:
            backgroundColor = .myWhite
            layer.borderWidth = 1
            layer.borderColor = UIColor.myRed.cgColor
            setTitleColor(.myRed, for: .normal)
            setTitle(title, for: .normal)
            
        case .grey:
            backgroundColor = .myGray
            setTitleColor(.white, for: .normal)
            setTitle(title, for: .normal)
        }
    }
}
