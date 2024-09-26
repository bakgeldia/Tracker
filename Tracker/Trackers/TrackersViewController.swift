//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Bakgeldi Alkhabay on 13.08.2024.
//

import UIKit

final class TrackersViewController: UIViewController, UISearchBarDelegate {
    
    var categories = [TrackerCategory]()
    var completedTrackers = [TrackerRecord]()
    var currentDate: Date = Date()
    
    private var filteredTrackers = [TrackerCategory]()
    
    private var addTrackerButton = UIButton()
    private var datePicker = UIDatePicker()
    private var pageTitle = UILabel()
    private var searchBar = UISearchBar()
    private let errorImageView = UIImageView()
    private let errorLabel = UILabel()
    private var searchController = UISearchController()
    private let filtersButton = UIButton(type: .system)
    
    private var selectedFilter = "Все трекеры"
    
    private let trackerStore = TrackerStore()
    private let trackerCategoryStore = TrackerCategoryStore()
    private let trackerRecordStore = TrackerRecordStore()
    
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
        let category1 = TrackerCategory(title: "Домашний уют", trackers: [])
        
        if !trackerCategoryStore.categoryExists(category2) {
            do {
                try trackerCategoryStore.addNewTrackerCategory(category2)
            } catch {
                print(error)
            }
        }
        
        if !trackerCategoryStore.categoryExists(category1) {
            do {
                try trackerCategoryStore.addNewTrackerCategory(category1)
            } catch {
                print(error)
            }
        }
        
        getCategories()
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
        
