//
//  EditEventViewController.swift
//  Tracker
//
//  Created by Bakgeldi Alkhabay on 25.09.2024.
//

import UIKit

protocol EditEventViewControllerDelegate: AnyObject {
    func updateEvent(id: UInt, title: String, category: String, emoji: String, color: UIColor, schedule: [String], isPinned: Bool)
}

final class EditEventViewController: UIViewController {
    weak var delegate: EditEventViewControllerDelegate?
    
    var tracker: Tracker?
    
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
    
    var categories = [TrackerCategory]()
    var selectedCategory: String?
    
    private let counterLabel = UILabel()
    private let titleLabel = UILabel()
    private let textField = UITextField()
    private let tableView = UITableView()
    
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
    private let saveButton = UIButton()
    
    private var selectedCategoryPath: IndexPath?
    
    private let trackerRecordStore = TrackerRecordStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupCollectionView()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        setTrackerValues()
    }
    
    private func setTrackerValues() {
        selectedEmoji = tracker?.emoji
        selectedColor = tracker?.color
        
        guard let category = tracker?.trackerCategory else { return }
        selectedCategory = category
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupView() {
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        
        // Title Label
        let titleText = NSLocalizedString("nonRegularEventVC.title", comment: "Non-Regular VC Title")
        titleLabel.text = "Редактирование нерегулярного события"
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = Colors.black
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        //Counter Label
        guard let trackerID = tracker?.id else { return }
        let count = trackerRecordStore.countTrackerRecords(byId: Int(trackerID))
        let daysString = String.localizedStringWithFormat(
            NSLocalizedString("numberOfDays", comment: "Number of completed days"),
            count
        )
        counterLabel.text = daysString
        counterLabel.textAlignment = .center
        counterLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        counterLabel.textColor = Colors.black
        counterLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(counterLabel)
        
        // TextField
        let textFieldPlaceholder = NSLocalizedString("textField.placeholder", comment: "Text Field Placeholder")
        textField.placeholder = textFieldPlaceholder
        textField.text = tracker?.name
        textField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textField.backgroundColor = Colors.lightGray
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
        let cancelButtonTitle = NSLocalizedString("cancelButton.title", comment: "Cancel Button Title")
        cancelButton.setTitle(cancelButtonTitle, for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        cancelButton.setTitleColor(Colors.redColor, for: .normal)
        cancelButton.backgroundColor = .white
        cancelButton.layer.cornerRadius = 16
        cancelButton.layer.borderColor = Colors.redColor.cgColor
        cancelButton.layer.borderWidth = 1
        cancelButton.addTarget(self, action: #selector(cancelCreatingNewEvent), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.addArrangedSubview(cancelButton)
        
        // Create Button
        let createButtonTitle = NSLocalizedString("createButton.title", comment: "Create Button Title")
        saveButton.setTitle("Сохранить", for: .normal)
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.backgroundColor = Colors.black
        saveButton.isEnabled = true
        saveButton.layer.cornerRadius = 16
        saveButton.addTarget(self, action: #selector(saveButtonPressed), for: .touchUpInside)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.addArrangedSubview(saveButton)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            // Title
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            //Counter Label
            counterLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            counterLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            counterLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // TextField
            textField.topAnchor.constraint(equalTo: counterLabel.bottomAnchor, constant: 38),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            // Table View
            tableView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: textField.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 75),
            
            // Button Stack View
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            buttonStackView.heightAnchor.constraint(equalToConstant: 60),
            
            // Button Heights
            saveButton.heightAnchor.constraint(equalToConstant: 60),
            saveButton.heightAnchor.constraint(equalToConstant: 60)
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
    private func cancelCreatingNewEvent() {
        dismiss(animated: true)
    }
    
    @objc
    private func saveButtonPressed() {
        guard let eventTitle = textField.text, !eventTitle.isEmpty else {
            print("Название события не может быть пустым")
            return
        }
        
        // Проверяем, выбрана ли категория
        guard let category = selectedCategory else {
            print("Категория не выбрана")
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
        
        guard let id = tracker?.id else {
            return
        }
        
        guard let isPinned = tracker?.isPinned else {
            return
        }
        
        guard let schedule = tracker?.schedule else {
            return
        }
        
        saveButton.isEnabled = false
        delegate?.updateEvent(id: id, title: eventTitle, category: category, emoji: emoji, color: color, schedule: schedule, isPinned: isPinned)
    }
    
    private func showCategoriesPopover() {
        let categoryVC = CategoryViewController()
        let popover = UIPopoverPresentationController(presentedViewController: categoryVC, presenting: self)
        popover.sourceView = self.view
        popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
        popover.permittedArrowDirections = []
        
        categoryVC.modalPresentationStyle = .popover
        categoryVC.selectedIndexPath = selectedCategoryPath
        categoryVC.selectedCategory = selectedCategory
        categoryVC.delegate = self
        
        self.present(categoryVC, animated: true, completion: nil)
    }
}

extension EditEventViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.accessoryType = .disclosureIndicator
        
        // Удаляем все существующие субвью
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        // Category Label
        let categoryLabel = UILabel()
        let categoryLabelText = NSLocalizedString("categoryLabel.text", comment: "Category Label Text")
        
        categoryLabel.text = categoryLabelText
        categoryLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        categoryLabel.textColor = Colors.black
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(categoryLabel)
        
        // Description Label
        let descriptionLabel = UILabel()
        descriptionLabel.text = selectedCategory
        descriptionLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        descriptionLabel.textColor = Colors.descriptionLabelColor
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            // Category Label
            categoryLabel.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 15),
            categoryLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
            categoryLabel.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
            
            // Description Label
            descriptionLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: categoryLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: categoryLabel.trailingAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -15)
        ])
        
        cell.backgroundColor = Colors.lightGray
        
        return cell
    }
}

extension EditEventViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Handle button taps
        print("Категория tapped")
        showCategoriesPopover()
        
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

extension EditEventViewController: CategoryViewControllerDelegate {
    func didSelectCategory(_ category: TrackerCategory, _ selectedIndexPath: IndexPath?) {
        // Сохраняем выбранную категорию
        selectedCategoryPath = selectedIndexPath
        let categoryCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0))
        if let descriptionLabel = categoryCell?.contentView.subviews.last as? UILabel {
            descriptionLabel.text = category.title
            selectedCategory = category.title
        }
    }
}

extension EditEventViewController: UICollectionViewDataSource {
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
                cell.contentView.backgroundColor = Colors.selectedEmojiColor
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
        let emojiHeaderTitle = NSLocalizedString("emojiHeader.title", comment: "Emoji Header Title")
        let colorHeaderTitle = NSLocalizedString("colorHeader.title", comment: "Color Header Title")
        
        guard let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "CollectionHeader",
            for: indexPath
        ) as? CollectionHeaderReusableView else {
            return UICollectionViewCell()
        }
        headerView.categoryTitle.text = indexPath.section == 0 ? emojiHeaderTitle : colorHeaderTitle
        return headerView
    }
}

extension EditEventViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            selectedEmoji = emojis[indexPath.item]
        } else {
            selectedColor = colors[indexPath.item]
        }

        collectionView.reloadData()
    }
}

extension EditEventViewController: UICollectionViewDelegateFlowLayout {
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
