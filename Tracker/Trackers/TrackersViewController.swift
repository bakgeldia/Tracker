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
    
    private func setupView() {
        view.backgroundColor = .white
        
//        //Left top Button
//        addTrackerButton = UIButton.systemButton(
//            with: UIImage(named: "add_tracker_button") ?? UIImage(),
//            target: self,
//            action: #selector(Self.didTapAddButton)
//        )
//        addTrackerButton.tintColor = UIColor(red: 26.0/255.0, green: 27.0/255.0, blue: 34.0/255.0, alpha: 1)
//        addTrackerButton.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(addTrackerButton)
//        
//        NSLayoutConstraint.activate([
//            addTrackerButton.widthAnchor.constraint(equalToConstant: 44),
//            addTrackerButton.heightAnchor.constraint(equalToConstant: 44),
//            addTrackerButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 6),
//            addTrackerButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1),
//        ])
//        
//        //Date picker
//        datePicker.locale = .current
//        datePicker.datePickerMode = .date
//        datePicker.preferredDatePickerStyle = .compact
//        
//        datePicker.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(datePicker)
//        
//        NSLayoutConstraint.activate([
//            datePicker.widthAnchor.constraint(equalToConstant: 100),
//            datePicker.heightAnchor.constraint(equalToConstant: 34),
//            datePicker.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
//            datePicker.centerYAnchor.constraint(equalTo: addTrackerButton.centerYAnchor)
//        ])
        
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
    
    @objc
    private func didTapAddButton() {
        //TODO: adding new tracker
        
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let formattedDate = dateFormatter.string(from: selectedDate)
        print("Выбранная дата: \(formattedDate)")
    }
}
