//
//  TrackerStore.swift
//  Tracker
//
//  Created by Bakgeldi Alkhabay on 10.09.2024.
//

import UIKit
import CoreData

enum TrackerStoreError: Error {
    case decodingErrorInvalidEmojies
    case decodingErrorInvalidColorHex
}

final class TrackerStore {
    private let uiColorMarshalling = UIColorMarshalling()
    private let scheduleMarshalling = ScheduleMarshalling()
    private let scheduleTransformer = ScheduleTransformer()
    
    private var appDelegate: AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }
    
    private var context: NSManagedObjectContext {
        appDelegate.persistentContainer.viewContext
    }
    
    func addNewTracker(_ tracker: Tracker) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = Int16(tracker.id)
        trackerCoreData.name = tracker.name
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.color = uiColorMarshalling.hexString(from: tracker.color)
        trackerCoreData.schedule = tracker.schedule as NSObject
        
        appDelegate.saveContext()
    }

    func updateExistingTracker(_ trackerCoreData: TrackerCoreData, with tracker: Tracker) {
        trackerCoreData.id = Int16(tracker.id)
        trackerCoreData.name = tracker.name
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.color = uiColorMarshalling.hexString(from: tracker.color)
        trackerCoreData.schedule = scheduleMarshalling.transformToNSObject(from: tracker.schedule)
        
        appDelegate.saveContext()
    }
    
    func fetchTrackers() throws -> [Tracker] {
        let fetchRequest = TrackerCoreData.fetchRequest()
        let trackersFromCoreData = try context.fetch(fetchRequest)
        return try trackersFromCoreData.map { try self.getTracker(from: $0) }
    }
    
    func getTracker(from trackersCoreData: TrackerCoreData) throws -> Tracker {
        guard let id = Optional(trackersCoreData.id) else {
            throw TrackerStoreError.decodingErrorInvalidEmojies
        }
        guard let name = trackersCoreData.name else {
            throw TrackerStoreError.decodingErrorInvalidEmojies
        }
        guard let color = trackersCoreData.color else {
            throw TrackerStoreError.decodingErrorInvalidEmojies
        }
        guard let emoji = trackersCoreData.emoji else {
            throw TrackerStoreError.decodingErrorInvalidEmojies
        }
        guard let schedule = trackersCoreData.schedule else {
            throw TrackerStoreError.decodingErrorInvalidEmojies
        }
        return Tracker(id: UInt(id),
                       name: name,
                       color: uiColorMarshalling.color(from: color),
                       emoji: emoji,
                       schedule: scheduleMarshalling.transformToArray(from: schedule) 
        )
    }
    
}
