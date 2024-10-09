//
//  CategoryViewModel.swift
//  Tracker
//
//  Created by Bakgeldi Alkhabay on 19.09.2024.
//


import UIKit

final class CategoryViewModel {
    private let trackerCategoryStore = TrackerCategoryStore()
    
    
    var categories: [TrackerCategory] = [] {
        didSet {
            categoriesDidUpdate?(categories)
        }
    }
    
    var categoriesDidUpdate: (([TrackerCategory]) -> Void)?
    
    var selectedIndexPath: IndexPath? {
        didSet {
            selectedCategoryDidChange?(selectedIndexPath)
        }
    }
    
    var selectedCategoryDidChange: ((IndexPath?) -> Void)?
    
    init() {
        fetchCategories()
    }
    
    func fetchCategories() {
        do {
            categories = try trackerCategoryStore.fetchCategories()
        } catch {
            print("Ошибка при получении категории")
        }
    }
    
    func categoryTitle(at indexPath: IndexPath) -> String {
        return categories[indexPath.row].title
    }
    
    func selectCategory(at indexPath: IndexPath) {
        selectedIndexPath = indexPath
    }
    
    func isSelectedCategory(at indexPath: IndexPath) -> Bool {
        return indexPath == selectedIndexPath
    }
}


