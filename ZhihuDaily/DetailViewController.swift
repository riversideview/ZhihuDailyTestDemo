//
//  DetailViewController.swift
//  ZhihuDaily
//
//  Created by Riversideview on 15/11/29.
//  Copyright © 2015年 Riversideview. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import SwiftyJSON
import LTNavigationBar

import ZFDragableModalTransition

class DetailViewController: UIViewController, UIScrollViewDelegate, ParallaxHeaderViewDelegate, UIGestureRecognizerDelegate, UIWebViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var statusBarBackgroundView: UIView!
    
    var id = "id"
    var coreDataStack: CoreDataStack {
        get {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            return appDelegate.coreDataStack
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.purpleColor()


        setTopImageView()
        loadWebView()
        setup()
        

    }
    func loadWebView() {
        
        let request = NSFetchRequest(entityName: "Detail")
        request.predicate =  NSPredicate(format: "id = %@", id)
        
        do {
            let results = try coreDataStack.context.executeFetchRequest(request) as! [Detail]
            if let result = results.first {
                webView.loadHTMLString(result.html!, baseURL: nil)
                
                let titleLabel = imageView.subviews[1] as! myUILabel
                let copyrightLabel = imageView.subviews[2] as! UILabel
                
                self.imageView.image = result.image
                titleLabel.text = result.title
                copyrightLabel.text = result.copyright
                print("load cache")
            } else if id != "id" {
                
                Alamofire.request(.GET, "http://news-at.zhihu.com/api/4/news/" + id).responseJSON { (data:Response<AnyObject, NSError>) -> Void in
                    guard data.result.error == nil else {
                        print("fail")
                        return
                    }
                    let json = JSON(data: data.data!)
                    //                print(json)
                    let body = json["body"].string!
                    let css = json["css"].array?.first?.string!
                    let html = "<html><head><link rel=\"stylesheet\"href=\(css!)</head><body>\(body)</body></html>"
                    let title = json["title"].string!
                    let copyright = json["image_source"].string!
                    
                    let detailEntity = NSEntityDescription.entityForName("Detail", inManagedObjectContext: self.coreDataStack.context)
                    let detail = Detail(entity: detailEntity!, insertIntoManagedObjectContext: self.coreDataStack.context)
                    
                    detail.title = title
                    detail.html = html
                    detail.copyright = copyright
                    detail.id = self.id
//                    print("detail.title = \(detail.title)")
//                    print("detail.html = \(detail.html)")
//                    print("detail.copyright = \(detail.copyright)")
                    
                    let imageURL = json["image"].string!
                    Alamofire.request(.GET, imageURL).responseData({ (data: Response<NSData, NSError>) -> Void in
                        let image = UIImage(data: data.data!)
                        detail.image = image
                        
                        self.coreDataStack.saveContext()
                        
                        let request = NSFetchRequest(entityName: "Detail")
                        do {
                            if let results = try self.coreDataStack.context.executeFetchRequest(request) as? [Detail] {
                                
                                self.webView.loadHTMLString(results.last!.html!, baseURL: nil)
                                
                                let titleLabel = self.imageView.subviews[1] as! myUILabel
                                let copyrightLabel = self.imageView.subviews[2] as! UILabel
                                
                                self.imageView.image = detail.image
                                titleLabel.text = detail.title
                                copyrightLabel.text = detail.copyright
                            }
                            
                        } catch let error as NSError {
                            print(error.userInfo)
                        }
                        
                    })
                }
            }
        } catch let error as NSError {
            print(error.userInfo)
        }
        
        
        
    }
    //配置视图属性
    func setup() {
        //避免因含有navBar而对scrollInsets做自动调整
        self.automaticallyAdjustsScrollViewInsets = false
        
        //避免webScrollView的ContentView过长 挡住底层View
        self.view.clipsToBounds = false
        
        //将返回按钮主题色设置为白色
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.lt_setBackgroundColor(UIColor.clearColor())
        self.webView.delegate = self
        
        //对scrollView做基本配置
        self.webView.scrollView.delegate = self
        self.webView.scrollView.clipsToBounds = false

    }
    
    
    
    var headerView = ParallaxHeaderView()
    var imageView = UIImageView()
    
    
    //配置顶部主题图
    func setTopImageView() {
        //将statusBar的背景色置为透明
        statusBarBackgroundView.backgroundColor = UIColor.clearColor()

        
        //添加imageView显示主题图片
        imageView = UIImageView(frame: CGRectMake(0, 0, self.view.frame.width, 223))
        imageView.image = UIImage(named: "cellimage")
        imageView.contentMode = .ScaleAspectFill
        
        //为imageView创建阴影层imageView.subview0
        let blurView = GradientView(frame: CGRectMake(0, webView.frame.origin.y + 80, self.view.frame.width, 223), type: TRANSPARENT_GRADIENT_TWICE_TYPE)
        imageView.addSubview(blurView)
        
        //为imageView创建标题栏imageView.subview1
        let imageViewHeight = imageView.frame.height
        let titleLabel = myUILabel(frame: CGRect(x: 15, y: imageViewHeight - 80, width: self.view.frame.width - 30, height: 60))
        titleLabel.font = UIFont(name: "STHeitiSC-Medium", size: 21)
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.shadowColor = UIColor.blackColor()
        titleLabel.shadowOffset = CGSizeMake(0, 1)
        titleLabel.verticalAlignment = VerticalAlignmentBottom
        titleLabel.numberOfLines = 3
        titleLabel.text = "初始化headerView并添加imageView进去初始化headerView并添加imageView进去"
        imageView.addSubview(titleLabel)
        
        //为imageView添加图片版权栏imageView.subview2
        let copyrightLabel = UILabel(frame: CGRect(x: 15, y: imageViewHeight - 20, width: self.view.frame.width - 30, height: 15))
        copyrightLabel.font = UIFont(name: "HelveticaNeue", size: 12)
        copyrightLabel.textColor = UIColor.lightTextColor()
        copyrightLabel.textAlignment = NSTextAlignment.Right
        let copyrightLabelText = "balabala"
        copyrightLabel.text = "图片：" + copyrightLabelText
        imageView.addSubview(copyrightLabel)
        
        //初始化headerView并添加imageView进去
        headerView = ParallaxHeaderView.parallaxWebHeaderViewWithSubView(imageView, forSize: CGSize(width: self.view.frame.width, height: 223)) as! ParallaxHeaderView
        headerView.delegate = self
        webView.scrollView.addSubview(headerView)
        webView.addSubview(statusBarBackgroundView)
        //0
        let dropView = UIView(frame: CGRect(x: 0, y: -65, width: self.view.frame.width, height: 45))
        dropView.backgroundColor = UIColor.blackColor()
        webView.scrollView.addSubview(dropView)
        
        titleOriginY = titleLabel.frame.origin.y
        copyrightOriginY = copyrightLabel.frame.origin.y
        
    }
    //点击链接时通过浏览器打开
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == .LinkClicked {
            UIApplication.sharedApplication().openURL(request.URL!)
            return false
        }
        return true
    }
    func lockContentOffsetTopY() {
        self.webView.scrollView.contentOffset.y = -45

    }
    deinit {
        print("released")
    }
    
    var titleOriginY: CGFloat!
    var copyrightOriginY: CGFloat!

    func scrollViewDidScroll(scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
        if offset.y == -45 {
            print("scroll down")
        }
        headerView.layoutWebHeaderViewForScrollViewOffset(scrollView.contentOffset)
        
        let titleLabel = imageView.subviews[1] as! myUILabel
        let copyrightLabel = imageView.subviews[2] as! UILabel
        
        let offsetY = scrollView.contentOffset.y

        if offsetY < 0 {
            titleLabel.frame.origin = CGPoint(x: 15, y: titleOriginY - offsetY)
            copyrightLabel.frame.origin = CGPoint(x: 15, y: copyrightOriginY - offsetY)
        }
        
        
        let nvbHeight:CGFloat = 64
        let color = UIColor(red: 0/255, green: 175/255, blue: 240/255, alpha: 1)
        let topImageHeight: CGFloat = 223
        if offsetY > nvbHeight {
            let alpha = min(1, (offsetY - nvbHeight) / (topImageHeight - nvbHeight*2))
            self.navigationController?.navigationBar.lt_setBackgroundColor(color.colorWithAlphaComponent(alpha))
        } else {
            self.navigationController?.navigationBar.lt_setBackgroundColor(color.colorWithAlphaComponent(0))
        }
        
        //控制statusBarBackgroundView的颜色以便显示statusBar
        if scrollView.contentOffset.y > 223 {
            statusColor = true
        } else if scrollView.contentOffset.y < 223{
            statusColor = false
        }

    }
    
    
    //控制statusBar字体颜色
    var statusColor: Bool = false {
        didSet {
            UIView.animateWithDuration(0.32) { () -> Void in
                self.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        if statusColor {
            statusBarBackgroundView.backgroundColor = UIColor.whiteColor()
            return .Default
        } else {
            statusBarBackgroundView.backgroundColor = UIColor.clearColor()
            return .LightContent
        }
    }
    
    
}



extension UIImageView {
    public override func layoutSubviews() {
        if let blurView = self.subviews.first as? GradientView {
//            print("image = \(self.frame)")
//            print("blurView.frame = \(blurView.frame)")
            blurView.frame = self.frame
            blurView.layer.sublayers?.first?.removeFromSuperlayer()
            blurView.insertTwiceTransparentGradient()
        }

    }
}