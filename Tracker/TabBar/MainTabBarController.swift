import UIKit

final class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setAppearance()
        viewControllers = [
            generateViewController(
                TrackersViewController(),
                image: .leftTabBar,
                title: "Трекеры"),
            generateViewController(
                StatisticViewController(),
                image: .rightTabBar,
                title: "Статистика")
        ]
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
