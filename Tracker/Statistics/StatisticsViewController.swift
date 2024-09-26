//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Bakgeldi Alkhabay on 13.08.2024.
//

import UIKit

final class StatisticsViewController: UIViewController {
    
    private var completedTrackersCounter = 0
    
    private let titleLabel = UILabel()
    private let notFoundImageView = UIImageView()
    private let notFoundLabel = UILabel()
    private let completedTrackersView = UIView()
    private let countLabel = UILabel()
    private let completedLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupStatsView()
        checkStats()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        completedTrackersCounter = UserDefaults.standard.integer(forKey: "completedTrackersCounter")
        countLabel.text = "\(completedTrackersCounter)"
        checkStats()
    }
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        
        titleLabel.text = "Статистика"
        titleLabel.textColor = Colors.statisticsTitle
        titleLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        notFoundImageView.image = UIImage(named: "sad")
        notFoundImageView.isHidden = true
        notFoundImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(notFoundImageView)
        
        notFoundLabel.text = "Анализировать пока нечего"
        notFoundLabel.textAlignment = .center
        notFoundLabel.textColor = Colors.statisticsTitle
        notFoundLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        notFoundLabel.isHidden = true
        notFoundLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(notFoundLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -105),
            
            notFoundImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            notFoundImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            notFoundImageView.heightAnchor.constraint(equalToConstant: 80),
            notFoundImageView.widthAnchor.constraint(equalToConstant: 80),
            
            notFoundLabel.topAnchor.constraint(equalTo: notFoundImageView.bottomAnchor, constant: 8),
            notFoundLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            notFoundLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupStatsView() {
        completedTrackersView.layer.cornerRadius = 16
        completedTrackersView.isHidden = true
        completedTrackersView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(completedTrackersView)
        
        addGradient()
        
        countLabel.text = "\(completedTrackersCounter)"
        countLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        countLabel.textColor = Colors.statisticsTitle
        countLabel.isHidden = true
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        completedTrackersView.addSubview(countLabel)
        
        completedLabel.text = "Трекеров завершено"
        completedLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        completedLabel.textColor = Colors.statisticsTitle
        completedLabel.isHidden = true
        completedLabel.translatesAutoresizingMaskIntoConstraints = false
        completedTrackersView.addSubview(completedLabel)
        
        NSLayoutConstraint.activate([
            completedTrackersView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            completedTrackersView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            completedTrackersView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            completedTrackersView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            completedTrackersView.heightAnchor.constraint(equalToConstant: 90),
            
            countLabel.topAnchor.constraint(equalTo: completedTrackersView.topAnchor, constant: 12),
            countLabel.leadingAnchor.constraint(equalTo: completedTrackersView.leadingAnchor, constant: 12),
            countLabel.trailingAnchor.constraint(equalTo: completedTrackersView.trailingAnchor, constant: -12),
           
            completedLabel.topAnchor.constraint(equalTo: countLabel.bottomAnchor, constant: 7),
            completedLabel.leadingAnchor.constraint(equalTo: countLabel.leadingAnchor),
            completedLabel.trailingAnchor.constraint(equalTo: countLabel.trailingAnchor),
            completedLabel.bottomAnchor.constraint(equalTo: completedTrackersView.bottomAnchor, constant: -12)
        ])
    }
    
    private func addGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0/255, green: 123/255, blue: 250/255, alpha: 1).cgColor,
            UIColor(red: 70/255, green: 230/255, blue: 157/255, alpha: 1).cgColor,
            UIColor(red: 253/255, green: 76/255, blue: 73/255, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = completedTrackersView.bounds
        gradientLayer.cornerRadius = 16
        
        let borderLayer = CALayer()
        borderLayer.frame = completedTrackersView.bounds
        borderLayer.cornerRadius = 16
        borderLayer.borderWidth = 1
        borderLayer.borderColor = UIColor.clear.cgColor
        
        completedTrackersView.layer.addSublayer(gradientLayer)
        completedTrackersView.layer.addSublayer(borderLayer)
        
        updateGradientBorderLayer()
    }
    
    private func updateGradientBorderLayer() {
        if let gradientLayer = completedTrackersView.layer.sublayers?[0] as? CAGradientLayer {
            gradientLayer.frame = completedTrackersView.bounds
        }
        if let borderLayer = completedTrackersView.layer.sublayers?[1] {
            borderLayer.frame = completedTrackersView.bounds
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateGradientBorderLayer()
    }
    
    private func checkStats() {
        if completedTrackersCounter > 0 {
            notFoundImageView.isHidden = true
            notFoundLabel.isHidden = true
            completedTrackersView.isHidden = false
            countLabel.isHidden = false
            completedLabel.isHidden = false
            
        } else {
            notFoundImageView.isHidden = false
            notFoundLabel.isHidden = false
            completedTrackersView.isHidden = true
            countLabel.isHidden = true
            completedLabel.isHidden = true
        }
    }
    
}
