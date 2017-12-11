//
//  Settings+CoreDataProperties.swift
//  Microbiology Reference
//
//  Created by Cole Denkensohn on 11/23/17.
//  Copyright © 2017 Denkensohn. All rights reserved.
//
//

import Foundation
import CoreData


extension Settings {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Settings> {
        return NSFetchRequest<Settings>(entityName: "Settings")
    }

    @NSManaged public var dataversion: Int16

}
