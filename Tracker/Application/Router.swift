import UIKit

protocol RouterMain {
    var navigationController: UINavigationController? { get set }
    var assembly: AssemblyProtocol? { get set }
}

protocol RouterProtocol: RouterMain {
    func initialViewController()
    func mainTrackerController()
}

class Router: RouterProtocol {
    var navigationController: UINavigationController?
    var assembly: AssemblyProtocol?
    
    init(
        navigationController: UINavigationController?,
        assembly: AssemblyProtocol?
    ) {
        self.navigationController = navigationController
        self.assembly = assembly
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func initialViewController() {
        if let navigationController {
            guard let onboarding = assembly?.createOnboarding(router: self) else { return }
            navigationController.pushViewController(onboarding, animated: true)
        }
    }
    
    func mainTrackerController() {
        if let navigationController {
            guard let mainTracker = assembly?.createMainTabBar(router: self) else { return }
            navigationController.pushViewController(mainTracker, animated: true)
        }
    }
}
