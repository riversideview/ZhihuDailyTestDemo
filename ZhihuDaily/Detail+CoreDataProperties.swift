//
//  Detail+CoreDataProperties.swift
//  ZhihuDaily
//
//  Created by Riversideview on 15/12/1.
//  Copyright © 2015年 Riversideview. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Detail {

    @NSManaged var image: UIImage?
    @NSManaged var title: String?
    @NSManaged var html: String?
    @NSManaged var copyright: String?
    @NSManaged var id: String?

}
