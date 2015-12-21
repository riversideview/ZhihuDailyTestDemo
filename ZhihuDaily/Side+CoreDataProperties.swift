//
//  Side+CoreDataProperties.swift
//  ZhihuDaily
//
//  Created by Riversideview on 15/12/15.
//  Copyright © 2015年 Riversideview. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Side {

    @NSManaged var id: String?
    @NSManaged var title: String?
    @NSManaged var name: String?
    @NSManaged var imageURL: String?

}
