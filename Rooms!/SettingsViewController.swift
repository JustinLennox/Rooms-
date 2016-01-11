//
//  SettingsViewController.swift
//  AndChill
//
//  Created by Justin Lennox on 1/5/16.
//  Copyright © 2016 Justin Lennox. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    //MARK: - UI
    let bannerBackground : UIView = UIView()
    let titleLabel : UILabel = UILabel()
    let logoutButton = UIButton(type: .System)
    
    override func viewDidLoad() {
        addMainUI()
    }
    
    func addMainUI(){
        bannerBackground.frame = CGRectMake(0, 0, view.frame.width, 64)
        bannerBackground.backgroundColor = UIColor.icyBlue()
        view.addSubview(bannerBackground)
        
        let bannerY = bannerBackground.frame.height * 0.25
        let bannerHeight = bannerBackground.frame.height * 0.8
        
        titleLabel.frame = CGRectMake(view.frame.width * 0.125, bannerY, view.frame.width * 0.75, bannerHeight)
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.font = UIFont.systemFontOfSize(25.0)
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = "Settings"
        view.addSubview(titleLabel)
        
        let backButton = UIButton(type: .System)
        backButton.setBackgroundImage(UIImage(named: "backArrow.png"), forState: .Normal)
        backButton.frame = CGRectMake(10, bannerY + 8, 32, 32)
        backButton.addTarget(self, action: "backButtonPressed", forControlEvents: .TouchUpInside)
        view.addSubview(backButton)
        
        logoutButton.frame = CGRectMake(view.frame.width * 0.025, CGRectGetMaxY(view.frame) - 120, view.frame.width * 0.95, 90)
        logoutButton.setTitle("Logout", forState: .Normal)
        logoutButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        logoutButton.layer.cornerRadius = 8.0
        logoutButton.layer.masksToBounds = true
        logoutButton.backgroundColor = UIColor.icyBlue()
        if #available(iOS 8.2, *) {
            logoutButton.titleLabel?.font = UIFont.systemFontOfSize(20.0, weight: 0.2)
        } else {
            // Fallback on earlier versions
            logoutButton.titleLabel?.font = UIFont.systemFontOfSize(20.0)
        }
        logoutButton.addTarget(self, action: "logout", forControlEvents: .TouchUpInside)
        view.addSubview(logoutButton)
    }
    
    func logout(){
        if(FBSDKAccessToken.currentAccessToken() != nil){
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
        }
        if(PFUser.currentUser() != nil){
            PFUser.logOut()
        }
        performSegueWithIdentifier("showLandingSegue", sender: self)
    }
    
    func backButtonPressed(){
        dismissViewControllerAnimated(true, completion: nil)
    }
}
