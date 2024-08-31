//
//  NewHabitViewController.swift
//  Tracker
//
//  Created by Bakgeldi Alkhabay on 23.08.2024.
//

import UIKit

protocol NewHabitViewControllerDelegate: AnyObject {
    func createNewHabit(title: String, category: String, schedule: [String])
}

final class NewHabitViewController: UIViewController {
    
    weak var delegate: NewHabitViewControllerDelegate?
    
    private let titleLabel = UILabel()
    private let textField = UITextField()
    private let tableView = UITableView()
    
    private let buttonStackView = UIStackView()
    private let cancelButton = UIButton()
    private let createButton = UIButton()
    
    var categories = [TrackerCategory]()
    var selectedCategory: String?
    var selectedDays: [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        
        // Title Label
        titleLabel.text = "Новая привычка"
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = UIColor(red: 26.0/255.0, green: 27.0/255.0, blue: 34.0/255.0, alpha: 1)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // TextField
        textField.placeholder = "Введите название трекера"
        textField.backgroundColor = UIColor(red: 230.0/255.0, green: 232.0/255.0, blue: 235.0/255.0, alpha: 0.3)
        textField.layer.cornerRadius = 16
        textField.textAlignment = .left
        
        // Add padding to the left side of the text field
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textField)
        
        // Table View
        tableView.layer.cornerRadius = 16
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.dataSource = self
        tableView.delegate = self
        
        // Button Stack View
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 8
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonStackView)
        
        // Cancel Button
        let redColor = UIColor(red: 245.0/255.0, green: 107.0/255.0, blue: 108.0/255.0, alpha: 1)
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.setTitleColor(redColor, for: .normal)
        cancelButton.backgroundColor = .white
        cancelButton.layer.cornerRadius = 16
        cancelButton.layer.borderColor = redColor.cgColor
        cancelButton.layer.borderWidth = 1
        cancelButton.addTarget(self, action: #selector(cancelCreatingNewHabit), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.addArrangedSubview(cancelButton)
        
        // Create Button
        createButton.setTitle("Создать", for: .normal)
        createButton.setTitleColor(.white, for: .normal)
        createButton.backgroundColor = UIColor(red: 26.0/255.0, green: 27.0/255.0, blue: 34.0/255.0, alpha: 1)
        createButton.layer.cornerRadius = 16
        createButton.addTarget(self, action: #selector(createNewHabit), for: .touchUpInside)
        createButton.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.addArrangedSubview(createButton)
        
        
        // Layout constraints
        NSLayoutConstraint.activate([
            // Title
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // TextField
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            // Table View
            tableView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: textField.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 150),
            
            // Button Stack View
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            buttonStackView.heightAnchor.constraint(equalToConstant: 60),
            
            // Button Heights
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc
    private func cancelCreatingNewHabit() {
        dismiss(animated: true)
    }
    
    @objc
    private func createNewHabit() {
        guard let habitTitle = textField.text, !habitTitle.isEmpty else {
            print("Название события не может быть пустым")
            return
        }
        
        // Проверяем, выбрана ли категория
        guard let category = selectedCategory else {
            print("Категория не выбрана")
            return
        }
        
        // Проверяем, установлено ли расписание
        guard let schedule = selectedDays else {
            print("Расписание пусто")
            return
        }
        
        dismiss(animated: true, completion: nil)
        delegate?.createNewHabit(title: habitTitle, category: category, schedule: schedule)
    }
    
    private func showSchedulePopover() {
        let scheduleVC = ScheduleViewController()
        let popover = UIPopoverPresentationController(presentedViewController: scheduleVC, presenting: self)
        popover.sourceView = self.view
        popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
        popover.permittedArrowDirections = []
        
        scheduleVC.modalPresentationStyle = .popover
        scheduleVC.delegate = self
        
        self.present(scheduleVC, animated: true, completion: nil)
    }
    
    private func showCategoriesPopover() {
        let categoryVC = CategoryViewController()
        let popover = UIPopoverPresentationController(presentedViewController: categoryVC, presenting: self)
        popover.sourceView = self.view
        popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
        popover.permittedArrowDirections = []
        
        categoryVC.modalPresentationStyle = .popover
        categoryVC.categories = self.categories
        categoryVC.delegate = self
        
        self.present(categoryVC, animated: true, completion: nil)
    }
}

extension NewHabitViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        if indexPath.row == 0 {
            let categoryLabel = UILabel()
            categoryLabel.text = "Категория"
            categoryLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            categoryLabel.textColor = UIColor(red: 26.0/255.0, green: 27.0/255.0, blue: 34.0/255.0, alpha: 1)
            categoryLabel.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(categoryLabel)
            
            let descriptionLabel = UILabel()
            descriptionLabel.text = ""
            descriptionLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            descriptionLabel.textColor = UIColor(red: 174.0/255.0, green: 175.0/255.0, blue: 180.0/255.0, alpha: 1)
            descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
            descriptionLabel.isHidden = true
            cell.contentView.addSubview(descriptionLabel)
            
            NSLayoutConstraint.activate([
                categoryLabel.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 15),
                categoryLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
                categoryLabel.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
                
                descriptionLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 8),
                descriptionLabel.leadingAnchor.constraint(equalTo: categoryLabel.leadingAnchor),
                descriptionLabel.trailingAnchor.constraint(equalTo: categoryLabel.trailingAnchor),
                descriptionLabel.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -15)
            ])
            
        } else {
            //cell.textLabel?.text = "Расписание"
            let scheduleLabel = UILabel()
            scheduleLabel.text = "Расписание"
            scheduleLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            scheduleLabel.textColor = UIColor(red: 26.0/255.0, green: 27.0/255.0, blue: 34.0/255.0, alpha: 1)
            scheduleLabel.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(scheduleLabel)
            
            let daysLabel = UILabel()
            daysLabel.text = ""
            daysLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            daysLabel.textColor = UIColor(red: 174.0/255.0, green: 175.0/255.0, blue: 180.0/255.0, alpha: 1)
            daysLabel.translatesAutoresizingMaskIntoConstraints = false
            daysLabel.isHidden = true
            cell.contentView.addSubview(daysLabel)
            
            NSLayoutConstraint.activate([
                scheduleLabel.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 15),
                scheduleLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
                scheduleLabel.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
                
                daysLabel.topAnchor.constraint(equalTo: scheduleLabel.bottomAnchor, constant: 8),
                daysLabel.leadingAnchor.constraint(equalTo: scheduleLabel.leadingAnchor),
                daysLabel.trailingAnchor.constraint(equalTo: scheduleLabel.trailingAnchor),
                daysLabel.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -15)
            ])
        }
        
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = UIColor(red: 230.0/255.0, green: 232.0/255.0, blue: 235.0/255.0, alpha: 0.3)
        return cell
    }
}


