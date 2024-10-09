//
//  Colors.swift
//  Tracker
//
//  Created by Bakgeldi Alkhabay on 20.09.2024.
//

import UIKit

struct Colors {
    static let black = UIColor(red: 26.0/255.0, green: 27.0/255.0, blue: 34.0/255.0, alpha: 1)
    static let searchBarGray = UIColor(red: 118.0/255.0, green: 118.0/255.0, blue: 128.0/255.0, alpha: 0.12)
    static let lightGray = UIColor(red: 230.0/255.0, green: 232.0/255.0, blue: 235.0/255.0, alpha: 0.3)
    static let selectedEmojiColor = UIColor(red: 230.0/255.0, green: 232.0/255.0, blue: 235.0/255.0, alpha: 1.0)
    static let cancelSearchBarBlue = UIColor(red: 55.0/255.0, green: 114.0/255.0, blue: 231.0/255.0, alpha: 1)
    static let redColor = UIColor(red: 245.0/255.0, green: 107.0/255.0, blue: 108.0/255.0, alpha: 1)
    static let descriptionLabelColor = UIColor(red: 174.0/255.0, green: 175.0/255.0, blue: 180.0/255.0, alpha: 1)
    static let datePickerColor = UIColor(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 1)
    
    static let categoryHeaderColor = UIColor { (traits: UITraitCollection) -> UIColor in
        if traits.userInterfaceStyle == .light {
            return black
        } else {
            return UIColor.white
        }
    }
    
    static let addTrackerButtonColor = UIColor { (traits: UITraitCollection) -> UIColor in
        if traits.userInterfaceStyle == .light {
            return black
        } else {
            return UIColor.white
        }
    }
    
    static let tabBarShadowColor = UIColor { (traits: UITraitCollection) -> UIColor in
        if traits.userInterfaceStyle == .light {
            return .lightGray
        } else {
            return .black
        }
    }
    
    static let searchBarPlaceholderColor = UIColor { (traits: UITraitCollection) -> UIColor in
        if traits.userInterfaceStyle == .light {
            return descriptionLabelColor
        } else {
            return UIColor(red: 235.0/255.0, green: 235.0/255.0, blue: 245.0/255.0, alpha: 1)
        }
    }
    
    static let searchBarTextFieldBackground = UIColor { (traits: UITraitCollection) -> UIColor in
        if traits.userInterfaceStyle == .light {
            return searchBarGray
        } else {
            return searchBarGray.withAlphaComponent(0.24)
        }
    }
    
    static let searchBarSearchIcon = UIColor { (traits: UITraitCollection) -> UIColor in
        if traits.userInterfaceStyle == .light {
            return searchBarGray
        } else {
            return UIColor(red: 235.0/255.0, green: 235.0/255.0, blue: 245.0/255.0, alpha: 1)
        }
    }
    
    static let errorLabelColor = UIColor { (traits: UITraitCollection) -> UIColor in
        if traits.userInterfaceStyle == .light {
            return black
        } else {
            return .white
        }
    }
    
    static let plusButtonColor = UIColor { (traits: UITraitCollection) -> UIColor in
        if traits.userInterfaceStyle == .light {
            return .white
        } else {
            return black
        }
    }
    
    static let statisticsTitle = UIColor { (traits: UITraitCollection) -> UIColor in
        if traits.userInterfaceStyle == .light {
            return black
        } else {
            return .white
        }
    }
}
