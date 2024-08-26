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
        categoryTitle.font = UIFont.boldSystemFont(ofSize: 16)
        categoryTitle.textColor = .black
        
        NSLayoutConstraint.activate([
            categoryTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            categoryTitle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            categoryTitle.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
