//
//  PromptItem.swift
//  InterviewHelperPOC
//
//  Created by Mona Zheng on 10/26/23.
//

import Foundation
import CoreData

@objc(PromptItem)
public class PromptItem: NSManagedObject, GenericPromptItem {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<PromptItem> {
        return NSFetchRequest<PromptItem>(entityName: "PromptItem")
    }

    /// Id of the item that was assigned from the downloaded content
    @NSManaged public var originalId: String?
    /// The original category the item was from, ex: "top-interview-questions"
    @NSManaged public var originialCategory: String?
    /// Identifier used to store and retrieve the item
    @NSManaged public var identifier: UUID
    /// The prompt for the user to respond to.
    @NSManaged public var prompt: String
    /// The response that the user inputted.
    @NSManaged public var response: String?
}
