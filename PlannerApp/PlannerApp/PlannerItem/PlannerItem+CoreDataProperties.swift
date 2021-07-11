//
//  PlannerItem+CoreDataProperties.swift
//  PlannerApp
//
//  Created by user198300 on 6/22/21.
//
//

import Foundation
import CoreData


extension PlannerItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlannerItem> {
        return NSFetchRequest<PlannerItem>(entityName: "PlannerItem")
    }

    @NSManaged public var dueDate: Date?
    @NSManaged public var category: String?
    @NSManaged public var title: String?

}

extension PlannerItem : Identifiable {

}
