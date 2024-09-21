//
//  OnboardingPageViewController.swift
//  Tracker
//
//  Created by Bakgeldi Alkhabay on 20.09.2024.
//

import UIKit

final class OnboardingPageViewController: UIViewController {
    
    let imageView = UIImageView()
    let label = UILabel()
    
    private var pageType: OnboardingPageType
    
    init(pageType: OnboardingPageType) {
        self.pageType = pageType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        configureView(for: pageType)
    }
    
    func setupView() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        label.numberOfLines = 2
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -270),
        ])
    }
    
    func configureView(for pageType: OnboardingPageType) {
        imageView.image = UIImage(named: pageType.imageName)
        label.text = pageType.labelText
    }
}
