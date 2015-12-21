//
//  Top+CoreDataProperties.swift
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

extension Top {

    @NSManaged var id: String?
    @NSManaged var title: String?
    @NSManaged var image: UIImage?
    @NSManaged var mian: Main?

}
