//
//  Main+CoreDataProperties.swift
//  ZhihuDaily
//
//  Created by Riversideview on 15/11/28.
//  Copyright © 2015年 Riversideview. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Main {

    @NSManaged var top: NSOrderedSet?
    @NSManaged var list: NSOrderedSet?

}
