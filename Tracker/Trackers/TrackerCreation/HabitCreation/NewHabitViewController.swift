//
//  NewHabitViewController.swift
//  Tracker
//
//  Created by Bakgeldi Alkhabay on 23.08.2024.
//

import UIKit

protocol NewHabitViewControllerDelegate: AnyObject {
    func createNewHabit(title: String, category: String, emoji: String, color: UIColor, schedule: [String])
}

final class NewHabitViewController: UIViewController {
    
    weak var delegate: NewHabitViewControllerDelegate?
    
    private let titleLabel = UILabel()
    private let textField = UITextField()
    private let tableView = UITableView()
    
    let emojis = ["😀", "😂", "🥰", "😎", "🤔", "🙌", "🎉", "💪", "🍕", "🏆", "🚀", "❤️", "🔥", "🌟", "🎶", "🌈", "🐶", "⚡️"]
    let colors: [UIColor] = [
        UIColor(red: 255/255, green: 99/255, blue: 71/255, alpha: 1.0),   // Tomato
        UIColor(red: 135/255, green: 206/255, blue: 235/255, alpha: 1.0), // SkyBlue
        UIColor(red: 144/255, green: 238/255, blue: 144/255, alpha: 1.0), // LightGreen
        UIColor(red: 255/255, green: 165/255, blue: 0/255, alpha: 1.0),   // Orange
        UIColor(red: 75/255, green: 0/255, blue: 130/255, alpha: 1.0),    // Indigo
        UIColor(red: 255/255, green: 215/255, blue: 0/255, alpha: 1.0),   // Gold
        UIColor(red: 199/255, green: 21/255, blue: 133/255, alpha: 1.0),  // MediumVioletRed
        UIColor(red: 255/255, green: 182/255, blue: 193/255, alpha: 1.0), // LightPink
        UIColor(red: 173/255, green: 255/255, blue: 47/255, alpha: 1.0),  // GreenYellow
        UIColor(red: 70/255, green: 130/255, blue: 180/255, alpha: 1.0),  // SteelBlue
        UIColor(red: 240/255, green: 128/255, blue: 128/255, alpha: 1.0), // LightCoral
        UIColor(red: 221/255, green: 160/255, blue: 221/255, alpha: 1.0), // Plum
        UIColor(red: 255/255, green: 99/255, blue: 132/255, alpha: 1.0),  // PinkishRed
        UIColor(red: 46/255, green: 139/255, blue: 87/255, alpha: 1.0),   // SeaGreen
        UIColor(red: 255/255, green: 140/255, blue: 0/255, alpha: 1.0),   // DarkOrange
        UIColor(red: 138/255, green: 43/255, blue: 226/255, alpha: 1.0),  // BlueViolet
        UIColor(red: 102/255, green: 205/255, blue: 170/255, alpha: 1.0), // MediumAquamarine
        UIColor(red: 220/255, green: 20/255, blue: 60/255, alpha: 1.0)    // Crimson
    ]
    private var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: "emojiCell")
        collectionView.register(ColorCell.self, forCellWithReuseIdentifier: "colorCell")
        return collectionView
    }()
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    
    private let buttonStackView = UIStackView()
    private let cancelButton = UIButton()
    private let createButton = UIButton()
    
    private var prevDays: [String] = []
    var selectedCategory: String?
    var selectedCategoryPath: IndexPath?
    var selectedDays: [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupCollectionView()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
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
        textField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
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
        tableView.isScrollEnabled = false
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
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
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
        createButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
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
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: "emojiCell")
        collectionView.register(ColorCell.self, forCellWithReuseIdentifier: "colorCell")
        collectionView.register(CollectionHeaderReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "CollectionHeader")
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
            collectionView.bottomAnchor.constraint(equalTo: buttonStackView.topAnchor, constant: -16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.headerReferenceSize = CGSize(width: collectionView.bounds.width, height: 18)
        }
    }
    
    @objc
    private func cancelCreatingNewHabit() {
        dismiss(animated: true)
    }
    
    @objc
    private func createNewHabit() {
        guard let habitTitle = textField.text, !habitTitle.isEmpty else {
            print("Название привычки не может быть пустым")
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
        
        guard let emoji = selectedEmoji else {
            print("Эмодзи не выбрана")
            return
        }
        
        guard let color = selectedColor else {
            print("Цвет не выбран")
            return
        }
        
        createButton.isEnabled = false
        
        delegate?.createNewHabit(title: habitTitle, category: category, emoji: emoji, color: color, schedule: schedule)
    }
    
    private func showSchedulePopover() {
        let scheduleVC = ScheduleViewController()
        let popover = UIPopoverPresentationController(presentedViewController: scheduleVC, presenting: self)
        popover.sourceView = self.view
        popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
        popover.permittedArrowDirections = []
        
        scheduleVC.modalPresentationStyle = .popover
        scheduleVC.selectedDays = prevDays
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
        categoryVC.selectedIndexPath = selectedCategoryPath
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
            categoryLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            categoryLabel.textColor = UIColor(red: 26.0/255.0, green: 27.0/255.0, blue: 34.0/255.0, alpha: 1)
            categoryLabel.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(categoryLabel)
            
            let descriptionLabel = UILabel()
            descriptionLabel.text = ""
            descriptionLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
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
            let scheduleLabel = UILabel()
            scheduleLabel.text = "Расписание"
            scheduleLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            scheduleLabel.textColor = UIColor(red: 26.0/255.0, green: 27.0/255.0, blue: 34.0/255.0, alpha: 1)
            scheduleLabel.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(scheduleLabel)
            
            let daysLabel = UILabel()
            daysLabel.text = ""
            daysLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
}

extension NewHabitViewController: CategoryViewControllerDelegate {
    func didSelectCategory(_ category: TrackerCategory, _ selectedIndexPath: IndexPath?) {
        // Сохраняем выбранную категорию
        selectedCategoryPath = selectedIndexPath
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
        prevDays = days
        
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

extension NewHabitViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return section == 0 ? emojis.count : colors.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        if indexPath.section == 0 {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "emojiCell",
                for: indexPath
            ) as? EmojiCell else {
                return UICollectionViewCell()
            }
            
            cell.emoji.text = emojis[indexPath.item]
            
            if emojis[indexPath.item] == selectedEmoji {
                cell.contentView.layer.cornerRadius = 16
                cell.contentView.backgroundColor = UIColor(red: 230.0/255.0, green: 232.0/255.0, blue: 235.0/255.0, alpha: 1.0)
            } else {
                cell.contentView.backgroundColor = UIColor.clear
            }
            
            return cell
            
        } else {
            
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "colorCell",
                for: indexPath
            ) as? ColorCell else {
                return UICollectionViewCell()
            }
            cell.square.backgroundColor = colors[indexPath.item]
            
            if colors[indexPath.item] == selectedColor {
                cell.layer.borderColor = colors[indexPath.item].withAlphaComponent(0.3).cgColor
                cell.layer.borderWidth = 3.0
                cell.layer.cornerRadius = 8
            } else {
                cell.layer.borderWidth = 0
            }
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "CollectionHeader",
            for: indexPath
        ) as? CollectionHeaderReusableView else {
            return UICollectionViewCell()
        }
        headerView.categoryTitle.text = indexPath.section == 0 ? "Emoji" : "Цвет"
        return headerView
    }
}

extension NewHabitViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            selectedEmoji = emojis[indexPath.item]
        } else {
            selectedColor = colors[indexPath.item]
        }
        
        collectionView.reloadData()
    }
}

extension NewHabitViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let totalSpacing: CGFloat = 25
        let width = (collectionView.bounds.width - totalSpacing) / 7
        return CGSize(width: width, height: width)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
