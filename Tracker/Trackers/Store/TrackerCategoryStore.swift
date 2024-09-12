//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Bakgeldi Alkhabay on 10.09.2024.
//

import UIKit
import CoreData

enum TrackerCategoryStoreError: Error {
    case decodingErrorInvalidEmojies
    case decodingErrorInvalidColorHex
}

final class TrackerCategoryStore {
    private let trackerStore = TrackerStore()
    private let trackersArrayMarshalling = TrackersArrayMarshalling()
    private var appDelegate: AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }
    
    private var context: NSManagedObjectContext {
        appDelegate.persistentContainer.viewContext
    }
    
    func addNewTrackerCategory(_ category: TrackerCategory) throws {
        let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
        trackerCategoryCoreData.title = category.title
        trackerCategoryCoreData.trackers = category.trackers as NSObject
        
        appDelegate.saveContext()
    }

    func updateExistingTrackerCategory(_ trackerCategoryCoreData: TrackerCategoryCoreData, with category: TrackerCategory) {
        trackerCategoryCoreData.title = category.title
        trackerCategoryCoreData.trackers = category.trackers as NSObject
        
        appDelegate.saveContext()
    }
    
    func categoryExists(_ trackerCategory: TrackerCategory) -> Bool {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", trackerCategory.title)
        
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            print("Ошибка при проверке наличия категории: \(error)")
            return false
        }
    }

    
    func fetchTrackerCategories() throws -> [TrackerCategory] {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.fetchLimit = 1
        let trackerCategoriesFromCoreData = try context.fetch(fetchRequest)
        return try trackerCategoriesFromCoreData.map { try self.getCategory(from: $0) }
    }
    
    func getCategory(from trackerCategoryCoreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let name = trackerCategoryCoreData.title else {
            throw TrackerCategoryStoreError.decodingErrorInvalidEmojies
        }
        let trackers = try! trackerStore.fetchTrackers()
        return TrackerCategory(title: name,
                               trackers: trackers)
    }
    
}
