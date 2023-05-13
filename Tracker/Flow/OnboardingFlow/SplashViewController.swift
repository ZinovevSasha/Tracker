//
//  SplashViewController.swift
//  Tracker
//
//  Created by Александр Зиновьев on 09.05.2023.
//

import UIKit

final class SplashViewcontroller: UIViewController {
    private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .logo
        return imageView
    }()
    
    private let authService: AuthService
    
    init(authService: AuthService = AuthService()) {
        self.authService = authService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        start()
    }
    
    func setLayout() {
        view.addSubviews(imageView)
        view.backgroundColor = .myBlue
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    private func start() {
        if authService.isLogin == true  {
            presentTrackerViewcontroller()
        } else {
            presentOnboardingViewController()
        }
    }
    
    private func presentTrackerViewcontroller() {
        if let window = UIApplication.shared.windows.first {
            let tabBar = MainTabBarController()
            window.rootViewController = tabBar
        } else {
            fatalError("Invalid Configuration")
        }
    }
    
    private func presentOnboardingViewController() {
        let onboardingPageViewController = OnboardingPageViewController()
        onboardingPageViewController.modalPresentationStyle = .fullScreen
        present(onboardingPageViewController, animated: true)
       
        onboardingPageViewController.userSuccesfullyLoggedIn = { [weak self] in
            guard let self = self else { return }
            self.authService.isLogin = true
            self.presentTrackerViewcontroller()
        }
    }
}
