import UIKit

final class MainTabBarController: UITabBarController {
    init() {
        super.init(nibName: nil, bundle: nil)
        
        let trackersViewController =  generateViewController(
            TrackersViewController(
                viewModel: TrackerViewModel(diffCalculator: DiffCalculator() )),
            image: .leftTabBar,
            title: Localized.TabBar.trackers
        
        )
        
        let statisticViewController = generateViewController(
            StatisticViewController(),
            image: .rightTabBar,
            title: Localized.TabBar.statistics
        )
        setViewControllers([trackersViewController, statisticViewController], animated: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAppearance()
    }

    // MARK: - Private methods
    
    private func generateViewController(_ rootViewController: UIViewController, image: UIImage?, title: String) -> UIViewController {
        let viewController = rootViewController
        viewController.tabBarItem.image = image
        viewController.tabBarItem.title = title
        return viewController
    }
    
    private func setAppearance() {
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
