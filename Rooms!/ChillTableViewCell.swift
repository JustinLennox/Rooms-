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
    let chillTypeLabel = UILabel()
    
    /**
    *   This is where we add all of the UI for the chill table view cell
    */
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        containerView.backgroundColor = UIColor.whiteColor()
        containerView.layer.cornerRadius = 8.0
        containerView.layer.masksToBounds = true
        addSubview(containerView)
        
        profileImage.image = UIImage(named: "prof.jpg")
        profileImage.layer.masksToBounds = true
        containerView.addSubview(profileImage)
        
        chillDetailsLabel.text = ""
        chillDetailsLabel.layer.masksToBounds = true
        chillDetailsLabel.font = UIFont.systemFontOfSize(14.0)
        chillDetailsLabel.numberOfLines = -1
        containerView.addSubview(chillDetailsLabel)
        
        chillTypeLabel.text = ""
        chillTypeLabel.textAlignment = .Right
        chillTypeLabel.textColor = UIColor.icyBlue()
        chillTypeLabel.font = UIFont.systemFontOfSize(14.0)
        containerView.addSubview(chillTypeLabel)
        
        chillButton.setBackgroundImage(UIImage(named: "Snowflake.png"), forState: UIControlState.Normal)
        chillButton.alpha = 0.0
        chillButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        containerView.addSubview(chillButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("FATAL ERROR")
    }
    
    /**
    *   This is where we position the UI for the chill table view cell
    */
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.frame = CGRectMake(frame.width * 0.025, frame.height * 0.05, frame.width * 0.95, frame.height * 0.9)
        profileImage.frame = CGRectMake(0, 0, containerView.frame.height, containerView.frame.height)
        chillDetailsLabel.frame = CGRectMake(profileImage.frame.width + 10, 5, containerView.frame.width - profileImage.frame.width - 20, containerView.frame.height * 0.8 - 5)
        chillTypeLabel.frame = CGRectMake(profileImage.frame.width + 10, chillDetailsLabel.frame.height + 5, containerView.frame.width - profileImage.frame.width - 20, containerView.frame.height * 0.2)
        chillButton.frame = CGRectMake(10, 10, containerView.frame.height - 20, containerView.frame.height - 20)
        
    }
    
    /**
    *   This animates the chill cell when we tap it. It flip/rotates it and shows the front or back
    */
    func flipCell(currentChill : Chill){
        if(currentChill.flipped == false){  //We're flipping the cell over to show the BACK
            
            UIView.animateWithDuration(0.3) { () -> Void in
                self.containerView.layer.transform = CATransform3DMakeRotation(3.14, 1.0, 0.0, 0.0)
            }
            
            UIView.animateWithDuration(0.15, animations: { () -> Void in //HIDE THE FRONT UI
                self.profileImage.alpha = 0.0
                
                }) { (Bool) -> Void in //SHOW THE BACK UI
                    currentChill.flipped = true
                    self.chillButton.alpha = 1.0
                    self.containerView.layer.transform = CATransform3DMakeRotation(3.14, 0.0, 0.0, 0.0)
            }
            
        }else{  //We're flipping the cell to its original position to show the FRONT
            UIView.animateWithDuration(0.3) { () -> Void in
                self.containerView.layer.transform = CATransform3DMakeRotation(3.14, 1.0, 0.0, 0.0)
            }
            
            UIView.animateWithDuration(0.15, animations: { () -> Void in //HIDE THE BACK UI
                self.chillButton.alpha = 0.0
                
                }) { (Bool) -> Void in  // SHOW THE FRONT UI
                    currentChill.flipped = false
                    self.profileImage.alpha = 1.0
                    self.containerView.layer.transform = CATransform3DMakeRotation(3.14, 0.0, 0.0, 0.0)
            }
        }
    }
    
}