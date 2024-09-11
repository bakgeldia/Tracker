//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Bakgeldi Alkhabay on 10.09.2024.
//

import UIKit
import CoreData

final class TrackerCategoryStore {
    private var appDelegate: AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }
    
    private var context: NSManagedObjectContext {
        appDelegate.persistentContainer.viewContext
    }
    
    func trackerToDictionary(_ tracker: Tracker) -> NSDictionary {
        return [
            "id": tracker.id,
            "name": tracker.name,
            "color": tracker.color,
            "emoji": tracker.emoji,
            "schedule": tracker.schedule
        ] as NSDictionary
    }
    
    func dictionaryToTracker(_ dictionary: NSDictionary) -> Tracker? {
        guard let id = dictionary["id"] as? UInt,
              let name = dictionary["name"] as? String,
              let color = dictionary["color"] as? UIColor,
              let emoji = dictionary["emoji"] as? String,
              let schedule = dictionary["schedule"] as? [String] else {
            return nil
        }
        
        return Tracker(id: id, name: name, color: color, emoji: emoji, schedule: schedule)
    }
    
    func trackersToNSObject(_ trackers: [Tracker]) -> NSObject {
        let trackerDictionaries = trackers.map { trackerToDictionary($0) }
        return NSArray(array: trackerDictionaries)
    }

    func nsObjectToTrackers(_ object: NSObject?) -> [Tracker] {
        guard let trackerDictionaries = object as? [NSDictionary] else { return [] }
        
        return trackerDictionaries.compactMap { dictionaryToTracker($0) }
    }
    
    func addNewTrackerCategory(_ category: TrackerCategory) throws {
        let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
        trackerCategoryCoreData.title = category.title
        trackerCategoryCoreData.trackers = trackersToNSObject(category.trackers)
        
        appDelegate.saveContext()
    }

    func updateExistingTrackerCategory(_ trackerCategoryCoreData: TrackerCategoryCoreData, with category: TrackerCategory) {
        trackerCategoryCoreData.title = category.title
        trackerCategoryCoreData.trackers = trackersToNSObject(category.trackers)
        
        appDelegate.saveContext()
    }
}
