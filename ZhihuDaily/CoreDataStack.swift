//
//  CoreDataStack.swift
//  ZhihuDaily
//
//  Created by Riversideview on 15/11/26.
//  Copyright © 2015年 Riversideview. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    let modelName = "ZhihuDaily"
    
    private lazy var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count - 1]
    }()
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource(self.modelName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    
    lazy var context: NSManagedObjectContext = {
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.psc
        return managedObjectContext
    }()
    
    private lazy var psc: NSPersistentStoreCoordinator = {
        var coordintor = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent(self.modelName)
        do {
            let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
            try coordintor.addPersistentStoreWithType(
                NSSQLiteStoreType, configuration: nil, URL: url,
                options: options)
        } catch {
            print("Error adding persistent store.")
        }
        return coordintor
    }()
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch let error as NSError {
                print(error.localizedDescription)
                abort()
            }
        }
    }
    
}