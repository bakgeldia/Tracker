//
//  ColorCollectionViewCell.swift
//  Tracker
//
//  Created by Bakgeldi Alkhabay on 05.09.2024.
//

import UIKit

final class ColorCell: UICollectionViewCell {
    let square = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        square.layer.cornerRadius = 8
        square.layer.masksToBounds = true
        contentView.addSubview(square)
        square.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            square.widthAnchor.constraint(equalToConstant: 40),
            square.heightAnchor.constraint(equalToConstant: 40),
            square.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            square.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
