//
//  ChillTableViewCell.swift
//  AndChill
//
//  Created by Justin Lennox on 11/18/15.
//  Copyright © 2015 Justin Lennox. All rights reserved.
//

class ChillTableViewCell: UITableViewCell {
    
    let containerView = UIView()
    let profileImage = UIImageView()
    let chillButton = UIButton(type: UIButtonType.System)
    let chillDetailsLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        containerView.backgroundColor = UIColor.whiteColor()
        containerView.layer.cornerRadius = 8.0
        containerView.layer.masksToBounds = true
        addSubview(containerView)
        
        chillDetailsLabel.text = ""
        chillDetailsLabel.layer.masksToBounds = true
        chillDetailsLabel.font = UIFont.systemFontOfSize(14.0)
        chillDetailsLabel.numberOfLines = -1
        containerView.addSubview(chillDetailsLabel)
        
        profileImage.image = UIImage(named: "prof.jpg")
        profileImage.layer.masksToBounds = true
        containerView.addSubview(profileImage)
        
        chillButton.setBackgroundImage(UIImage(named: "Snowflake.png"), forState: UIControlState.Normal)
        chillButton.alpha = 0.0
        chillButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        containerView.addSubview(chillButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("FATAL ERROR")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.frame = CGRectMake(frame.width * 0.025, frame.height * 0.05, frame.width * 0.95, frame.height * 0.9)
        profileImage.frame = CGRectMake(0, 0, containerView.frame.height, containerView.frame.height)
        chillDetailsLabel.frame = CGRectMake(profileImage.frame.width + 20, 0, containerView.frame.width - profileImage.frame.width - 20, containerView.frame.height)
        chillButton.frame = CGRectMake(10, 10, containerView.frame.height - 20, containerView.frame.height - 20)
        
    }
    
}