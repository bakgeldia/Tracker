//
//  ViewController.swift
//  Tracker
//
//  Created by Bakgeldi Alkhabay on 13.08.2024.
//

import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTabBarItems()
        customizeTabBarAppearance()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showOnboard()
    }

    private func showOnboard() {
        let onboardKey = "hasSeenOnboarding"
        let hasSeenOnboarding = UserDefaults.standard.bool(forKey: onboardKey)
        if !hasSeenOnboarding {
            let onboardingViewController = OnboardingViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
            onboardingViewController.modalPresentationStyle = .fullScreen
            present(onboardingViewController, animated: true, completion: nil)
        }
    }
    
    private func setTabBarItems() {
        let trackersViewController = TrackersViewController()
        let statisticsViewController = StatisticsViewController()
        
        let tabBarTrackers = NSLocalizedString("tabBar.trackers", comment: "Tab Bar Trackers")
        let tabBarStatistics = NSLocalizedString("tabBar.statistics", comment: "Tab Bar Statistics")
        
        trackersViewController.tabBarItem = UITabBarItem(
            title: tabBarTrackers,
            image: UIImage(named: "tab_trackers"),
            selectedImage: nil
        )
        
        statisticsViewController.tabBarItem = UITabBarItem(
            title: tabBarStatistics,
            image: UIImage(named: "tab_statistics"),
            selectedImage: nil
        )
        
        let navigationController = UINavigationController(rootViewController: trackersViewController)
        
        self.viewControllers = [navigationController, statisticsViewController]
    }
    
    private func customizeTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        
        appearance.shadowColor = Colors.tabBarShadowColor
        
        tabBar.standardAppearance = appearance
        
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = tabBar.standardAppearance
        }
    }

}

