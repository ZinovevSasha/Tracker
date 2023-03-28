import UIKit

final class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setAppearance()
        viewControllers = [
            generateViewController(
                TrackerViewController(),
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
    func generateViewController(_ rootViewController: UIViewController, image: UIImage, title: String) -> UIViewController {
        let viewController = rootViewController
        viewController.tabBarItem.image = image
        viewController.tabBarItem.title = title
        return viewController
    }
    
    func setAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .myWhite
        appearance.selectionIndicatorTintColor = .black
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
    }
}
