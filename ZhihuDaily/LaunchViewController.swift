//
//  ViewController.swift
//  ZhihuDaily
//
//  Created by Riversideview on 15/11/25.
//  Copyright © 2015年 Riversideview. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import SwiftyJSON
import SKSplashView

class LaunchViewController: UIViewController, SKSplashDelegate  {
    
    @IBOutlet weak var copyrightLabel: UILabel!
    @IBOutlet weak var logoImage: UIImageView!

    var coreDataStack = CoreDataStack()
    var launchData: [Launch]! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        getCache()
        launchImage()
        getLaunchData()
        clearCache()
        view.backgroundColor = UIColor.blackColor()
        
        
        
    }
    //        删除coredata中所有的managedobject

    private func clearCache() {
        
        
        let fetchRequest = NSFetchRequest(entityName: "Launch")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try coreDataStack.context.executeRequest(deleteRequest)
        } catch let error as NSError {
            print(error.userInfo)
        }
    
    }
    //获取缓存
    private func getCache() {
        
        let fetchRequest = NSFetchRequest(entityName: "Launch")
        
        do {
            let results =
            try coreDataStack.context.executeFetchRequest(fetchRequest) as! [Launch]
            launchData = results
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
    }
    //从服务器获取launch数据
    private func getLaunchData() {
        
        let zhihuEntity = NSEntityDescription.entityForName("Launch", inManagedObjectContext: coreDataStack.context)
        let launch = Launch(entity: zhihuEntity!, insertIntoManagedObjectContext: coreDataStack.context)
        //从网络获取launch图
        Alamofire.request(.GET, "http://news-at.zhihu.com/api/4/start-image/1080*1776").responseJSON(options: .MutableContainers) { (data: Response<AnyObject, NSError>) -> Void in
            guard data.result.error == nil else {
                print("fail")
                return
            }
            let json = JSON(data: data.data!, options: NSJSONReadingOptions.MutableContainers, error: nil)
//            print(json)
            let imageURL = json["img"].string!
            launch.copyright = json["text"].string!
            
            
            Alamofire.request(.GET, imageURL).responseData({ (data: Response<NSData, NSError>) -> Void in
                launch.startImage = UIImage(data: data.data!)
                self.coreDataStack.saveContext()
            })
        
            
        }
        let fetchRequest = NSFetchRequest(entityName: "Launch")
        do {
            let results =
            try coreDataStack.context.executeFetchRequest(fetchRequest) as! [Launch]
            launchData = results
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
    }
    
    //进入APP的启动画面
    private func launchImage() {
        var splashView = SKSplashView()
        
        if launchData.count != 0 {
            splashView = SKSplashView(backgroundImage: launchData.last?.startImage, animationType: .Zoom)
            copyrightLabel.text = launchData.last?.copyright
        } else {
            splashView = SKSplashView(backgroundImage: UIImage(named: "launchImage"), animationType: .Zoom)
        }
        splashView.frame = self.view.frame
        splashView.animationDuration = 3
        self.view.addSubview(splashView)
        splashView.delegate = self
        
        
        //设置渐明效果
        let blurView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        blurView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.3)
        splashView.addSubview(blurView)
        UIView.animateWithDuration(2.5) { () -> Void in
            blurView.backgroundColor = UIColor.clearColor()
        }
        
        //底层阴影view
        let gradientView = GradientView(frame: CGRectMake(0, self.view.frame.height / 3 * 2, self.view.frame.width, self.view.frame.height / 3 ), type: TRANSPARENT_GRADIENT_TYPE)
        splashView.addSubview(gradientView)
        //执行动画
        splashView.startAnimation()
        self.view.bringSubviewToFront(logoImage)
        self.view.bringSubviewToFront(copyrightLabel)

    }
    
    //跳转到主界面
    func splashViewDidEndAnimating(splashView: SKSplashView!) {
        performSegueWithIdentifier("main", sender: nil)
    }
    
    

}


