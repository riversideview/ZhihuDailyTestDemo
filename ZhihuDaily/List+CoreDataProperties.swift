//
//  List+CoreDataProperties.swift
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

extension List {

    @NSManaged var id: String?
    @NSManaged var image: UIImage?
    @NSManaged var title: String?
    @NSManaged var main: Main?

}
