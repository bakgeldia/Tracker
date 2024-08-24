//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Bakgeldi Alkhabay on 13.08.2024.
//

import UIKit

final class TrackersViewController: UIViewController {
    
    private var addTrackerButton = UIButton()
    private var datePicker = UIDatePicker()
    private var pageTitle = UILabel()
    private var searchBar = UISearchBar()
    private let errorImageView = UIImageView()
    private let errorLabel = UILabel()
    private let searchController = UISearchController()
    
    var categories = [TrackerCategory]()
    var completedTrackers = [TrackerRecord]()
    
    private let emojies = [
        "🍇", "🍈", "🍉", "🍊", "🍋", "🍌", "🍍", "🥭", "🍎", "🍏", "🍐", "🍒",
        "🍓", "🫐", "🥝", "🍅", "🫒", "🥥", "🥑", "🍆", "🥔", "🥕", "🌽", "🌶️",
        "🫑", "🥒", "🥬", "🥦", "🧄", "🧅", "🍄",
    ]
    
    private var visibleEmojies: [String] = []
    
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
        
        setupNavBar()
        setupView()
        
        //-------------- Example ------------------
        let tracker1 = Tracker(id: 0, name: "Поливать растения", color: UIColor(red: 51.0/255.0, green: 207.0/255.0, blue: 105.0/255.0, alpha: 1), emoji: "🍇", schedule: ["Monday", "Friday"])
        let tracker2 = Tracker(id: 1, name: "Читать книгу", color: UIColor(red: 255.0/255.0, green: 102.0/255.0, blue: 102.0/255.0, alpha: 1), emoji: "📚", schedule: ["Wednesday"])
        let tracker3 = Tracker(id: 2, name: "Медитация", color: UIColor(red: 0.0/255.0, green: 150.0/255.0, blue: 255.0/255.0, alpha: 1), emoji: "🧘‍♂️", schedule: ["Everyday"])
        let tracker4 = Tracker(id: 3, name: "Занятия спортом", color: UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 0.0/255.0, alpha: 1), emoji: "🏋️‍♂️", schedule: ["Tuesday", "Thursday"])
        let tracker5 = Tracker(id: 4, name: "Уборка", color: UIColor(red: 75.0/255.0, green: 0.0/255.0, blue: 130.0/255.0, alpha: 1), emoji: "🧹", schedule: ["Saturday"])
        
        let category1 = TrackerCategory(title: "Домашний уют", trackers: [tracker1, tracker5])
        let category2 = TrackerCategory(title: "Здоровый образ жизни", trackers: [tracker2, tracker3, tracker4])
        
        categories = [category1, category2]
        //-------------- Example ------------------
        
        setupCollectionView()
    }
    
    private func setupNavBar() {
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
        
        
        searchController.searchBar.placeholder = "Поиск"
        searchController.searchBar.tintColor = UIColor(red: 118.0/255.0, green: 118.0/255.0, blue: 128.0/255.0, alpha: 0.12)
        searchController.searchBar.layer.cornerRadius = 30
        searchController.searchBar.backgroundImage = UIImage()
        
        
        navigationItem.searchController = searchController
    }
    
    @objc
    private func addNextEmoji() {
        guard visibleEmojies.count < emojies.count else { return }

        let nextEmojiIndex = visibleEmojies.count
        visibleEmojies.append(emojies[nextEmojiIndex])
        collectionView.performBatchUpdates {
            collectionView.insertItems(at: [IndexPath(item: nextEmojiIndex, section: 0)])
        }
    }

    @objc
    private func removeLastEmoji() {
        guard visibleEmojies.count > 0 else { return }

        let lastEmojiIndex = visibleEmojies.count - 1
        visibleEmojies.removeLast()
        collectionView.performBatchUpdates {
            collectionView.deleteItems(at: [IndexPath(item: lastEmojiIndex, section: 0)])
        }
    }
    
    private func setupCollectionView() {
        //TODO: setup collection view
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])

        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func setupView() {
        view.backgroundColor = .white
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAddTracker" {
            let destinationVC = segue.destination as! AddTrackerViewController
            destinationVC.modalPresentationStyle = .overCurrentContext
            destinationVC.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
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
        
        // Отображаем popover
        self.present(addTrackerVC, animated: true, completion: nil)
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let formattedDate = dateFormatter.string(from: selectedDate)
        print("Выбранная дата: \(formattedDate)")
    }
}

extension TrackersViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return categories.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! TrackerCollectionViewCell
        
        cell.emoji.text = categories[indexPath.row].trackers[0].emoji
        cell.trackerName.text = categories[indexPath.row].trackers[0].name
        return cell
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
        //return CGSize(width: collectionView.bounds.width / 2, height: 148)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 9
    }
}


//        //Error image
//        errorImageView.image = UIImage(named: "error")
//        errorImageView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(errorImageView)
//
//        NSLayoutConstraint.activate([
//            errorImageView.widthAnchor.constraint(equalToConstant: 80),
//            errorImageView.heightAnchor.constraint(equalToConstant: 80),
//            errorImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
//            errorImageView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 220)
//        ])
//
//        errorLabel.text = "Что будем отслеживать?"
//        errorLabel.textColor = UIColor(red: 26.0/255.0, green: 27.0/255.0, blue: 34.0/255.0, alpha: 1)
//        errorLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
//        errorLabel.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(errorLabel)
//
//        NSLayoutConstraint.activate([
//            errorLabel.topAnchor.constraint(equalTo: errorImageView.bottomAnchor, constant: 8),
//            errorLabel.centerXAnchor.constraint(equalTo: errorImageView.centerXAnchor)
//        ])
