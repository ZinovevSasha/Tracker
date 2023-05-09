import UIKit

extension UIImage {
    static let plus               = UIImage(named: "06plus")
    static let logo               = UIImage(named: "07Logo")
    static let done               = UIImage(named: "11done")
    static let chevron            = UIImage(named: "10chevron")
    static let plusWhite          = UIImage(named: "08plusWhite")
    static let borderCell         = UIImage(named: "09cellBorder")
    static let leftTabBar         = UIImage(named: "02rightTabBar")
    static let rightTabBar        = UIImage(named: "01leftTabBar")
    static let onboardingRed      = UIImage(named: "04onboardingRed")
    static let onboardingBlue     = UIImage(named: "03onboardingBlue")
    static let star               = UIImage(named: "05placeholderTracker")
    static let noResult           = UIImage(named: "12placeholderNoStatistic")
    static let noStatistic        = UIImage(named: "13placeholderNoResult")
    static let checkmarkBlue      = UIImage(named: "14checkmark")
    
    enum Placeholder {
        case star
        case noResult
        case noStatistic
        
        var image: UIImage? {
            switch self {
            case .star:
                return .star
            case .noResult:
                return .noResult
            case .noStatistic:
                return .noStatistic
            }
        }
    }
}

extension UIImage {
    // Create a UIImage from a UIColor
    convenience init(color: UIColor) {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.init(ciImage: CIImage(image: image)!)
    }
}
