//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Bakgeldi Alkhabay on 26.09.2024.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {

    func testViewControllerLightMode() {
        let vc = TrackersViewController()
        //vc.view.backgroundColor = .blue
        
        // Скриншот-тест для светлой темы
        assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    func testViewControllerDarkMode() {
        let vc = TrackersViewController()
        //vc.view.backgroundColor = .blue
        
        // Скриншот-тест для тёмной темы
        assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }

}