        setupFiltersButton()
        changefilterVisibility()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterTrackers(for: searchText)
        updatePlaceholderVisibility()
        collectionView.reloadData()
    }
    
    func changefilterVisibility() {
        if filteredTrackers.flatMap({ $0.trackers }).isEmpty {
            filtersButton.isHidden = true
        } else {
            filtersButton.isHidden = false
        }
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        datePicker.isEnabled = true
        
        currentDate = sender.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let selectedDay = dateFormatter.string(from: currentDate)
        let capitalizedDay = selectedDay.capitalized
        
        let filters = ["Все трекеры", "Трекеры на сегодня", "Завершенные", "Незавершенные"]
        
        switch selectedFilter {
        case filters[0]:
            getCategories()
            filteredTrackers = categories.compactMap { category in
                let filteredTrackers = category.trackers.filter { tracker in
                    tracker.schedule.contains(capitalizedDay) || tracker.schedule.contains("Everyday")
                }
                return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filteredTrackers)
            }
        case filters[1]:
            getCategories()
            datePicker.isEnabled = false
            datePicker.setDate(Date(), animated: false)
            filteredTrackers = categories.compactMap { category in
                let filteredTrackers = category.trackers.filter { tracker in
                    tracker.schedule.contains(capitalizedDay) || tracker.schedule.contains("Everyday")
                }
                return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filteredTrackers)
            }
        case filters[2]:
            getCategories()
            do {
                filteredTrackers = try trackerCategoryStore.fetchCategoriesWithCompletedTrackers(for: dateWithoutTime(from: currentDate))
                let completedCategories = try trackerCategoryStore.fetchCategoriesWithCompletedTrackers(for: dateWithoutTime(from: currentDate))
                print(completedCategories)
            } catch {
                print("no completed trackers")
            }
        default:
            getCategories()
            do {
                filteredTrackers = try trackerCategoryStore.fetchCategoriesWithUnmarkedTrackers(for: dateWithoutTime(from: currentDate))
                let unmarkedCategories = try trackerCategoryStore.fetchCategoriesWithUnmarkedTrackers(for: dateWithoutTime(from: dateWithoutTime(from: currentDate)))
                let trackers = try trackerRecordStore.filterUnmarkedTrackers(for: currentDate)
                print("unmarked")
                print(unmarkedCategories)
            } catch {
                print("no uncompleted trackers")
            }
        }
        
        // Проверяем, есть ли категория "Закрепленные" и перемещаем её на первое место
        if let pinnedCategoryIndex = filteredTrackers.firstIndex(where: { $0.title == "Закрепленные" }) {
            let pinnedCategory = filteredTrackers.remove(at: pinnedCategoryIndex)
            filteredTrackers.insert(pinnedCategory, at: 0)
        }
        changefilterVisibility()
        updatePlaceholderVisibility()
        collectionView.reloadData()
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
        addTrackerButton.tintColor = Colors.black
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: addTrackerButton)
        
        let trackersVCTitle = NSLocalizedString("trackersVC.title", comment: "Trackers View Controller Title")
        navigationItem.title = trackersVCTitle
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        
        let searchBarPlaceholder = NSLocalizedString("searchBar.placeholer", comment: "SearchBar placeholder")
        searchController.searchBar.placeholder = searchBarPlaceholder
        searchController.searchBar.tintColor = Colors.searchBarGray
        searchController.searchBar.layer.cornerRadius = 30
        searchController.searchBar.backgroundImage = UIImage()
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        
        let searchBarCancel = NSLocalizedString("searchBar.cancel", comment: "SearchBar cancel")
        searchController.searchBar.setValue(searchBarCancel, forKey: "cancelButtonText")
        
        // Настройка кнопки отмены
        let cancelButtonAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: Colors.cancelSearchBarBlue,
            .font: UIFont.systemFont(ofSize: 17, weight: .regular)
        ]
        
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(cancelButtonAttributes, for: .normal)
        
        definesPresentationContext = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
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
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
        collectionView.alwaysBounceVertical = true
        
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
        
        let errorLabelText = NSLocalizedString("errorLabel.text", comment: "Error label")
        errorLabel.text = errorLabelText
        errorLabel.textColor = Colors.black
        errorLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(errorLabel)
        
        NSLayoutConstraint.activate([
            errorLabel.topAnchor.constraint(equalTo: errorImageView.bottomAnchor, constant: 8),
            errorLabel.centerXAnchor.constraint(equalTo: errorImageView.centerXAnchor)
        ])
    }
    
    private func setupFiltersButton() {
        filtersButton.isHidden = false
        filtersButton.setTitle("Фильтры", for: .normal)
        filtersButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        filtersButton.setTitleColor(.white, for: .normal)
        filtersButton.layer.cornerRadius = 16
        filtersButton.backgroundColor = Colors.cancelSearchBarBlue
        filtersButton.addTarget(self, action: #selector(filtersButtonTapped), for: .touchUpInside)
        
        // Add the button to the view
        view.addSubview(filtersButton)
        view.bringSubviewToFront(filtersButton)
        
        // Set button constraints
        filtersButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            filtersButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filtersButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
            filtersButton.heightAnchor.constraint(equalToConstant: 50),
            filtersButton.widthAnchor.constraint(equalToConstant: 114)
        ])
    }
    
    @objc private func filtersButtonTapped() {
        let filtersVC = FiltersViewController()
       
        let popover = UIPopoverPresentationController(presentedViewController: filtersVC, presenting: self)
        popover.sourceView = self.view
        popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
        popover.permittedArrowDirections = []
        
        filtersVC.modalPresentationStyle = .popover
        filtersVC.delegate = self
        filtersVC.selectedFilter = selectedFilter
        
        present(filtersVC, animated: true, completion: nil)
    }
    
    private func getCategories() {
        do {
            categories = try trackerCategoryStore.fetchTrackerCategories()
        } catch {
            print("Ошибка при получении категории")
        }
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
        addTrackerVC.delegate = self
        
        // Отображаем popover
        present(addTrackerVC, animated: true, completion: nil)
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
        
        let count = trackerRecordStore.countTrackerRecords(byId: Int(tracker.id))
        let daysString = String.localizedStringWithFormat(
            NSLocalizedString("numberOfDays", comment: "Number of completed days"),
            count
        )
        
        cell.numOfDays.text = daysString
        cell.pinImageView.isHidden = !tracker.isPinned
        
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
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let tracker = filteredTrackers[indexPath.section].trackers[indexPath.item]
        
        // Возвращаем конфигурацию для контекстного меню
        return UIContextMenuConfiguration(
            identifier: indexPath as NSCopying,
            previewProvider: nil,
            actionProvider: { _ in
                // Настройка элементов контекстного меню
                let pinActionTitle = tracker.isPinned ? "Открепить" : "Закрепить"
                let pinAction = UIAction(title: pinActionTitle) { _ in
                    self.togglePin(for: indexPath)
                }
                
                let editAction = UIAction(title: "Редактировать") { _ in
                    self.editTracker(for: indexPath)
                }
                
                let deleteAction = UIAction(title: "Удалить", attributes: .destructive) { _ in
                    self.deleteTracker(for: indexPath)
                }
                
                return UIMenu(title: "", children: [pinAction, editAction, deleteAction])
            }
        )
    }
    
    
    // Метод для предотвращения случайного свайпа при долгом нажатии
    func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        animator.preferredCommitStyle = .dismiss
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath else { return nil }
        guard let cell = collectionView.cellForItem(at: indexPath) as? TrackerCollectionViewCell else { return nil }
        
        // Выделяем только часть ячейки, например, иконку
        let targetView = cell.emojiAndNameView
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        
        return UITargetedPreview(view: targetView, parameters: parameters)
    }
    
    private func togglePin(for indexPath: IndexPath) {
        // Получаем трекер по indexPath
        let tracker = filteredTrackers[indexPath.section].trackers[indexPath.item]
        
        // Логика для закрепления/открепления трекера
        // Обновляем данные в хранилище или базе данных
        do {
            try trackerStore.updateTrackerPinStatus(tracker)
            
            if !tracker.isPinned {
                let pinnedCategory = TrackerCategory(title: "Закрепленные", trackers: [])
                if !trackerCategoryStore.categoryExists(pinnedCategory) {
                    try trackerCategoryStore.addNewTrackerCategory(pinnedCategory)
                }
                
                try trackerStore.updateTrackerCategoryToPinned(tracker)
                print("Category changed to Pinned")
            } else {
                //TO-DO: убрать из категории "Закрепленные"
                try trackerStore.updateTrackerCategoryToPrevious(tracker)
                print("Category back to prev")
            }
            
        } catch {
            print("Ошибка при закрепления/открепления трекера: \(error)")
        }
        
        datePickerValueChanged(datePicker)
    }
    
    private func editTracker(for indexPath: IndexPath) {
        let tracker = filteredTrackers[indexPath.section].trackers[indexPath.item]
        
        if tracker.schedule.contains("Everyday") {
            showEditEventVC(tracker)
        } else {
            showEditHabitVC(tracker)
        }
        
        datePickerValueChanged(datePicker)
    }
    
    private func showEditHabitVC(_ tracker: Tracker) {
        let editHabitVC = EditHabitViewController()
        editHabitVC.tracker = tracker
        
        let popover = UIPopoverPresentationController(presentedViewController: editHabitVC, presenting: self)
        popover.sourceView = self.view
        popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
        popover.permittedArrowDirections = []
        editHabitVC.modalPresentationStyle = .popover
        editHabitVC.delegate = self
        
        present(editHabitVC, animated: true, completion: nil)
    }
    
    private func showEditEventVC(_ tracker: Tracker) {
        let editEventVC = EditEventViewController()
        editEventVC.tracker = tracker
        
        let popover = UIPopoverPresentationController(presentedViewController: editEventVC, presenting: self)
        popover.sourceView = self.view
        popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
        popover.permittedArrowDirections = []
        editEventVC.modalPresentationStyle = .popover
        editEventVC.delegate = self
        
        present(editEventVC, animated: true, completion: nil)
    }
    
    private func deleteTracker(for indexPath: IndexPath) {
        showDeleteConfirmation(indexPath: indexPath)
    }
    
    private func showDeleteConfirmation(indexPath: IndexPath) {
        let alert = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let messageAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 13),
            .foregroundColor: UIColor.black
        ]
        let messageAttributedString = NSAttributedString(string: "Уверены что хотите удалить трекер?", attributes: messageAttributes)
        alert.setValue(messageAttributedString, forKey: "attributedMessage")
        
        let deleteAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20, weight: .regular),
            .foregroundColor: UIColor.red
        ]
        let deleteAttributedTitle = NSAttributedString(string: "Удалить", attributes: deleteAttributes)
        
        alert.addAction(UIAlertAction(
            title: deleteAttributedTitle.string,
            style: .destructive,
            handler: { _ in
                self.confirmTrackerDeletion(indexPath)
            }
        ))
        
        let cancelAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20, weight: .bold),
            .foregroundColor: UIColor.blue
        ]
        let cancelAttributedTitle = NSAttributedString(string: "Отменить", attributes: cancelAttributes)
        
        alert.addAction(UIAlertAction(
            title: cancelAttributedTitle.string,
            style: .cancel,
            handler: { _ in }
        ))
        
        present(alert, animated: true, completion: nil)
    }
    
    private func confirmTrackerDeletion(_ indexPath: IndexPath) {
        let tracker = filteredTrackers[indexPath.section].trackers[indexPath.item]
        
        do {
            try trackerStore.deleteTracker(tracker)
        } catch {
            print("Error deleting tracker")
        }
        
        datePickerValueChanged(datePicker)
    }
    
    private func getFilterName() {
        if let filter = UserDefaults.standard.string(forKey: "selectedFilter") {
            selectedFilter = filter
        } else {
            selectedFilter = "Все трекеры"
        }
        datePickerValueChanged(datePicker)
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
        
        if completedTrackers.firstIndex(of: trackerRecord) != nil {
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
        
        if tracker.schedule.contains("Everyday") {
            do {
                try trackerStore.deleteTracker(tracker)
            } catch {
                print("Error deleting tracker")
            }
        }
        datePickerValueChanged(datePicker       )
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
            schedule: schedule ?? ["Everyday"],
            isPinned: false,
            trackerCategory: category
        )
        
        do {
            try trackerStore.addNewTracker(newTracker)
        } catch {
            print("Ошибка при добавлении нового трекера в бд")
        }
        
        datePickerValueChanged(datePicker)
    }
}

