import UIKit

final class OnboardingPageViewController: UIPageViewController {
    
    var userSuccessfullyLoggedIn: (() -> Void)?
    
    // MARK: Private properties
    private lazy var pages: [UIViewController] = {
        let onboardingBlue = OnboardingViewController(
            image: .onboardingBlue,
            greetingText: Localized.Onboarding.greeting1)
        let onboardingRed = OnboardingViewController(
            image: .onboardingRed,
            greetingText: Localized.Onboarding.greeting2)
        
        return [onboardingBlue, onboardingRed]
    }()
    
    private var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = 2
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = .black.withAlphaComponent(0.3)
        return pageControl
    }()
    
    private var button: ActionButton = {
        let buttonTitle = Localized.Onboarding.enter
        let button = ActionButton(title: buttonTitle)
        return button
    }()
    
    // MARK: - Init
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
        dataSource = self
        delegate = self
        
        if let first = pages.first{
            setViewControllers([first], direction: .forward, animated: true)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }
    
    @objc private func buttonTapped() {
        userSuccessfullyLoggedIn?()
    }
    
    // Private methods
    private func setupLayout() {
        view.addSubviews(pageControl, button)        
        
        
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .leadingInset),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: .trailingInset),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
        ])
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -24),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}

extension OnboardingPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController) else { return nil }
        let previousIndex = (index == 0) ? pages.count - 1 : index - 1
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController) else { return nil }
        let nextIndex = (index == pages.count - 1) ? 0 : index + 1
        return pages[nextIndex]
    }
}

extension OnboardingPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentViewController = pageViewController.viewControllers?.first,
            let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}
