//
//  CategoryViewController.swift
//  Tracker
//
//  Created by Bakgeldi Alkhabay on 24.08.2024.
//

import UIKit

protocol CategoryViewControllerDelegate: AnyObject {
    func didSelectCategory(_ category: TrackerCategory)
}

final class CategoryViewController: UIViewController {
    
    weak var delegate: CategoryViewControllerDelegate?
    
    private let titleLabel = UILabel()
    private let tableView = UITableView()
    private let addButton = UIButton()
    private var selectedIndexPath: IndexPath?
    
    var categories: [TrackerCategory] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        
        // Title Label
        titleLabel.text = "Категория"
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = UIColor(red: 26.0/255.0, green: 27.0/255.0, blue: 34.0/255.0, alpha: 1)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // Table View
        tableView.layer.cornerRadius = 16
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CategoryCell")
        tableView.dataSource = self
        tableView.delegate = self
        
        // Add Button
        addButton.setTitle("Добавить категорию", for: .normal)
        addButton.setTitleColor(.white, for: .normal)
        addButton.backgroundColor = UIColor(red: 26.0/255.0, green: 27.0/255.0, blue: 34.0/255.0, alpha: 1)
        addButton.layer.cornerRadius = 16
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.addTarget(self, action: #selector(addCategory), for: .touchUpInside)
        view.addSubview(addButton)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            // Title Label
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Table View
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -20),
            
            // Add Button
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc
    private func addCategory() {
        print("Add Category button tapped")
    }
}

extension CategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Возвращаем количество категорий
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        // Устанавливаем название категории в текст метки ячейки
        cell.textLabel?.text = categories[indexPath.row].title
        cell.backgroundColor = UIColor(red: 230.0/255.0, green: 232.0/255.0, blue: 235.0/255.0, alpha: 0.3)
        return cell
    }
}

extension CategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Получаем выбранную категорию
        let selectedCategory = categories[indexPath.row]
        
        // Сначала убираем галочку с ранее выбранной ячейки, если она существует
        if let previousIndexPath = selectedIndexPath {
            if previousIndexPath != indexPath {
                let previousCell = tableView.cellForRow(at: previousIndexPath)
                previousCell?.accessoryType = .none
            }
        }
        
        // Устанавливаем галочку на текущей выбранной ячейке
        let currentCell = tableView.cellForRow(at: indexPath)
        currentCell?.accessoryType = .checkmark
        
        // Обновляем выбранную ячейку
        selectedIndexPath = indexPath
        tableView.deselectRow(at: indexPath, animated: true)
        
        delegate?.didSelectCategory(selectedCategory)
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Убираем сепаратор для последней ячейки
        if indexPath.row == categories.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
        
        // Добавляем скругление внизу таблицы для последней ячейки
        if indexPath.row == categories.count - 1 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.clipsToBounds = true
        } else {
            cell.layer.cornerRadius = 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}
