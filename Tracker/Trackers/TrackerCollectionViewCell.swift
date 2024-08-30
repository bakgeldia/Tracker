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
    
    private let daysAndButtonView = UIView()
    let numOfDays = UILabel()
    let completeTrackerButton = UIButton()
    
    private let trackerView = UIView()
    var checkedButton = false
    
    var trackerDate: Date?
    var dayCounter = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        setupCell()
    }
    
    private func setupCell() {
        //Tracker View
        contentView.addSubview(trackerView)
        trackerView.translatesAutoresizingMaskIntoConstraints = false
        
        //Emoji and tracker name view
        emojiAndNameView.layer.cornerRadius = 16
        trackerView.addSubview(emojiAndNameView)
        emojiAndNameView.translatesAutoresizingMaskIntoConstraints = false
        
        
        //Emoji
        emojiAndNameView.addSubview(emoji)
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
            
            emoji.heightAnchor.constraint(equalToConstant: 24),
            emoji.widthAnchor.constraint(equalToConstant: 24),
            emoji.topAnchor.constraint(equalTo: emojiAndNameView.topAnchor, constant: 12),
            emoji.leadingAnchor.constraint(equalTo: emojiAndNameView.leadingAnchor, constant: 12),
            
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
//        checkedButton = !checkedButton
//        
//        if checkedButton {
//            completeTrackerButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
//            completeTrackerButton.backgroundColor?.withAlphaComponent(0.3)
//            dayCounter += 1
//            numOfDays.text = "\(dayCounter) день"
//        } else {
//            completeTrackerButton.setImage(UIImage(systemName: "plus"), for: .normal)
//            completeTrackerButton.backgroundColor?.withAlphaComponent(1)
//            dayCounter -= 1
//            numOfDays.text = "\(dayCounter) день"
//        }
        
        delegate?.didTapCompleteButton(in: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
