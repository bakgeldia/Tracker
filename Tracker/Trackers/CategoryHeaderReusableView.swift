//
//  CategoryHeaderReusableView.swift
//  Tracker
//
//  Created by Bakgeldi Alkhabay on 24.08.2024.
//

import UIKit

final class CategoryHeaderReusableView: UICollectionReusableView {
    let categoryTitle = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(categoryTitle)
        categoryTitle.translatesAutoresizingMaskIntoConstraints = false
        categoryTitle.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        categoryTitle.textColor = UIColor(red: 26.0/255.0, green: 27.0/255.0, blue: 34.0/255.0, alpha: 1)
        
        NSLayoutConstraint.activate([
            categoryTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            categoryTitle.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
