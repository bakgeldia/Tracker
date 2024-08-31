//
//  AddTrackerViewController.swift
//  Tracker
//
//  Created by Bakgeldi Alkhabay on 23.08.2024.
//

import UIKit

protocol AddTrackerViewControllerDelegate: AnyObject {
    func getTrackerDetail(title: String, category: String, schedule: [String]?)
}

final class AddTrackerViewController: UIViewController {
    private let titleLabel = UILabel()
    private let habitButton = UIButton()
    private let eventButton = UIButton()
    
    var categories = [TrackerCategory]()
    
    weak var delegate: AddTrackerViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        
        // Title Label
        titleLabel.text = "Создание трекера"
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = UIColor(red: 26.0/255.0, green: 27.0/255.0, blue: 34.0/255.0, alpha: 1)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // Habit Button
        habitButton.setTitle("Привычка", for: .normal)
        eventButton.setTitleColor(.white, for: .normal)
        habitButton.backgroundColor = UIColor(red: 26.0/255.0, green: 27.0/255.0, blue: 34.0/255.0, alpha: 1)
        habitButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        habitButton.layer.cornerRadius = 16
        habitButton.addTarget(self, action: #selector(self.showHabitPopover), for: .touchUpInside)
        habitButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(habitButton)
        
        // Event Button
        eventButton.setTitle("Нерегулярное событие", for: .normal)
        eventButton.setTitleColor(.white, for: .normal)
        eventButton.backgroundColor = UIColor(red: 26.0/255.0, green: 27.0/255.0, blue: 34.0/255.0, alpha: 1)
        eventButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        eventButton.layer.cornerRadius = 16
        eventButton.addTarget(self, action: #selector(self.showNonRegularEventPopover), for: .touchUpInside)
        eventButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(eventButton)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            // Title
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Habit Button
            habitButton.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            habitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            habitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            habitButton.heightAnchor.constraint(equalToConstant: 60),
            
            // Event Button
            eventButton.topAnchor.constraint(equalTo: habitButton.bottomAnchor, constant: 16),
            eventButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            eventButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            eventButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc
    private func showHabitPopover() {
        // Инициализируем PopoverViewController
        let newHabitVC = NewHabitViewController()
        
        // Создаем контейнер для popover
        let popover = UIPopoverPresentationController(presentedViewController: newHabitVC, presenting: self)
        popover.sourceView = self.view
        popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
        popover.permittedArrowDirections = []
        
        // Настройки popover
        newHabitVC.modalPresentationStyle = .popover
        newHabitVC.categories = self.categories
        newHabitVC.delegate = self
        
        // Отображаем popover
        self.present(newHabitVC, animated: true, completion: nil)
    }
    
    @objc
    private func showNonRegularEventPopover() {
        // Инициализируем PopoverViewController
        let newEventVC = NonRegularEventViewController()
        
        // Создаем контейнер для popover
        let popover = UIPopoverPresentationController(presentedViewController: newEventVC, presenting: self)
        popover.sourceView = self.view
        popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
        popover.permittedArrowDirections = []
        
        // Настройки popover
        newEventVC.modalPresentationStyle = .popover
        newEventVC.categories = self.categories
        newEventVC.delegate = self
        
        // Отображаем popover
        self.present(newEventVC, animated: true, completion: nil)
    }
}

extension AddTrackerViewController: NewHabitViewControllerDelegate {
    func createNewHabit(title: String, category: String, schedule: [String]) {
        delegate?.getTrackerDetail(title: title, category: category, schedule: schedule)
        dismiss(animated: false)
    }
}

extension AddTrackerViewController: NonRegularEventViewControllerDelegate {
    func createNewEvent(title: String, category: String) {
        delegate?.getTrackerDetail(title: title, category: category, schedule: nil)
        dismiss(animated: false)
    }
}
