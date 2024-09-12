//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Bakgeldi Alkhabay on 10.09.2024.
//

import UIKit
import CoreData

enum TrackerRecordStoreError: Error {
    case decodingErrorInvalidEmojies
    case decodingErrorInvalidColorHex
}

struct TrackerRecordUpdate {
    struct Move: Hashable {
        let oldIndex: Int
        let newIndex: Int
    }
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let updatedIndexes: IndexSet
    let movedIndexes: Set<Move>
}

protocol TrackerRecordDelegate: AnyObject {
    func store(
        _ store: TrackerRecordStore,
        didUpdate update: TrackerRecordUpdate
    )
}

final class TrackerRecordStore: NSObject {
    private var appDelegate: AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }
    
    private var context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>?
    weak var delegate: TrackerRecordDelegate?
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    private var movedIndexes: Set<TrackerRecordUpdate.Move>?
    
    override convenience init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        try! self.init(context: context)
    }

    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()

        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerRecordCoreData.id, ascending: true)
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
    
    var trackerRecords: [TrackerRecord] {
        guard
            let objects = self.fetchedResultsController?.fetchedObjects,
            let trackerRecords = try? objects.map({ try self.getTrackerRecord(from: $0) })
        else { return [] }
        return trackerRecords
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
    
    func deleteExistingTrackerRecord(_ trackerRecord: TrackerRecord) throws {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d AND date == %@", trackerRecord.id, trackerRecord.date as CVarArg)

        do {
            let records = try context.fetch(fetchRequest)
            
            if let recordToDelete = records.first {
                context.delete(recordToDelete)
                appDelegate.saveContext()
            } else {
                print("Запись не найдена")
            }
        } catch {
            print("Ошибка удаления записи: \(error)")
            throw error
        }
    }
    
    func trackerRecordExists(_ trackerRecord: TrackerRecord) -> Bool {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d AND date == %@", trackerRecord.id, trackerRecord.date as CVarArg)

        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            print("Ошибка при проверке наличия записи: \(error)")
            return false
        }
    }
    
    func countTrackerRecords(byId id: Int) -> Int {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)

        do {
            let count = try context.count(for: fetchRequest)
            return count
        } catch {
            print("Ошибка при подсчете записей: \(error)")
            return 0
        }
    }

    
    func fetchTrackerRecords() throws -> [TrackerRecord] {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.fetchLimit = 1
        let trackerRecordCoreData = try context.fetch(fetchRequest)
        return try trackerRecordCoreData.map { try self.getTrackerRecord(from: $0) }
    }
    
    func getTrackerRecord(from trackerRecordCoreData: TrackerRecordCoreData) throws -> TrackerRecord {
        guard let id = Optional(trackerRecordCoreData.id) else {
            throw TrackerRecordStoreError.decodingErrorInvalidEmojies
        }
        guard let date = trackerRecordCoreData.date else {
            throw TrackerRecordStoreError.decodingErrorInvalidEmojies
        }
        return TrackerRecord(id: UInt(id), date: date)
    }
    
    func clearCoreData() throws {
        let entities = appDelegate.persistentContainer.managedObjectModel.entities

        for entity in entities {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.name ?? "")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

            do {
                // Выполняем запрос на удаление всех объектов в сущности
                try context.execute(deleteRequest)
            } catch let error as NSError {
                print("Ошибка при удалении данных из сущности \(entity.name ?? ""): \(error)")
                throw error
            }
        }

        appDelegate.saveContext()
    }
}

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
        updatedIndexes = IndexSet()
        movedIndexes = Set<TrackerRecordUpdate.Move>()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.store(
            self,
            didUpdate: TrackerRecordUpdate(
                insertedIndexes: insertedIndexes!,
                deletedIndexes: deletedIndexes!,
                updatedIndexes: updatedIndexes!,
                movedIndexes: movedIndexes!
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
