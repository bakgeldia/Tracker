//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Bakgeldi Alkhabay on 13.08.2024.
//

import UIKit

final class TrackersViewController: UIViewController, UISearchBarDelegate {
    
    private var addTrackerButton = UIButton()
    private var datePicker = UIDatePicker()
    private var pageTitle = UILabel()
    private var searchBar = UISearchBar()
    private let errorImageView = UIImageView()
    private let errorLabel = UILabel()
    private var searchController = UISearchController()
    
    private let trackerStore = TrackerStore()
    private let trackerCategoryStore = TrackerCategoryStore()
    private let trackerRecordStore = TrackerRecordStore()
    
    var categories = [TrackerCategory]()
    var completedTrackers = [TrackerRecord]()
    var currentDate: Date = Date()
    private var filteredTrackers = [TrackerCategory]()
    
    private let emojies = [
        "😀", "😂", "🥲", "😍", "😎", "🤔", "😱", "🤯", "🥳", "😅",
        "🙈", "🙉", "🙊", "💩", "💖", "🌟", "🔥", "🌈", "🌹", "🎉",
        "🎂", "🍕", "🍔", "🍣", "🍦", "🍩", "🍪", "🍉", "🍓", "🍑",
        "🏠", "🚗", "✈️", "🚀", "🛳️", "🚤", "🚲", "🛵", "🕰️", "📱",
        "💻", "⌚", "📚", "📝", "🖼️", "🎨", "🎵", "🎸", "🎻", "🎺",
        "🎷", "🎹", "🎼", "🎧", "🎤", "🎬", "🎮", "🎲", "🎯", "🎳",
        "🎮", "🏆", "🥇", "🥈", "🥉", "🏅", "🎖️", "🏅", "🛡️", "⚔️"
    ]
    
    private var visibleEmojies: [String] = []
    private var trackerCounters = [UInt: Int]()
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //-------------- Example ------------------
        let category2 = TrackerCategory(title: "Здоровый образ жизни", trackers: [])
        
        if !trackerCategoryStore.categoryExists(category2) {
            do {
                try trackerCategoryStore.addNewTrackerCategory(category2)
            } catch {
                print(error)
            }
        }
        
        do {
            categories = try trackerCategoryStore.fetchTrackerCategories()
        } catch {
            print("Ошибка при получении категории")
        }
        //-------------- Example -------------------
        
        searchController.searchBar.delegate = self
        
        setupNavBar()
        setupSearchController()
        setupView()
        
        let today = Date()
        datePicker.setDate(today, animated: false)
        datePickerValueChanged(datePicker)
        
