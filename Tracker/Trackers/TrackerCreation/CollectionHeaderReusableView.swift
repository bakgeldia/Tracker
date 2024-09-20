//
//  CollectionHeaderReusableView.swift
//  Tracker
//
//  Created by Bakgeldi Alkhabay on 06.09.2024.
//

import UIKit

final class CollectionHeaderReusableView: UICollectionReusableView {
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
        categoryTitle.textColor = Colors.black
        
        NSLayoutConstraint.activate([
            categoryTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            categoryTitle.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
