//
//  ScheduleMarshalling.swift
//  Tracker
//
//  Created by Bakgeldi Alkhabay on 11.09.2024.
//

import UIKit

final class ScheduleMarshalling {
    
    func transformToNSObject(from array: [String]) -> NSObject {
        return NSArray(array: array)
    }
    
    func transformToArray(from object: NSObject?) -> [String] {
        return (object as? [String]) ?? []
    }
}
