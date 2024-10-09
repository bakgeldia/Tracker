//
//  OnboardingPageType.swift
//  Tracker
//
//  Created by Bakgeldi Alkhabay on 20.09.2024.
//

import Foundation

enum OnboardingPageType {
    case first
    case second
    
    var imageName: String {
        switch self {
        case .first:
            return "onboarding1"
        case .second:
            return "onboarding2"
        }
    }
    
    var labelText: String {
        switch self {
        case .first:
            return NSLocalizedString("onboardingText1", comment: "Onboarding first screen text")
        case .second:
            return NSLocalizedString("onboardingText2", comment: "Onboarding second screen text")
        }
    }
}