        setupCollectionView()
        trackerCategoryStore.delegate = self
        trackerRecordStore.delegate = self
    }
    
    private func updatePlaceholderVisibility() {
        if filteredTrackers.flatMap({ $0.trackers }).isEmpty {
            errorImageView.isHidden = false
            errorLabel.isHidden = false
            collectionView.isHidden = true
        } else {
            errorImageView.isHidden = true
            errorLabel.isHidden = true
            collectionView.isHidden = false
        }
    }
    
    private func setupNavBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor = .clear

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        
        //Date picker
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        
        //Add tracker button
        addTrackerButton = UIButton.systemButton(
            with: UIImage(named: "add_tracker_button") ?? UIImage(),
            target: self,
            action: #selector(Self.didTapAddButton)
        )
        addTrackerButton.tintColor = UIColor(red: 26.0/255.0, green: 27.0/255.0, blue: 34.0/255.0, alpha: 1)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: addTrackerButton)
        
        navigationItem.title = "Трекеры"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Поиск"
        searchController.searchBar.tintColor = UIColor(red: 118.0/255.0, green: 118.0/255.0, blue: 128.0/255.0, alpha: 0.12)
        searchController.searchBar.layer.cornerRadius = 30
        searchController.searchBar.backgroundImage = UIImage()
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.setValue("Отменить", forKey: "cancelButtonText")
        
        // Настройка кнопки отмены
        let cancelButtonAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(red: 55.0/255.0, green: 114.0/255.0, blue: 231.0/255.0, alpha: 1),
            .font: UIFont.systemFont(ofSize: 17, weight: .regular)
        ]
        
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(cancelButtonAttributes, for: .normal)
        
        definesPresentationContext = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterTrackers(for: searchText)
        updatePlaceholderVisibility()
        collectionView.reloadData()
    }
    
    private func setupCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.register(CategoryHeaderReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header")
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.headerReferenceSize = CGSize(width: collectionView.bounds.width, height: 40)
        }
    }
    
    private func setupView() {
        view.backgroundColor = .white
        
        errorImageView.image = UIImage(named: "error")
        errorImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(errorImageView)
        
        NSLayoutConstraint.activate([
            errorImageView.widthAnchor.constraint(equalToConstant: 80),
            errorImageView.heightAnchor.constraint(equalToConstant: 80),
            errorImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            errorImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 402)
        ])
        
        errorLabel.text = "Что будем отслеживать?"
        errorLabel.textColor = UIColor(red: 26.0/255.0, green: 27.0/255.0, blue: 34.0/255.0, alpha: 1)
        errorLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(errorLabel)
        
        NSLayoutConstraint.activate([
            errorLabel.topAnchor.constraint(equalTo: errorImageView.bottomAnchor, constant: 8),
            errorLabel.centerXAnchor.constraint(equalTo: errorImageView.centerXAnchor)
        ])
    }
    
    @objc
    private func didTapAddButton() {
        // Инициализируем PopoverViewController
        let addTrackerVC = AddTrackerViewController()
        
        // Создаем контейнер для popover
        let popover = UIPopoverPresentationController(presentedViewController: addTrackerVC, presenting: self)
        popover.sourceView = self.view
        popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
        popover.permittedArrowDirections = []
        
        // Настройки popover
        addTrackerVC.modalPresentationStyle = .popover
        addTrackerVC.categories = self.categories
        addTrackerVC.delegate = self
        
        // Отображаем popover
        present(addTrackerVC, animated: true, completion: nil)
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE" // Формат для полного названия дня недели
        let selectedDay = dateFormatter.string(from: currentDate)
        let capitalizedDay = selectedDay.capitalized
        
        // Фильтрация трекеров по выбранному дню недели
        filteredTrackers = categories.compactMap { category in
            let filteredTrackers = category.trackers.filter { tracker in
                tracker.schedule.contains(capitalizedDay) || tracker.schedule.contains("Everyday")
            }
            return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filteredTrackers)
        }
        
        updatePlaceholderVisibility()
        collectionView.reloadData()
    }
    
    private func filterTrackers(for searchText: String) {
        let filteredCategories = categories.map { category in
            let filteredTrackers = category.trackers.filter { tracker in
                tracker.name.lowercased().contains(searchText.lowercased())
            }
            return TrackerCategory(title: category.title, trackers: filteredTrackers)
        }
        
        // Фильтруем только если поисковый текст не пустой
        if searchText.isEmpty {
            filteredTrackers = categories
            datePickerValueChanged(datePicker)
        } else {
            filteredTrackers = filteredCategories.filter { !$0.trackers.isEmpty }
        }
        
        updatePlaceholderVisibility()
    }
    
    private func dateWithoutTime(from date: Date) -> Date {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        if let dateOnly = calendar.date(from: dateComponents) {
            return dateOnly
        }
        
        return Date()
    }
}

extension TrackersViewController: TrackerCategoryDelegate {
    func store(_ store: TrackerCategoryStore, didUpdate update: TrackerCategoryUpdate) {
        filteredTrackers = store.categories
        collectionView.reloadData()
    }
}

extension TrackersViewController: TrackerRecordDelegate {
    func store(_ store: TrackerRecordStore, didUpdate update: TrackerRecordUpdate) {
        completedTrackers = store.trackerRecords
        
        collectionView.reloadData()
    }
}

