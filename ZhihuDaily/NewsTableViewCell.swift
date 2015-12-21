//
//  NewsTableViewCell.swift
//  ZhihuDaily
//
//  Created by Riversideview on 15/11/28.
//  Copyright © 2015年 Riversideview. All rights reserved.
//

import UIKit

class NewsTableViewCell: UITableViewCell {

    @IBOutlet weak var titleTextLabel: UILabel!

    @IBOutlet weak var titleImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let line = UIView(frame: CGRect(x: 15, y: 119, width: UIScreen.mainScreen().bounds.width - 30, height: 1))
        line.backgroundColor = UIColor.lightGrayColor()
        self.contentView.addSubview(line)
//        print(self.contentView.frame.height)
//        titleLabel.verticalAlignment = VerticalAlignmentMiddle
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
