//
//  SideMenuTableViewController.swift
//  ZhihuDaily
//
//  Created by Riversideview on 15/12/15.
//  Copyright © 2015年 Riversideview. All rights reserved.
//

import UIKit
import CoreData

class SideMenuTableViewController: UITableViewController {

    var side: [Side]!
    var coreDataStack: CoreDataStack {
        get {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            return appDelegate.coreDataStack
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("SideMenu")
        getSideData()
    }
    private func getSideData() {
        let request = NSFetchRequest(entityName: "Side")
        do {
            let results = try coreDataStack.context.executeFetchRequest(request) as! [Side]
            side = results
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell")!
        if indexPath.row == 0 {
            
        }
        cell.textLabel?.text = side[indexPath.row].name
        return cell
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return side.count
    }

}
