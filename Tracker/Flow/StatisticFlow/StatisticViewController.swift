import UIKit

final class StatisticViewController: UIViewController {
    private let placeholder = PlaceholderView(state: .noStatistic)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .myWhite
        view.addSubview(placeholder)
        
        placeholder.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        placeholder.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}
