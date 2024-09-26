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

struct TrackerCategoryUpdate {
    struct Move: Hashable {
        let oldIndex: Int
        let newIndex: Int
    }
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let updatedIndexes: IndexSet
    let movedIndexes: Set<Move>
}

protocol TrackerCategoryDelegate: AnyObject {
    func store(
        _ store: TrackerCategoryStore,
        didUpdate update: TrackerCategoryUpdate
    )
}

final class TrackerCategoryStore: NSObject {
    private let trackerStore = TrackerStore()
    private let trackerRecordStore = TrackerRecordStore()
    private let trackersArrayMarshalling = TrackersArrayMarshalling()
    private let dbStore = DBStore.shared
    
    private var context: NSManagedObjectContext
    
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>?
    weak var delegate: TrackerCategoryDelegate?
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    private var movedIndexes: Set<TrackerCategoryUpdate.Move>?
    
    override convenience init() {
        let store = DBStore.shared
        let context = store.persistentContainer.viewContext
        do {
            try self.init(context: context)
        } catch {
            fatalError("Ошибка при инициализации с context: \(error)")
        }
    }

    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()

        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCategoryCoreData.title, ascending: true)
        ]
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        self.fetchedResultsController = controller
        try controller.performFetch()
    }
    
    var categories: [TrackerCategory] {
        guard
            let objects = self.fetchedResultsController?.fetchedObjects,
            let categories = try? objects.map({ try self.getCategory(from: $0) })
        else { return [] }
        return categories
    }
    
    func addNewTrackerCategory(_ category: TrackerCategory) throws {
        let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
        trackerCategoryCoreData.title = category.title
        trackerCategoryCoreData.trackers = category.trackers as NSObject
        
        dbStore.saveContext()
    }

    func updateExistingTrackerCategory(_ trackerCategoryCoreData: TrackerCategoryCoreData, with category: TrackerCategory) {
        trackerCategoryCoreData.title = category.title
        trackerCategoryCoreData.trackers = category.trackers as NSObject
        
        dbStore.saveContext()
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
        let trackerCategoriesFromCoreData = try context.fetch(fetchRequest)
        return try trackerCategoriesFromCoreData.map { try self.getCategory(from: $0) }
    }
    
    func getCategory(from trackerCategoryCoreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let name = trackerCategoryCoreData.title else {
            throw TrackerCategoryStoreError.decodingErrorInvalidEmojies
        }
        
        do {
            let trackers = try trackerStore.fetchTrackersByCategory(name)
            return TrackerCategory(title: name, trackers: trackers)
        } catch {
            print("Ошибка при получении трекеров: \(error)")
            throw error
        }
    }
    
    func fetchCategories() throws -> [TrackerCategory] {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        let trackerCategoriesFromCoreData = try context.fetch(fetchRequest)
        
        // Фильтрация: исключаем категорию с названием "Закрепленные"
        return try trackerCategoriesFromCoreData
            .filter { $0.title != "Закрепленные" }
            .map { try self.getCategory(from: $0) }
    }

    func fetchCategoriesWithCompletedTrackers(for date: Date) throws -> [TrackerCategory] {
        let completedTrackers = try trackerRecordStore.filterCompletedTrackers(for: date)
        
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        let categoriesCoreData = try context.fetch(fetchRequest)
        
        let filteredCategories = try categoriesCoreData.filter { category in
            return completedTrackers.contains { tracker in
                tracker.trackerCategory == category.title
            }
        }.map { category in
            return try getCompletedTrackersCategory(from: category, with: completedTrackers)
        }
        
        return filteredCategories
    }
    
    func getCompletedTrackersCategory(from categoryCoreData: TrackerCategoryCoreData, with completedTrackers: [Tracker]) throws -> TrackerCategory {
        guard let title = categoryCoreData.title else {
            throw TrackerCategoryStoreError.decodingErrorInvalidEmojies
        }
        
        let trackersInCategory = completedTrackers.filter { tracker in
            tracker.trackerCategory == title
        }

        return TrackerCategory(
            title: title,
            trackers: trackersInCategory
        )
    }
    
    func fetchCategoriesWithUnmarkedTrackers(for date: Date) throws -> [TrackerCategory] {
        let unmarkedTrackers = try trackerRecordStore.filterUnmarkedTrackers(for: date)
        
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        let categoriesCoreData = try context.fetch(fetchRequest)
        
        let filteredCategories = try categoriesCoreData.filter { category in
            return unmarkedTrackers.contains { tracker in
                tracker.trackerCategory == category.title
            }
        }.map { category in
            return try getUnmarkedTrackersCategory(from: category, with: unmarkedTrackers)
        }
        
        return filteredCategories
    }
    
    func getUnmarkedTrackersCategory(from categoryCoreData: TrackerCategoryCoreData, with unmarkedTrackers: [Tracker]) throws -> TrackerCategory {
        guard let title = categoryCoreData.title else {
            throw TrackerCategoryStoreError.decodingErrorInvalidEmojies
        }
        
        let trackersInCategory = unmarkedTrackers.filter { tracker in
            tracker.trackerCategory == title
        }

        return TrackerCategory(
            title: title,
            trackers: trackersInCategory
        )   
    }
    
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
        updatedIndexes = IndexSet()
        movedIndexes = Set<TrackerCategoryUpdate.Move>()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.store(
            self,
            didUpdate: TrackerCategoryUpdate(
                insertedIndexes: insertedIndexes ?? IndexSet(),
                deletedIndexes: deletedIndexes ?? IndexSet(),
                updatedIndexes: updatedIndexes ?? IndexSet(),
                movedIndexes: movedIndexes ?? Set<TrackerCategoryUpdate.Move>()
            )
        )
        insertedIndexes = nil
        deletedIndexes = nil
        updatedIndexes = nil
        movedIndexes = nil
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {

        switch type {
        case .insert:
            guard let indexPath = newIndexPath else { fatalError() }
            insertedIndexes?.insert(indexPath.item)
        case .delete:
            guard let indexPath = indexPath else { fatalError() }
            deletedIndexes?.insert(indexPath.item)
        case .update:
            guard let indexPath = indexPath else { fatalError() }
            updatedIndexes?.insert(indexPath.item)
        case .move:
            guard let oldIndexPath = indexPath, let newIndexPath = newIndexPath else { fatalError() }
            movedIndexes?.insert(.init(oldIndex: oldIndexPath.item, newIndex: newIndexPath.item))
        @unknown default:
            fatalError()
        }
    }
}
