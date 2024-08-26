//
//  NonReguarEventViewController.swift
//  Tracker
//
//  Created by Bakgeldi Alkhabay on 27.08.2024.
//

import UIKit

final class NonRegularEventViewController: UIViewController {
    
    private let titleLabel = UILabel()
    private let textField = UITextField()
    private let tableView = UITableView()
    
    private let buttonStackView = UIStackView()
    private let cancelButton = UIButton()
    private let createButton = UIButton()
    
    var categories = [TrackerCategory]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        
        // Title Label
        titleLabel.text = "Нерегулярное событие"
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = UIColor(red: 26.0/255.0, green: 27.0/255.0, blue: 34.0/255.0, alpha: 1)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // TextField
        textField.placeholder = "Введите название события"
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
        cancelButton.addTarget(self, action: #selector(cancelCreatingNewEvent), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.addArrangedSubview(cancelButton)
        
        // Create Button
        createButton.setTitle("Создать", for: .normal)
        createButton.setTitleColor(.white, for: .normal)
        createButton.backgroundColor = UIColor(red: 26.0/255.0, green: 27.0/255.0, blue: 34.0/255.0, alpha: 1)
        createButton.layer.cornerRadius = 16
        createButton.addTarget(self, action: #selector(createNewEvent), for: .touchUpInside)
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
            tableView.heightAnchor.constraint(equalToConstant: 75), // Only one row, so height is smaller
            
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
    private func cancelCreatingNewEvent() {
        dismiss(animated: true)
        print("Cancel button tapped")
    }
    
    @objc
    private func createNewEvent() {
        dismiss(animated: true)
        print("Create button tapped")
    }
    
    private func showCategoriesPopover() {
        let categoryVC = CategoryViewController()
        let popover = UIPopoverPresentationController(presentedViewController: categoryVC, presenting: self)
        popover.sourceView = self.view
        popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
        popover.permittedArrowDirections = []
        
        categoryVC.modalPresentationStyle = .popover
        categoryVC.categories = self.categories
        
        self.present(categoryVC, animated: true, completion: nil)
    }
}

extension NonRegularEventViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 // Only one cell now
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "Категория"
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = UIColor(red: 230.0/255.0, green: 232.0/255.0, blue: 235.0/255.0, alpha: 0.3)
        return cell
    }
}

extension NonRegularEventViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Handle button taps
        print("Категория tapped")
        showCategoriesPopover()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