extension TrackersViewController: TrackerDelegate {
    func store(_ store: TrackerStore, didUpdate update: TrackerUpdate) {
        
        collectionView.reloadData()
    }
}

extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filteredTrackers.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return filteredTrackers[section].trackers.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? TrackerCollectionViewCell else {
            return UICollectionViewCell()
        }
        let tracker = filteredTrackers[indexPath.section].trackers[indexPath.item]
        
        cell.emoji.text = tracker.emoji
        cell.trackerName.text = tracker.name
        cell.emojiAndNameView.backgroundColor = tracker.color
        cell.completeTrackerButton.backgroundColor = tracker.color
        
        let todayDate = Date()
        cell.completeTrackerButton.isEnabled = currentDate <= todayDate
        
        let trackerRecord = TrackerRecord(id: tracker.id, date: dateWithoutTime(from: currentDate))
        if trackerRecordStore.trackerRecordExists(trackerRecord) {
            cell.completeTrackerButton.setImage(UIImage(systemName: "checkmark"), for: .normal) // Иконка завершения
            cell.completeTrackerButton.backgroundColor?.withAlphaComponent(0.3)
        } else {
            cell.completeTrackerButton.setImage(UIImage(systemName: "plus"), for: .normal) // Иконка добавления
            cell.completeTrackerButton.backgroundColor?.withAlphaComponent(1)
        }
        
        //let count = trackerCounters[tracker.id, default: 0]
        let count = trackerRecordStore.countTrackerRecords(byId: Int(tracker.id))
        cell.numOfDays.text = "\(count) день"
        
        cell.delegate = self
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "Header",
            for: indexPath
        ) as? CategoryHeaderReusableView else {
            return UICollectionViewCell()
        }
        
        headerView.categoryTitle.text = filteredTrackers[indexPath.section].title
        return headerView
    }
}

extension TrackersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let totalSpacing: CGFloat = 9
        let width = (collectionView.bounds.width - totalSpacing) / 2
        return CGSize(width: width, height: 148)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
    }
}

extension TrackersViewController: TrackerCollectionViewCellDelegate {
    func didTapCompleteButton(in cell: TrackerCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let tracker = filteredTrackers[indexPath.section].trackers[indexPath.item]
        let trackerRecord = TrackerRecord(id: tracker.id, date: dateWithoutTime(from: currentDate))
        
        if let index = completedTrackers.firstIndex(of: trackerRecord) {
            do {
                try trackerRecordStore.deleteExistingTrackerRecord(trackerRecord)
            } catch {
                print("Ошибка удаления трекера из отмеченных")
            }
        } else {
            do {
                try trackerRecordStore.addNewTrackerRecord(trackerRecord)
            } catch {
                print("Ошибка добавленмя трекера в отмеченные")
            }
        }
    }
}

extension TrackersViewController: AddTrackerViewControllerDelegate {
    func getTrackerDetail(title: String, category: String, emoji: String, color: UIColor, schedule: [String]?) {
        //Закрываем все экраны одновременно после создания трекера
        dismiss(animated: true)
        
        // Создаем новый трекер с параметрами по умолчанию
        let newTracker = Tracker(
            id: (categories.flatMap { $0.trackers }.map { $0.id }.max() ?? 0) + 1,
            name: title,
            color: color,
            emoji: emoji,
            schedule: schedule ?? ["Everyday"]
        )
        
        do {
            try trackerStore.addNewTracker(newTracker)
        } catch {
            print("Ошибка при добавлении нового трекера в бд")
        }
        
        // Обновляем массив категорий и перезагружаем коллекцию
        do {
            self.categories = try trackerCategoryStore.fetchTrackerCategories()
        } catch {
            print("Ошибка при получении категории из бд")
        }
        
        datePickerValueChanged(datePicker)
    }
}
