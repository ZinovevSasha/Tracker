import UIKit

final class OnboardingPageViewController: UIPageViewController {
    lazy var pages: [UIViewController] = {
        let onboardingBlue = OnboardingViewController(
            router: router, image: .onboardingBlue,
            greetingText: "Отслеживайте только то, что хотите"
        )
        let onboardingRed = OnboardingViewController(
            router: router, image: .onboardingRed,
            greetingText: "Даже если это не литры воды и йога"
        )
        return [onboardingBlue, onboardingRed]
    }()
    
    lazy var pageControll: UIPageControl = {
        let pageControll = UIPageControl()
        pageControll.numberOfPages = 2
        pageControll.currentPage = 0
        pageControll.currentPageIndicatorTintColor = .black
        pageControll.pageIndicatorTintColor = .black.withAlphaComponent(0.3)
        return pageControll
    }()
    
    private var router: RouterProtocol?
    
    init(router: RouterProtocol) {
        self.router = router
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
    
    // Private methods
    func setupLayout() {
        view.addSubviews(pageControll)
        
        NSLayoutConstraint.activate([
            pageControll.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -134),
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

final class OnboardingViewController: UIViewController {
    // MARK: - Private properties
    private let imageView = UIImageView()
    private let greetingLabel: UILabel = {
        let greetingLabel = UILabel()
        greetingLabel.numberOfLines = 0
        greetingLabel.textAlignment = .center
        greetingLabel.textColor = .black
        greetingLabel.font = .bold32
        greetingLabel.lineBreakMode = .byWordWrapping
        return greetingLabel
    }()
    
    private let button = ActionButton(title: "Вот это технологии!")
    
    // MARK: - Init
    init(router: RouterProtocol?, image: UIImage?, greetingText: String) {
        self.router = router
        self.imageView.image = image
        self.greetingLabel.text = greetingText
        super.init(nibName: nil, bundle: nil)
        imageView.contentMode = .scaleAspectFill
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
    
    var router: RouterProtocol?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }
    
    
    @objc func buttonTapped() {
        router?.mainTrackerController()
//        let mainVC = MainTabBarController(
//        mainVC.modalPresentationStyle = .fullScreen
//        present(mainVC, animated: true)
    }
}

// MARK: - Private methods
private extension OnboardingViewController {
    func setupLayout() {
        view.addSubviews(imageView, greetingLabel, button)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .leadingInset),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: .trailingInset),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
        ])
        
        NSLayoutConstraint.activate([
            greetingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .leadingInset),
            greetingLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: .trailingInset),
            greetingLabel.topAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            imageView.topAnchor.constraint(equalTo: view.topAnchor)
        ])
    }
}
