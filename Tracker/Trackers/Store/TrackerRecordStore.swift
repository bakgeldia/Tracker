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

final class TrackerRecordStore {
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
