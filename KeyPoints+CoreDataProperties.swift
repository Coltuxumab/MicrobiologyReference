//
//  KeyPoints+CoreDataProperties.swift
//  Microbiology Reference
//
//  Created by Cole Denkensohn on 11/23/17.
//  Copyright © 2017 Denkensohn. All rights reserved.
//
//

import Foundation
import CoreData


extension KeyPoints {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<KeyPoints> {
        return NSFetchRequest<KeyPoints>(entityName: "KeyPoints")
    }

    @NSManaged public var name: String?
    @NSManaged public var related_bug: NSSet?

}

// MARK: Generated accessors for related_bug
extension KeyPoints {

    @objc(addRelated_bugObject:)
    @NSManaged public func addToRelated_bug(_ value: Bugs)

    @objc(removeRelated_bugObject:)
    @NSManaged public func removeFromRelated_bug(_ value: Bugs)

    @objc(addRelated_bug:)
    @NSManaged public func addToRelated_bug(_ values: NSSet)

    @objc(removeRelated_bug:)
    @NSManaged public func removeFromRelated_bug(_ values: NSSet)

}
