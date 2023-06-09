import UIKit

final class MainTabBarController: UITabBarController {
    // MARK: - Init
    init() {
        super.init(nibName: nil, bundle: nil)

        viewControllers = [
            generateViewController(
                TrackersViewController(
                    dataProvider: DataProvider(context: Context.shared.context)
                ),
                image: .leftTabBar,
                title: Strings.Localizable.TabBar.trackers),
            generateViewController(
                UINavigationController(rootViewController: StatisticViewController(
                    viewModel: StatisticViewModel(
                        trackerRecordStore: TrackerRecordStore(),
                        trackerStore: TrackerStore()
                        )
                    )
                ),
                image: .rightTabBar,
                title: Strings.Localizable.TabBar.statistics)
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

// MARK: - Private methods
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
