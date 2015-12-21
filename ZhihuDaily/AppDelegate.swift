//
//  AppDelegate.swift
//  ZhihuDaily
//
//  Created by Riversideview on 15/11/25.
//  Copyright © 2015年 Riversideview. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    lazy var coreDataStack = CoreDataStack()
    
    


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        clearLatestCache()
        mainData()
        //创建一个已查看新闻的id数组
        if NSUserDefaults.standardUserDefaults().objectForKey("newsID") == nil {
            print("Creat Userdefaults")
            let newsID: [String] = []
            NSUserDefaults.standardUserDefaults().setObject(newsID, forKey: "newsID")
        }
        sideMenuData()
        
        
        return true
    }
    func mainData() {
        //创建entity
        let topEntity = NSEntityDescription.entityForName("Top", inManagedObjectContext: coreDataStack.context)
        let listEntity = NSEntityDescription.entityForName("List", inManagedObjectContext: coreDataStack.context)
        
        //获取最近的新闻（包含顶部轮播数据）
        Alamofire.request(.GET, "http://news-at.zhihu.com/api/4/news/latest").responseJSON { (data: Response<AnyObject, NSError>) -> Void in
            
            var jsonData = JSON(data: data.data!, options: NSJSONReadingOptions.MutableContainers, error: nil)
            
            //处理顶部轮播数据
            let topArray = jsonData["top_stories"].array!
            //            print("topArray count\(topArray.count)")
            //处理列表新闻数据
            let listArray = jsonData["stories"].array!
            //            print("listArray count \(listArray.count)")
            
            for json in listArray {
                
                let list = List(entity: listEntity!, insertIntoManagedObjectContext: self.coreDataStack.context)
                
                let id = json["id"].stringValue
                //                print(id)
                let imageURL = (json["images"].array?.first!.string)!
                
                //                print(imageURL)
                let title = json["title"].string!
                //                print(title)
                list.id = id
                list.title = title
                
                Alamofire.request(.GET, imageURL).responseData({ (data: Response<NSData, NSError>) -> Void in
                    list.image = UIImage(data: data.data!)
                    self.coreDataStack.saveContext()
                })
                
            }
            
            for json in topArray {
                
                let top = Top(entity: topEntity!, insertIntoManagedObjectContext: self.coreDataStack.context)
                
                
                let id = json["id"].stringValue
                //                print(id)
                let imageURL = json["image"].string!
                //                print(imageURL)
                let title = json["title"].string!
                //                print(title)
                top.id = id
                top.title = title
                
                
                //通过imageURL获取图像数据
                Alamofire.request(.GET, imageURL).responseData({ (data: Response<NSData, NSError>) -> Void in
                    top.image = UIImage(data: data.data!)
                    self.coreDataStack.saveContext()
                })
                
            }
            
            
            
        }
    }
    func sideMenuData() {
        Alamofire.request(.GET, "http://news-at.zhihu.com/api/4/themes").responseJSON { (data: Response<AnyObject, NSError>) -> Void in
            
            let jsonData = JSON(data: data.data!)
            print(jsonData)
            
            
            let sideArray = jsonData["others"].array!
            
            for json in sideArray {
                
                let id = json["id"].stringValue
                let name = json["name"].string
                let title = json["description"].string
                let imageURL = json["thumbnail"].string
                
                print(id)
                print(name)
                print(title)
                print(imageURL)
                
                let sideEntity = NSEntityDescription.entityForName("Side", inManagedObjectContext: self.coreDataStack.context)
                let side = Side(entity: sideEntity!, insertIntoManagedObjectContext: self.coreDataStack.context)
                
                side.id = id
                side.name = name
                side.title = title
                side.imageURL = imageURL
                
                self.coreDataStack.saveContext()
                
            }
            
        }
    }
    

    func clearLatestCache() {
        let topRequest = NSFetchRequest(entityName: "Top")
        let listRequest = NSFetchRequest(entityName: "List")
        let detailRequest = NSFetchRequest(entityName: "Detail")
        let sideRequest = NSFetchRequest(entityName: "Side")
        
        
        let deleteTop = NSBatchDeleteRequest(fetchRequest: topRequest)
        let deleteList = NSBatchDeleteRequest(fetchRequest: listRequest)
        let deleteDetail = NSBatchDeleteRequest(fetchRequest: detailRequest)
        let deleteSide = NSBatchDeleteRequest(fetchRequest: sideRequest)
        
        
        do {
            
            try coreDataStack.context.executeRequest(deleteTop)
            try coreDataStack.context.executeRequest(deleteList)
            try coreDataStack.context.executeRequest(deleteDetail)
            try coreDataStack.context.executeRequest(deleteSide)
            coreDataStack.saveContext()

        } catch let error as NSError {
            
            print(error.userInfo)
        }
    }
    
    
    
    
    
    
    

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

