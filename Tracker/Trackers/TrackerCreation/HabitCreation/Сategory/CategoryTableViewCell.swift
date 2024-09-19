//
//  CategoryTableViewCell.swift
//  Tracker
//
//  Created by Bakgeldi Alkhabay on 19.09.2024.
//

import UIKit

final class CategoryTableViewCell: UITableViewCell {
    
    static let identifier = "CategoryTableViewCell"
    private let titleLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        titleLabel.text = "Category"
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        titleLabel.textColor = UIColor(red: 26.0/255.0, green: 27.0/255.0, blue: 34.0/255.0, alpha: 1)
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true
    }
    
    func configure(with title: String, isSelected: Bool) {
        titleLabel.text = title
        accessoryType = isSelected ? .checkmark : .none
        backgroundColor = UIColor(red: 230.0/255.0, green: 232.0/255.0, blue: 235.0/255.0, alpha: 0.3)
    }
}

