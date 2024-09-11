//
//  TrackerStore.swift
//  Tracker
//
//  Created by Bakgeldi Alkhabay on 10.09.2024.
//

import UIKit
import CoreData

final class TrackerStore {
    private let uiColorMarshalling = UIColorMarshalling()
    
    private var appDelegate: AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }
    
    private var context: NSManagedObjectContext {
        appDelegate.persistentContainer.viewContext
    }
    
    private func transformToNSObject(from array: [String]) -> NSObject {
        return NSArray(array: array)
    }
    
    func addNewTracker(_ tracker: Tracker) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = Int16(tracker.id)
        trackerCoreData.name = tracker.name
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.color = uiColorMarshalling.hexString(from: tracker.color)
        trackerCoreData.schedule = transformToNSObject(from: tracker.schedule)
        
        appDelegate.saveContext()
    }

    func updateExistingTracker(_ trackerCoreData: TrackerCoreData, with tracker: Tracker) {
        trackerCoreData.id = Int16(tracker.id)
        trackerCoreData.name = tracker.name
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.color = uiColorMarshalling.hexString(from: tracker.color)
        trackerCoreData.schedule = transformToNSObject(from: tracker.schedule)
        
        appDelegate.saveContext()
    }
}
