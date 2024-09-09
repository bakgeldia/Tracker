//
//  NewTrackerCollectionViewCell.swift
//  Tracker
//
//  Created by Bakgeldi Alkhabay on 05.09.2024.
//

import UIKit

final class EmojiCell: UICollectionViewCell {
    let emoji: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(emoji)
        emoji.translatesAutoresizingMaskIntoConstraints = false
        emoji.font = UIFont.systemFont(ofSize: 32)
        
        NSLayoutConstraint.activate([
            emoji.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emoji.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
