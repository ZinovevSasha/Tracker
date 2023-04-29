import UIKit

final class StatisticViewController: UIViewController {
    private let placeholder = PlaceholderView(state: .noStatistic)
    
    var router: RouterProtocol?
    
    init(router: RouterProtocol? = nil) {
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .myWhite
        view.addSubviews(placeholder)
        
        placeholder.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        placeholder.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}
