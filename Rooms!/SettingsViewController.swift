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
    let rulesButton = UIButton(type: .System)
    let privacyPolicyButton = UIButton(type: .System)
    let termsButton = UIButton(type: .System)

    
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
        
        let buttonHeight = (view.frame.height - 120 / 4) < 90 ? view.frame.height - 120 / 4 : 90
        
        rulesButton.frame = CGRectMake(view.frame.width * 0.025, 74, view.frame.width * 0.95, buttonHeight)
        rulesButton.setTitle("Rules", forState: .Normal)
        rulesButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        rulesButton.layer.cornerRadius = 8.0
        rulesButton.layer.masksToBounds = true
        rulesButton.backgroundColor = UIColor.flatGray()
        if #available(iOS 8.2, *) {
            rulesButton.titleLabel?.font = UIFont.systemFontOfSize(20.0, weight: 0.2)
        } else {
            // Fallback on earlier versions
            rulesButton.titleLabel?.font = UIFont.systemFontOfSize(20.0)
        }
        rulesButton.addTarget(self, action: "showRules", forControlEvents: .TouchUpInside)
        view.addSubview(rulesButton)
        
        privacyPolicyButton.frame = CGRectMake(view.frame.width * 0.025, CGRectGetMaxY(rulesButton.frame) + 10, view.frame.width * 0.95, buttonHeight)
        privacyPolicyButton.setTitle("Privacy Policy", forState: .Normal)
        privacyPolicyButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        privacyPolicyButton.layer.cornerRadius = 8.0
        privacyPolicyButton.layer.masksToBounds = true
        privacyPolicyButton.backgroundColor = UIColor.flatGray()
        if #available(iOS 8.2, *) {
            privacyPolicyButton.titleLabel?.font = UIFont.systemFontOfSize(20.0, weight: 0.2)
        } else {
            // Fallback on earlier versions
            privacyPolicyButton.titleLabel?.font = UIFont.systemFontOfSize(20.0)
        }
        privacyPolicyButton.addTarget(self, action: "showPrivacyPolicy", forControlEvents: .TouchUpInside)
        view.addSubview(privacyPolicyButton)
        
        termsButton.frame = CGRectMake(view.frame.width * 0.025, CGRectGetMaxY(privacyPolicyButton.frame) + 10, view.frame.width * 0.95, buttonHeight)
        termsButton.setTitle("Terms of Use", forState: .Normal)
        termsButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        termsButton.layer.cornerRadius = 8.0
        termsButton.layer.masksToBounds = true
        termsButton.backgroundColor = UIColor.flatGray()
        if #available(iOS 8.2, *) {
            termsButton.titleLabel?.font = UIFont.systemFontOfSize(20.0, weight: 0.2)
        } else {
            // Fallback on earlier versions
            termsButton.titleLabel?.font = UIFont.systemFontOfSize(20.0)
        }
        termsButton.addTarget(self, action: "showTermsOfUse", forControlEvents: .TouchUpInside)
        view.addSubview(termsButton)

        
        logoutButton.frame = CGRectMake(view.frame.width * 0.025, CGRectGetMaxY(termsButton.frame) + 10, view.frame.width * 0.95, buttonHeight)
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
    
    func showRules(){
        performSegueWithIdentifier("showRulesSegue", sender: self)
    }
    
    func showPrivacyPolicy(){
        performSegueWithIdentifier("showPrivacyPolicySegue", sender: self)
    }
    
    func showTermsOfUse(){
        performSegueWithIdentifier("showTermsOfUseSegue", sender: self)
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
