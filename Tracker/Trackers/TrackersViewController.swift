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
    
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        return collectionView
    }()
    
    var categories = [TrackerCategory]()
    var completedTrackers = [TrackerRecord]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        setupView()
    }
    
    private func setupNavBar() {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        
        var addTrackerButton = UIButton()
        addTrackerButton = UIButton.systemButton(
            with: UIImage(named: "add_tracker_button") ?? UIImage(),
            target: self,
            action: #selector(Self.didTapAddButton)
        )
        addTrackerButton.tintColor = UIColor(red: 26.0/255.0, green: 27.0/255.0, blue: 34.0/255.0, alpha: 1)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: addTrackerButton)
    }
    
    private func setupCollectionView() {
        //TODO: setup
    }
    
    private func setupView() {
        view.backgroundColor = .white
        
        //Title label
        pageTitle.text = "Трекеры"
        pageTitle.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        pageTitle.tintColor = UIColor(red: 26.0/255.0, green: 27.0/255.0, blue: 34.0/255.0, alpha: 1)
        
        pageTitle.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageTitle)
        
        NSLayoutConstraint.activate([
            pageTitle.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            pageTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8)
        ])
        
        //Search Bar
        searchBar.placeholder = "Поиск"
        searchBar.tintColor = UIColor(red: 118.0/255.0, green: 118.0/255.0, blue: 128.0/255.0, alpha: 0.12)
        searchBar.layer.cornerRadius = 30
        searchBar.backgroundImage = UIImage()
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)
        
        NSLayoutConstraint.activate([
            searchBar.heightAnchor.constraint(equalToConstant: 36),
            searchBar.leadingAnchor.constraint(equalTo: pageTitle.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            searchBar.topAnchor.constraint(equalTo: pageTitle.bottomAnchor, constant: 7)
        ])
        
        //Error image
        errorImageView.image = UIImage(named: "error")
        errorImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(errorImageView)
        
        NSLayoutConstraint.activate([
            errorImageView.widthAnchor.constraint(equalToConstant: 80),
            errorImageView.heightAnchor.constraint(equalToConstant: 80),
            errorImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            errorImageView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 220)
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
