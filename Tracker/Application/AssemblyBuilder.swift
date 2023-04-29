import UIKit

protocol AssemblyProtocol {
    func createOnboarding(router: RouterProtocol) -> UIViewController
    func createMainTabBar(router: RouterProtocol) -> UIViewController
}

final class Assembly: AssemblyProtocol {
    func createOnboarding(router: RouterProtocol) -> UIViewController {
        return OnboardingPageViewController(router: router)
    }
    
    func createMainTabBar(router: RouterProtocol) -> UIViewController {
        return MainTabBarController(
            trackers: TrackersViewController(router: router),
            statistic: StatisticViewController(router: router)
        )
    }
    
    func createChoseTrackerViewController(router: RouterProtocol) -> UIViewController {
        return ChooseTrackerViewController(categories: [], from: TrackersViewController(router: router), date: "")
    }
    
    func createTrackerViewControllerBuilder() -> UIViewController {
        return CreateTrackerViewController(configuration: .oneRow, addCategories: [], date: "")
    }
    
    func createCategoryListViewController() -> UIViewController {
        return CategoryListViewController(tempCategory: [], lastRow: 0)
    }
    
    func createNewCategoryViewControllerBuilder() -> UIViewController {
        return CreateNewCategoryViewController()
    }
    
    func createScheduleTableViewCell() -> UIViewController {
        return ChooseScheduleViewController(weekDays: [2])
    }
}