extension NewHabitViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            showCategoriesPopover()
            
        } else if indexPath.row == 1 {
            showSchedulePopover()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension NewHabitViewController: CategoryViewControllerDelegate {
    func didSelectCategory(_ category: TrackerCategory) {
        // Сохраняем выбранную категорию
        let categoryCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0))
        if let descriptionLabel = categoryCell?.contentView.subviews.last as? UILabel {
            selectedCategory = category.title
            descriptionLabel.text = category.title
            descriptionLabel.isHidden = false
        }
    }
}

extension NewHabitViewController: ScheduleViewControllerDelegate {
    func didSelectDays(_ days: [String]) {
        // Сохраняем выбранную категорию
        let scheduleCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0))
        
        if let daysLabel = scheduleCell?.contentView.subviews.last as? UILabel {
            // Словарь для сокращенных имен дней недели
            let dayAbbreviations: [String: String] = [
                "Понедельник": "Пн",
                "Вторник": "Вт",
                "Среда": "Ср",
                "Четверг": "Чт",
                "Пятница": "Пт",
                "Суббота": "Сб",
                "Воскресенье": "Вс"
            ]
            
            // Преобразование выбранных дней в сокращенные названия
            let shortNames = days.compactMap { dayAbbreviations[$0] }
                .joined(separator: ", ")
            
            //Сохранение англ версий
            let daysTranslated: [String: String] = [
                "Понедельник": "Monday",
                "Вторник": "Tuesday",
                "Среда": "Wednesday",
                "Четверг": "Thursday",
                "Пятница": "Friday",
                "Суббота": "Saturday",
                "Воскресенье": "Sunday"
            ]
            let englishDays = days.compactMap { daysTranslated[$0] }
            selectedDays = englishDays
            
            daysLabel.text = shortNames
            daysLabel.isHidden = false
        }
    }
}
