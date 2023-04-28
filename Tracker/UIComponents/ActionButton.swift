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
        case black, red, grey, trueBlack
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
    
    convenience init(title: String) {        
        self.init(colorType: .trueBlack, title: title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
    
    private func updateAppearance() {
        layer.masksToBounds = true
        layer.cornerRadius = .cornerRadius
        titleLabel?.font = .medium16
        heightAnchor.constraint(equalToConstant: .buttonsHeight).isActive = true
       
        switch colorType {
        case .black:
            backgroundColor = .myBlack
            setTitleColor(.myWhite, for: .normal)
            setTitle(title, for: .normal)
        case .red:
            backgroundColor = .myWhite
            layer.borderWidth = 1
            layer.borderColor = UIColor.myRed?.cgColor
            setTitleColor(.myRed, for: .normal)
            setTitle(title, for: .normal)
        case .grey:
            backgroundColor = .myGray
            setTitleColor(.white, for: .normal)
            setTitle(title, for: .normal)
        case .trueBlack:
            backgroundColor = .black
            setTitleColor(.white, for: .normal)
            setTitle(title, for: .normal)
        }
    }
}