extension TrackersViewController: EditHabitViewControllerDelegate {
    func updateHabit(id: UInt, title: String, category: String, emoji: String, color: UIColor, schedule: [String], isPinned: Bool) {
        dismiss(animated: true)
        
        let tracker = Tracker(
            id: id,
            name: title,
            color: color,
            emoji: emoji,
            schedule: schedule,
            isPinned: isPinned,
            trackerCategory: category
        )
        
        do {
            try trackerStore.updateExistingTracker(with: tracker)
        } catch {
            print("Ошибка при обновлении привычки")
        }
        
        datePickerValueChanged(datePicker)
        
    }
}

extension TrackersViewController: EditEventViewControllerDelegate {
    func updateEvent(id: UInt, title: String, category: String, emoji: String, color: UIColor, schedule: [String], isPinned: Bool) {
        dismiss(animated: true)
        
        let tracker = Tracker(
            id: id,
            name: title,
            color: color,
            emoji: emoji,
            schedule: schedule,
            isPinned: isPinned,
            trackerCategory: category
        )
        
        do {
            try trackerStore.updateExistingTracker(with: tracker)
        } catch {
            print("Ошибка при обновлении события")
        }
        
        datePickerValueChanged(datePicker)
    }
}

extension TrackersViewController: FiltersViewControllerDelegate {
    func getFilter(_ filter: String) {
        errorImageView.image = UIImage(named: "notFound")
        errorLabel.text = "Ничего не найдено"
        
        getFilterName()
    }
}
