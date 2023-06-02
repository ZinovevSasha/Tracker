import UIKit

final class OnboardingPageViewController: UIPageViewController {
    
    var userSuccesfullyLoggedIn: (() -> Void)?
    
    // MARK: Private properties
    private var pages: [UIViewController] = {
        let onboardingBlue = OnboardingViewController(
            image: .onboardingBlue,
            greetingText: Localized.Onboarding.greeting1
        )
        let onboardingRed = OnboardingViewController(
            image: .onboardingRed,
            greetingText: Localized.Onboarding.greeting2
        )
        return [onboardingBlue, onboardingRed]
    }()
    
    private var pageControll: UIPageControl = {
        let pageControll = UIPageControl()
        pageControll.numberOfPages = 2
        pageControll.currentPage = 0
        pageControll.currentPageIndicatorTintColor = .black
        pageControll.pageIndicatorTintColor = .black.withAlphaComponent(0.3)
        return pageControll
    }()
    
    private let button = ActionButton(title: Localized.Onboarding.enter)
    
    // MARK: - Init
    private let authService: AuthService?
    
    init(authService: AuthService? = AuthService()) {
        self.authService = authService
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        
        dataSource = self
        delegate = self
        
        if let first = pages.first{
            setViewControllers([first], direction: .forward, animated: true)
        }
    }
    
    @objc private func buttonTapped() {
        userSuccesfullyLoggedIn?()
    }
    
    // Private methods
    private func setupLayout() {
        view.addSubviews(pageControll, button)
        
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .leadingInset),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: .trailingInset),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
        ])
        
        NSLayoutConstraint.activate([
            pageControll.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -134),
            pageControll.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}

extension OnboardingPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return getViewController(-, from: pages, relativeTo: viewController)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return getViewController(+, from: pages, relativeTo: viewController)
    }
    
    private func getViewController(_ operation: (Int, Int) -> Int, from viewControllers: [UIViewController], relativeTo viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = viewControllers.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = operation(viewControllerIndex, 1)
        
        if previousIndex < .zero {
            return viewControllers.last
        }
        
        if previousIndex >= viewControllers.count {
            return viewControllers.first
        }
        
        return viewControllers[previousIndex]
    }
}

extension OnboardingPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentViewController = pageViewController.viewControllers?.first,
            let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControll.currentPage = currentIndex
        }
    }
}
