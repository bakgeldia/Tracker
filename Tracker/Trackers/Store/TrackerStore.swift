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

struct TrackerUpdate {
    struct Move: Hashable {
        let oldIndex: Int
        let newIndex: Int
    }
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let updatedIndexes: IndexSet
    let movedIndexes: Set<Move>
}

protocol TrackerDelegate: AnyObject {
    func store(
        _ store: TrackerStore,
        didUpdate update: TrackerUpdate
    )
}

final class TrackerStore: NSObject {
    private let uiColorMarshalling = UIColorMarshalling()
    private let scheduleMarshalling = ScheduleMarshalling()
    
    private var dbStore = DBStore.shared
    
    private var context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>?
    weak var delegate: TrackerDelegate?
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    private var movedIndexes: Set<TrackerUpdate.Move>?
    
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

        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCoreData.id, ascending: true)
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
    
    var trackers: [Tracker] {
        guard
            let objects = self.fetchedResultsController?.fetchedObjects,
            let tracker = try? objects.map({ try self.getTracker(from: $0) })
        else { return [] }
        return tracker
    }
    
    func addNewTracker(_ tracker: Tracker) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = Int16(tracker.id)
        trackerCoreData.name = tracker.name
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.color = uiColorMarshalling.hexString(from: tracker.color)
        trackerCoreData.schedule = tracker.schedule as NSObject
        trackerCoreData.trackerCategory = tracker.trackerCategory
        
        dbStore.saveContext()
    }

    func updateExistingTracker(with tracker: Tracker) throws {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        let trackerId = NSNumber(value: tracker.id)
        fetchRequest.predicate = NSPredicate(format: "id == %@", trackerId)
        
        let trackersFromCoreData = try context.fetch(fetchRequest)
        
        guard let trackerFromCoreData = trackersFromCoreData.first else {
            throw NSError(domain: "TrackerNotFound", code: 404, userInfo: nil)
        }
        
        trackerFromCoreData.name = tracker.name
        trackerFromCoreData.emoji = tracker.emoji
        trackerFromCoreData.color = uiColorMarshalling.hexString(from: tracker.color)
        trackerFromCoreData.schedule = tracker.schedule as NSObject
        trackerFromCoreData.trackerCategory = tracker.trackerCategory
        
        dbStore.saveContext()
    }
    
    func updateTrackerPinStatus(_ tracker: Tracker) throws {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        let trackerId = NSNumber(value: tracker.id)
        fetchRequest.predicate = NSPredicate(format: "id == %@", trackerId)

        do {
            let results = try context.fetch(fetchRequest)
            if let trackerCoreData = results.first {
                // Обновляем статус закрепления
                trackerCoreData.isPinned.toggle()
                
                // Сохраняем изменения
                try context.save()
                print("Статус закрепления трекера обновлен на: \(trackerCoreData.isPinned)")
            } else {
                print("Трекер не найден.")
            }
        } catch {
            print("Ошибка при обновлении статуса закрепления трекера: \(error.localizedDescription)")
            throw error
        }
    }
    
    func updateTrackerCategoryToPinned(_ tracker: Tracker) throws {
        let fetchRequest = TrackerCoreData.fetchRequest()
        let trackerID = NSNumber(value: tracker.id)
        fetchRequest.predicate = NSPredicate(format: "id == %@", trackerID)
        
        let trackersFromCoreData = try context.fetch(fetchRequest)
        
        guard let trackerFromCoreData = trackersFromCoreData.first else {
            throw NSError(domain: "TrackerNotFound", code: 404, userInfo: nil)
        }
        trackerFromCoreData.lastCategory = tracker.trackerCategory
        trackerFromCoreData.trackerCategory = "Закрепленные"
        
        dbStore.saveContext()
    }
    
    func updateTrackerCategoryToPrevious(_ tracker: Tracker) throws {
        let fetchRequest = TrackerCoreData.fetchRequest()
        let trackerID = NSNumber(value: tracker.id)
        fetchRequest.predicate = NSPredicate(format: "id == %@", trackerID)
        
        let trackersFromCoreData = try context.fetch(fetchRequest)
        
        guard let trackerFromCoreData = trackersFromCoreData.first else {
            throw NSError(domain: "TrackerNotFound", code: 404, userInfo: nil)
        }
        trackerFromCoreData.trackerCategory = trackerFromCoreData.lastCategory
        
        dbStore.saveContext()
    }
    
    func deleteTracker(_ tracker: Tracker) throws {
        let fetchRequest = TrackerCoreData.fetchRequest()
        let trackerID = NSNumber(value: tracker.id)
        fetchRequest.predicate = NSPredicate(format: "id == %@", trackerID)
        
        do {
            let trackerCoreDataArray = try context.fetch(fetchRequest)
            if let trackerToDelete = trackerCoreDataArray.first {
                context.delete(trackerToDelete)
                dbStore.saveContext()
            } else {
                throw NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Tracker not found"])
            }
        } catch {
            throw error
        }
    }
    
    func fetchTrackers() throws -> [Tracker] {
        let fetchRequest = TrackerCoreData.fetchRequest()
        let trackersFromCoreData = try context.fetch(fetchRequest)
        return try trackersFromCoreData.map { try self.getTracker(from: $0) }
    }
    
    func fetchTrackersByCategory(_ category: String) throws -> [Tracker] {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "trackerCategory == %@", category)
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
        guard let category = trackersCoreData.trackerCategory else {
            throw TrackerStoreError.decodingErrorInvalidEmojies
        }
        return Tracker(id: UInt(id),
                       name: name,
                       color: uiColorMarshalling.color(from: color),
                       emoji: emoji,
                       schedule: scheduleMarshalling.transformToArray(from: schedule),
                       isPinned: trackersCoreData.isPinned,
                       trackerCategory: category
        )
    }
    
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
        updatedIndexes = IndexSet()
        movedIndexes = Set<TrackerUpdate.Move>()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.store(
            self,
            didUpdate: TrackerUpdate(
                insertedIndexes: insertedIndexes ?? IndexSet(),
                deletedIndexes: deletedIndexes ?? IndexSet(),
                updatedIndexes: updatedIndexes ?? IndexSet(),
                movedIndexes: movedIndexes ?? Set<TrackerUpdate.Move>()
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
