//
//  MainViewController.swift
//  ZhihuDaily
//
//  Created by Riversideview on 15/11/26.
//  Copyright © 2015年 Riversideview. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import SwiftyJSON
import LTNavigationBar
import ZFDragableModalTransition
import SWRevealViewController

class MainViewController: UIViewController, SDCycleScrollViewDelegate, ParallaxHeaderViewDelegate {
    

    
    var coreDataStack: CoreDataStack {
        get {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            return appDelegate.coreDataStack
        }
    }
    var animator: ZFModalTransitionAnimator = ZFModalTransitionAnimator()
    var mianScrollView: SDCycleScrollView!
    var main: [Main]!
    var top: [Top]!
    var list: [List]!
//    var detailViewController: DetailViewController {
//        get {
//            
//            return self.storyboard?.instantiateViewControllerWithIdentifier("DetailViewController") as! DetailViewController
//        }
//    }
    
    //顶部轮播图片及标题数组
    var images: [AnyObject]! = []
    var titles: [AnyObject]! = []

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sideMenuButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rvc = self.revealViewController()
        self.view.addGestureRecognizer(rvc.panGestureRecognizer())
        self.view.addGestureRecognizer(rvc.tapGestureRecognizer())
        sideMenuButton.target = rvc
        sideMenuButton.action = Selector("revealToggle:")
        
        setup()
        getNewsData()
        setTopScrollView()
        
        

        
        
    }
    
    //配置视图属性
    func setup() {
        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationController?.navigationBar.lt_setBackgroundColor(UIColor.clearColor())
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        //设置状态栏字体颜色
        self.navigationController?.navigationBar.barStyle = .BlackTranslucent
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        //添加返回按钮
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: self, action: "")
        backButton.tintColor = UIColor.whiteColor()
        navigationItem.backBarButtonItem = backButton
        
        self.tableView.separatorStyle = .None
        self.tableView.estimatedRowHeight = 110
    }
    
    //配置轮播
    func setTopScrollView() {
        
        mianScrollView = SDCycleScrollView(frame: CGRectMake(0, 0, self.view.frame.width, 250))
        mianScrollView.titlesGroup = titles
        mianScrollView.localizationImagesGroup = images
        
        mianScrollView.infiniteLoop = true
        mianScrollView.delegate = self
        mianScrollView.autoScrollTimeInterval = 3;
        mianScrollView.pageControlStyle = SDCycleScrollViewPageControlStyleClassic
        mianScrollView.titleLabelTextFont = UIFont(name: "STHeitiSC-Medium", size: 21)
        mianScrollView.titleLabelBackgroundColor = UIColor.clearColor()
        mianScrollView.titleLabelHeight = 60
        mianScrollView.titleLabelAlpha = 1
        
        //添加至ParallaxView
        let headerView = ParallaxHeaderView.parallaxHeaderViewWithSubView(mianScrollView, forSize: CGSizeMake(self.view.frame.width, 250)) as! ParallaxHeaderView
        
        self.tableView.tableHeaderView = headerView
        headerView.delegate = self
    }
    
    //获取顶部数据
    func getNewsData() {
        
        let topRequest = NSFetchRequest(entityName: "Top")
        let listRequest = NSFetchRequest(entityName: "List")
        do {
            
            let topResults = try coreDataStack.context.executeFetchRequest(topRequest) as! [Top]
            top = topResults
//            print(top.count)
            //为顶部轮播准备数据
            for t in top {
                images.append(t.image!)
                titles.append(t.title!)
            }
            let listResults = try coreDataStack.context.executeFetchRequest(listRequest) as! [List]
            list = listResults
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        
    }
    //parallaxheader代理
    func lockContentOffsetTopY() {
        self.tableView.contentOffset.y = -75
    }
    //MARK: 顶部滚动栏点击事件
    func cycleScrollView(cycleScrollView: SDCycleScrollView!, didSelectItemAtIndex index: Int) {
        let id = top[index].id!
        self.id = id
        customTransition(id)
        print("click \(index)")
    }
    //设置并转场
    private func customTransition(id: String) {
        //配置跳转动画
        let detailViewController = self.storyboard?.instantiateViewControllerWithIdentifier("DetailViewController") as! DetailViewController
        detailViewController.id = id
        animator = ZFModalTransitionAnimator(modalViewController: detailViewController)
        
        self.animator.dragable = true
        self.animator.bounces = false
        self.animator.behindViewAlpha = 0.5
        self.animator.behindViewScale = 0.5
        self.animator.transitionDuration = 0.5
        self.animator.direction = ZFModalTransitonDirection.Right
        
        //设置目标专场代理及转场模式
        detailViewController.transitioningDelegate = self.animator
        detailViewController.modalPresentationStyle = .Custom
        
        //实施转场
        self.presentViewController(detailViewController, animated: true, completion: nil)
        
    }
    var id = ""
    
    
    
}

    //MARK: tableview部分
extension MainViewController: UITableViewDataSource, UITableViewDelegate {

    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 120
    }
   
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        print("count of list = \(list.count)")
        return list.count
        
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        print(indexPath.row)
        
        let id = list[indexPath.row].id!
        var readNewsID = NSUserDefaults.standardUserDefaults().objectForKey("newsID") as! [String]
        if readNewsID.indexOf(id) == nil {

            readNewsID.append(id)

        }
        
        NSUserDefaults.standardUserDefaults().setObject(readNewsID, forKey: "newsID")
        
        self.id = id
        performSegueWithIdentifier("todetail", sender: self)
        
//        customTransition(id)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        
        switch segue.identifier! {
        case "todetail":
            let dvc = segue.destinationViewController as! DetailViewController
            dvc.id = id
        default: break
        }
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! NewsTableViewCell
        
        let news = list[indexPath.row]
        cell.titleImageView.image = news.image
        cell.titleTextLabel.text = news.title
        
        let id = news.id!
        
        let readNewsID = NSUserDefaults.standardUserDefaults().objectForKey("newsID") as! [String]

        
        if readNewsID.indexOf(id) != nil {
            cell.titleTextLabel.textColor = UIColor.lightGrayColor()
        } else {
            cell.titleTextLabel.textColor = UIColor.blackColor()
        }
        

        return cell
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.lt_setBackgroundColor(UIColor.clearColor())
        tableView.reloadData()
        print("viewwillappear")
    }
    
}

//MARK: 透明navigationcontroller及自动调整轮播图的frame
extension MainViewController {

    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        let header = self.tableView.tableHeaderView as! ParallaxHeaderView
        header.layoutHeaderViewForScrollViewOffset(scrollView.contentOffset)
        print(self.navigationController?.navigationBar.frame.size.height)
        
        //滑动时更新顶部NavigationBar透明度
        let nvbHeight: CGFloat = 64
        let topImageHeight: CGFloat = 250
        let color = UIColor(red: 0/255, green: 175/255, blue: 240/255, alpha: 1)
        let offsetY = scrollView.contentOffset.y
        if offsetY > nvbHeight {
            let alpha = min(1, (offsetY - nvbHeight) / (topImageHeight - nvbHeight*2))
            self.navigationController?.navigationBar.lt_setBackgroundColor(color.colorWithAlphaComponent(alpha))
        } else {
            self.navigationController?.navigationBar.lt_setBackgroundColor(color.colorWithAlphaComponent(0))
        }

    }
    
    
    
}
//

