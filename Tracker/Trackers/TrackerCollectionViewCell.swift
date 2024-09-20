//
//  TrackerCollectionViewCell.swift
//  Tracker
//
//  Created by Bakgeldi Alkhabay on 23.08.2024.
//

import UIKit

protocol TrackerCollectionViewCellDelegate: AnyObject {
    func didTapCompleteButton(in cell: TrackerCollectionViewCell)
}

final class TrackerCollectionViewCell: UICollectionViewCell {
    weak var delegate: TrackerCollectionViewCellDelegate?
    
    let emojiAndNameView = UIView()
    let emoji = UILabel()
    let trackerName = UILabel()
    let numOfDays = UILabel()
    let completeTrackerButton = UIButton()
    
    var checkedButton = false
    var trackerDate: Date?
    var dayCounter = 0
    
    private let emojiBackgroundView = UIView()
    private let daysAndButtonView = UIView()
    private let trackerView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        //Tracker View
        contentView.addSubview(trackerView)
        trackerView.translatesAutoresizingMaskIntoConstraints = false
        
        //Emoji and tracker name view
        emojiAndNameView.layer.cornerRadius = 16
        trackerView.addSubview(emojiAndNameView)
        emojiAndNameView.translatesAutoresizingMaskIntoConstraints = false
        
        // Emoji Background View
        emojiBackgroundView.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
        emojiBackgroundView.layer.cornerRadius = 12
        emojiBackgroundView.layer.masksToBounds = true
        emojiAndNameView.addSubview(emojiBackgroundView)
        emojiBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        //Emoji
        emoji.font = UIFont.systemFont(ofSize: 16) // Размер эмодзи
        emoji.textAlignment = .center
        emojiBackgroundView.addSubview(emoji)
        emoji.translatesAutoresizingMaskIntoConstraints = false
        
        //Tracker name
        trackerName.textColor = .white
        trackerName.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        emojiAndNameView.addSubview(trackerName)
        trackerName.translatesAutoresizingMaskIntoConstraints = false
        //trackerName.numberOfLines = 0
        
        //Num of days and button
        trackerView.addSubview(daysAndButtonView)
        daysAndButtonView.translatesAutoresizingMaskIntoConstraints = false
        
        //Days label
        numOfDays.text = "\(dayCounter) день"
        numOfDays.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        daysAndButtonView.addSubview(numOfDays)
        numOfDays.translatesAutoresizingMaskIntoConstraints = false
        
        //Button
        completeTrackerButton.setImage(UIImage(systemName: "plus"), for: .normal)
        completeTrackerButton.imageView?.tintColor = .white
        completeTrackerButton.layer.cornerRadius = 22
        completeTrackerButton.addTarget(self, action: #selector(self.didTapCompleteButton), for: .touchUpInside)
        daysAndButtonView.addSubview(completeTrackerButton)
        completeTrackerButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
            trackerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            trackerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            trackerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            trackerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            emojiAndNameView.topAnchor.constraint(equalTo: trackerView.topAnchor),
            emojiAndNameView.leadingAnchor.constraint(equalTo: trackerView.leadingAnchor),
            emojiAndNameView.trailingAnchor.constraint(equalTo: trackerView.trailingAnchor),
            emojiAndNameView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiBackgroundView.topAnchor.constraint(equalTo: emojiAndNameView.topAnchor, constant: 12),
            emojiBackgroundView.leadingAnchor.constraint(equalTo: emojiAndNameView.leadingAnchor, constant: 12),
            emojiBackgroundView.widthAnchor.constraint(equalToConstant: 24),
            emojiBackgroundView.heightAnchor.constraint(equalToConstant: 24),
            
            emoji.centerXAnchor.constraint(equalTo: emojiBackgroundView.centerXAnchor),
            emoji.centerYAnchor.constraint(equalTo: emojiBackgroundView.centerYAnchor),
            
            trackerName.topAnchor.constraint(equalTo: emoji.bottomAnchor, constant: 8),
            trackerName.leadingAnchor.constraint(equalTo: emojiAndNameView.leadingAnchor, constant: 12),
            trackerName.trailingAnchor.constraint(equalTo: emojiAndNameView.trailingAnchor, constant: -12),
            trackerName.bottomAnchor.constraint(equalTo: emojiAndNameView.bottomAnchor, constant: -12),

            daysAndButtonView.topAnchor.constraint(equalTo: emojiAndNameView.bottomAnchor),
            daysAndButtonView.leadingAnchor.constraint(equalTo: emojiAndNameView.leadingAnchor),
            daysAndButtonView.trailingAnchor.constraint(equalTo: emojiAndNameView.trailingAnchor),
            daysAndButtonView.heightAnchor.constraint(equalToConstant: 58),
            
            numOfDays.leadingAnchor.constraint(equalTo: daysAndButtonView.leadingAnchor, constant: 12),
            numOfDays.topAnchor.constraint(equalTo: emojiAndNameView.bottomAnchor, constant: 16),
            numOfDays.widthAnchor.constraint(equalToConstant: 101),
            numOfDays.centerYAnchor.constraint(equalTo: completeTrackerButton.centerYAnchor),
            
            completeTrackerButton.topAnchor.constraint(equalTo: emojiAndNameView.bottomAnchor, constant: 8),
            completeTrackerButton.heightAnchor.constraint(equalToConstant: 44),
            completeTrackerButton.widthAnchor.constraint(equalToConstant: 44),
            completeTrackerButton.trailingAnchor.constraint(equalTo: daysAndButtonView.trailingAnchor, constant: -10),
        ])
    }
    
    @objc
    private func didTapCompleteButton() {
        delegate?.didTapCompleteButton(in: self)
    }
}
