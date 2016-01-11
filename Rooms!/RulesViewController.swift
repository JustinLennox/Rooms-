//
//  RulesViewController.swift
//  AndChill
//
//  Created by Justin Lennox on 1/11/16.
//  Copyright © 2016 Justin Lennox. All rights reserved.
//

import UIKit

class RulesViewController: UIViewController {
    
    override func viewDidLoad() {
        addRulesUI()
        view.backgroundColor = UIColor.icyBlue()
    }
    
    override func viewWillAppear(animated: Bool) {
        if(NSUserDefaults.standardUserDefaults().objectForKey("AgreedToRules") == nil || NSUserDefaults.standardUserDefaults().objectForKey("AgreedToRules") as! String != "YES"){
            NSUserDefaults.standardUserDefaults().setObject("NO", forKey: "AgreedToRules")
            agreeButton.alpha = 1.0
        }else{
            cancelButton.setTitle("Back", forState: UIControlState.Normal)
            agreeButton.alpha = 0.0
        }
    }
    
    
    
    //MARK: - UI
    let rulesContainer = UIView()
    let cancelButton = UIButton(type: .System)
    let agreeButton = UIButton(type: .System)

    func addRulesUI(){
        rulesContainer.frame = view.frame
        view.addSubview(rulesContainer)
        
        let bannerBackground = UIView(frame:CGRectMake(0, 0, view.frame.width, 34))
        bannerBackground.backgroundColor = UIColor.icyBlue()
        rulesContainer.addSubview(bannerBackground)
        
        let rulesLabel = UILabel(frame: CGRectMake(0, 30, view.frame.width, 24))
        rulesLabel.text = "Rules"
        rulesLabel.font = UIFont.systemFontOfSize(20.0)
        rulesLabel.textColor = UIColor.whiteColor()
        rulesLabel.textAlignment = .Center
        rulesLabel.backgroundColor = UIColor.icyBlue()
        rulesContainer.addSubview(rulesLabel)
        
        cancelButton.backgroundColor = UIColor.icyBlue()
        cancelButton.frame = CGRectMake(0, 30, view.frame.width * 0.25, 24)
        cancelButton.setTitle("Cancel", forState: .Normal)
        cancelButton.titleLabel?.textAlignment = .Left
        cancelButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        cancelButton.titleLabel?.font = UIFont.systemFontOfSize(18.0)
        cancelButton.addTarget(self, action: "cancelButtonPressed", forControlEvents: .TouchUpInside)
        rulesContainer.addSubview(cancelButton)
        
        agreeButton.backgroundColor = UIColor.icyBlue()
        agreeButton.frame = CGRectMake(view.frame.width * 0.75, 30, view.frame.width * 0.25, 24)
        agreeButton.setTitle("Agree", forState: .Normal)
        agreeButton.titleLabel?.textAlignment = .Right
        agreeButton.addTarget(self, action: "agreeButtonPressed", forControlEvents: .TouchUpInside)
        agreeButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        agreeButton.titleLabel?.font = UIFont.systemFontOfSize(18.0)
        agreeButton.alpha = 0.0
        rulesContainer.addSubview(agreeButton)
        
        let rulesBackground = UIView(frame: CGRectMake(0, 64,view.frame.width, view.frame.height))
        rulesBackground.backgroundColor = UIColor.whiteColor()
        rulesContainer.addSubview(rulesBackground)
        
        let ruleDetailsLabel = UILabel(frame: CGRectMake(view.frame.width * 0.05, 100,view.frame.width * 0.9,view.frame.height - 100))
        ruleDetailsLabel.font = UIFont.systemFontOfSize(18.0)
        ruleDetailsLabel.numberOfLines = -1
        ruleDetailsLabel.textColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        ruleDetailsLabel.adjustsFontSizeToFitWidth = true
        ruleDetailsLabel.text = "In order to have a chill time, you should NOT post content on &Chill that harms either the feed or your community. For example:\n\nDO NOT bully or specifically target others.\n\nDO NOT post other people's phone numbers, street addresses, social media accounts, or other personally identifiable information without their express permission.\n\nDO NOT post repetitive, spammy content.\n\nIf your chills are repeatedly reported or flagged, you will be blocked from using &Chill."
        ruleDetailsLabel.sizeToFit()
        rulesContainer.addSubview(ruleDetailsLabel)
        
    }
    
    func cancelButtonPressed(){
        performSegueWithIdentifier("returnNearbySegue", sender: self)
    }
    
    func agreeButtonPressed(){
        NSUserDefaults.standardUserDefaults().setObject("YES", forKey: "AgreedToRules")
        dismissViewControllerAnimated(true, completion: nil)
    }

}
