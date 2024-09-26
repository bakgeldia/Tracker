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

    func testViewController() {
        let vc = TrackersViewController()
        vc.view.backgroundColor = .blue
        
        //assertSnapshot(of: vc, as: .image, record: true)
        assertSnapshot(of: vc, as: .image)
    }

}
