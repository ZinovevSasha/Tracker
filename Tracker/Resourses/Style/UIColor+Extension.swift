import UIKit

extension UIColor {
    
    static let myRed                     = UIColor(named: "myRed")
    static let myGray                    = UIColor(named: "myGray")
    static let myBlue                    = UIColor(named: "myBlue")
    static let myWhite                   = UIColor(named: "myWhite")
    static let myBlack                   = UIColor(named: "myBlack")
    static let myLightGrey               = UIColor(named: "myLightGrey")
    static let myBackground              = UIColor(named: "myBackground")
    static let myTranspatent             = UIColor(named: "myTranspatent")
    static let myCellBorderColor         = UIColor(named: "myCellBorderColor")
    static let myDatePickerBackground    = UIColor(named: "myDatePickerBackground")
    static let myCreateButtonColorLocked = UIColor(named: "myCreateButtonColorLocked")
}
extension UIColor {
    convenience init?(hexString: String) {
        var hexString = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        hexString = hexString.replacingOccurrences(of: "#", with: "")
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)
        
        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    func toHexString() -> String {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let redInt = Int(red * 255)
        let greenInt = Int(green * 255)
        let blueInt = Int(blue * 255)
        
        let hexString = String(format: "#%02x%02x%02x", redInt, greenInt, blueInt)
        return hexString
    }
}
