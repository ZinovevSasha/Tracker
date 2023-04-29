import UIKit

final class MainTabBarController: UITabBarController {
    var router: RouterProtocol?
    
    init(
        trackers: TrackersViewController,
        statistic: StatisticViewController
    ) {
        super.init(nibName: nil, bundle: nil)
        
        viewControllers = [
            generateViewController(
                trackers,
                image: .leftTabBar,
                title: "Трекеры"),
            generateViewController(
                statistic,
                image: .rightTabBar,
                title: "Статистика")
        ]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAppearance()
    }
}

private extension MainTabBarController {
    func generateViewController(_ rootViewController: UIViewController, image: UIImage?, title: String) -> UIViewController {
        let viewController = rootViewController
        viewController.tabBarItem.image = image
        viewController.tabBarItem.title = title
        return viewController
    }
    
    func setAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .myWhite
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
        tabBar.tintColor = .myBlue
    }
}
