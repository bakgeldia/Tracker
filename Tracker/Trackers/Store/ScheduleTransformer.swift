//
//  ScheduleTransformer.swift
//  Tracker
//
//  Created by Bakgeldi Alkhabay on 12.09.2024.
//

import UIKit

@objc(ScheduleTransformer)
final class ScheduleTransformer: ValueTransformer {

    // Указываем, что поддерживаем обратное преобразование (из Data обратно в NSObject)
    override class func allowsReverseTransformation() -> Bool {
        return true
    }

    // Указываем класс, в который будем преобразовывать данные для хранения в Core Data
    override class func transformedValueClass() -> AnyClass {
        return NSObject.self
    }

    // Преобразуем массив [String] в NSObject (фактически через Data)
    override func transformedValue(_ value: Any?) -> Any? {
        guard let scheduleArray = value as? [String] else { return nil }
        do {
            // Преобразуем массив строк в Data
            let data = try NSKeyedArchiver.archivedData(withRootObject: scheduleArray, requiringSecureCoding: true)
            // Преобразуем Data в NSObject для хранения
            return data as NSObject
        } catch {
            print("Error transforming value: \(error)")
            return nil
        }
    }

    // Преобразуем обратно из NSObject (фактически из Data) в массив [String]
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        do {
            // Декодируем Data обратно в массив [String]
            let scheduleArray = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self, NSString.self], from: data) as? [String]
            return scheduleArray
        } catch {
            print("Error reverse transforming value: \(error)")
            return nil
        }
    }
}
