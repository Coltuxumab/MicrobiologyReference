//
//  Bugs+CoreDataProperties.swift
//  Microbiology Reference
//
//  Created by Cole Denkensohn on 11/27/17.
//  Copyright © 2017 Denkensohn. All rights reserved.
//
//

import Foundation
import CoreData


extension Bugs {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Bugs> {
        return NSFetchRequest<Bugs>(entityName: "Bugs")
    }

    @NSManaged public var last_accessed: NSDate?
    @NSManaged public var match_basis: String?
    @NSManaged public var name: String
    @NSManaged public var related_diagnosis: NSSet?
    @NSManaged public var related_disease: NSSet?
    @NSManaged public var related_general: NSSet?
    @NSManaged public var related_gramstain: NSSet?
    @NSManaged public var related_keypoints: NSSet?
    @NSManaged public var related_laboratory: NSSet?
    @NSManaged public var related_morphology: NSSet?
    @NSManaged public var related_prevention: NSSet?
    @NSManaged public var related_signs: NSSet?
    @NSManaged public var related_source: NSSet?
    @NSManaged public var related_treatments: NSSet?
    @NSManaged public var related_type: NSSet?

}

// MARK: Generated accessors for related_diagnosis
extension Bugs {

    @objc(addRelated_diagnosisObject:)
    @NSManaged public func addToRelated_diagnosis(_ value: Bugs)

    @objc(removeRelated_diagnosisObject:)
    @NSManaged public func removeFromRelated_diagnosis(_ value: Bugs)

    @objc(addRelated_diagnosis:)
    @NSManaged public func addToRelated_diagnosis(_ values: NSSet)

    @objc(removeRelated_diagnosis:)
    @NSManaged public func removeFromRelated_diagnosis(_ values: NSSet)

}

// MARK: Generated accessors for related_disease
extension Bugs {

    @objc(addRelated_diseaseObject:)
    @NSManaged public func addToRelated_disease(_ value: Disease)

    @objc(removeRelated_diseaseObject:)
    @NSManaged public func removeFromRelated_disease(_ value: Disease)

    @objc(addRelated_disease:)
    @NSManaged public func addToRelated_disease(_ values: NSSet)

    @objc(removeRelated_disease:)
    @NSManaged public func removeFromRelated_disease(_ values: NSSet)

}

// MARK: Generated accessors for related_general
extension Bugs {

    @objc(addRelated_generalObject:)
    @NSManaged public func addToRelated_general(_ value: General)

    @objc(removeRelated_generalObject:)
    @NSManaged public func removeFromRelated_general(_ value: General)

    @objc(addRelated_general:)
    @NSManaged public func addToRelated_general(_ values: NSSet)

    @objc(removeRelated_general:)
    @NSManaged public func removeFromRelated_general(_ values: NSSet)

}

// MARK: Generated accessors for related_gramstain
extension Bugs {

    @objc(addRelated_gramstainObject:)
    @NSManaged public func addToRelated_gramstain(_ value: GramStain)

    @objc(removeRelated_gramstainObject:)
    @NSManaged public func removeFromRelated_gramstain(_ value: GramStain)

    @objc(addRelated_gramstain:)
    @NSManaged public func addToRelated_gramstain(_ values: NSSet)

    @objc(removeRelated_gramstain:)
    @NSManaged public func removeFromRelated_gramstain(_ values: NSSet)

}

// MARK: Generated accessors for related_keypoints
extension Bugs {

    @objc(addRelated_keypointsObject:)
    @NSManaged public func addToRelated_keypoints(_ value: KeyPoints)

    @objc(removeRelated_keypointsObject:)
    @NSManaged public func removeFromRelated_keypoints(_ value: KeyPoints)

    @objc(addRelated_keypoints:)
    @NSManaged public func addToRelated_keypoints(_ values: NSSet)

    @objc(removeRelated_keypoints:)
    @NSManaged public func removeFromRelated_keypoints(_ values: NSSet)

}

// MARK: Generated accessors for related_laboratory
extension Bugs {

    @objc(addRelated_laboratoryObject:)
    @NSManaged public func addToRelated_laboratory(_ value: Laboratory)

    @objc(removeRelated_laboratoryObject:)
    @NSManaged public func removeFromRelated_laboratory(_ value: Laboratory)

    @objc(addRelated_laboratory:)
    @NSManaged public func addToRelated_laboratory(_ values: NSSet)

    @objc(removeRelated_laboratory:)
    @NSManaged public func removeFromRelated_laboratory(_ values: NSSet)

}

// MARK: Generated accessors for related_morphology
extension Bugs {

    @objc(addRelated_morphologyObject:)
    @NSManaged public func addToRelated_morphology(_ value: Morphology)

    @objc(removeRelated_morphologyObject:)
    @NSManaged public func removeFromRelated_morphology(_ value: Morphology)

    @objc(addRelated_morphology:)
    @NSManaged public func addToRelated_morphology(_ values: NSSet)

    @objc(removeRelated_morphology:)
    @NSManaged public func removeFromRelated_morphology(_ values: NSSet)

}

// MARK: Generated accessors for related_prevention
extension Bugs {

    @objc(addRelated_preventionObject:)
    @NSManaged public func addToRelated_prevention(_ value: Prevention)

    @objc(removeRelated_preventionObject:)
    @NSManaged public func removeFromRelated_prevention(_ value: Prevention)

    @objc(addRelated_prevention:)
    @NSManaged public func addToRelated_prevention(_ values: NSSet)

    @objc(removeRelated_prevention:)
    @NSManaged public func removeFromRelated_prevention(_ values: NSSet)

}

// MARK: Generated accessors for related_signs
extension Bugs {

    @objc(addRelated_signsObject:)
    @NSManaged public func addToRelated_signs(_ value: Signs)

    @objc(removeRelated_signsObject:)
    @NSManaged public func removeFromRelated_signs(_ value: Signs)

    @objc(addRelated_signs:)
    @NSManaged public func addToRelated_signs(_ values: NSSet)

    @objc(removeRelated_signs:)
    @NSManaged public func removeFromRelated_signs(_ values: NSSet)

}

// MARK: Generated accessors for related_source
extension Bugs {

    @objc(addRelated_sourceObject:)
    @NSManaged public func addToRelated_source(_ value: Sources)

    @objc(removeRelated_sourceObject:)
    @NSManaged public func removeFromRelated_source(_ value: Sources)

    @objc(addRelated_source:)
    @NSManaged public func addToRelated_source(_ values: NSSet)

    @objc(removeRelated_source:)
    @NSManaged public func removeFromRelated_source(_ values: NSSet)

}

// MARK: Generated accessors for related_treatments
extension Bugs {

    @objc(addRelated_treatmentsObject:)
    @NSManaged public func addToRelated_treatments(_ value: Treatment)

    @objc(removeRelated_treatmentsObject:)
    @NSManaged public func removeFromRelated_treatments(_ value: Treatment)

    @objc(addRelated_treatments:)
    @NSManaged public func addToRelated_treatments(_ values: NSSet)

    @objc(removeRelated_treatments:)
    @NSManaged public func removeFromRelated_treatments(_ values: NSSet)

}

// MARK: Generated accessors for related_type
extension Bugs {

    @objc(addRelated_typeObject:)
    @NSManaged public func addToRelated_type(_ value: Type)

    @objc(removeRelated_typeObject:)
    @NSManaged public func removeFromRelated_type(_ value: Type)

    @objc(addRelated_type:)
    @NSManaged public func addToRelated_type(_ values: NSSet)

    @objc(removeRelated_type:)
    @NSManaged public func removeFromRelated_type(_ values: NSSet)

}
