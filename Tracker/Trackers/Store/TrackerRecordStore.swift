//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Bakgeldi Alkhabay on 10.09.2024.
//

import UIKit
import CoreData

final class TrackerRecordStore {
    private let trackersViewController = TrackersViewController()
    private var appDelegate: AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }
    
    private var context: NSManagedObjectContext {
        appDelegate.persistentContainer.viewContext
    }
    
    func addNewTrackerRecord(_ trackerRecord: TrackerRecord) throws {
        let trackerRecordCoreData = TrackerRecordCoreData(context: context)
        trackerRecordCoreData.id = Int16(trackerRecord.id)
        trackerRecordCoreData.date = trackerRecord.date
        
        appDelegate.saveContext()
    }

    func updateExistingTrackerRecord(_ trackerRecordCoreData: TrackerRecordCoreData, with trackerRecord: TrackerRecord) {
        trackerRecordCoreData.id = Int16(trackerRecord.id)
        trackerRecordCoreData.date = trackerRecord.date
        
        appDelegate.saveContext()
    }
}
