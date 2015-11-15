//
//  ViewController.swift
//  Rooms!
//
//  Created by Justin Lennox on 9/30/15.
//  Copyright © 2015 Justin Lennox. All rights reserved.
//

import UIKit
import ParseFacebookUtilsV4

class LandingViewController: UIViewController {
    
    //MARK: UI Properties
    let backgroundImage = UIImageView()
    let titleLabel = UILabel()
    let descriptionLabel = UILabel()
    let assuranceLabel = UILabel()
    let loginButton = UIButton(type: UIButtonType.System)
    let signUpButton = UIButton(type: UIButtonType.System)
    
    //MARK: View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = UIColor(red: (50.0/255.0), green: (50.0/255.0), blue: (50.0/255.0), alpha: 1.0)
        addUI()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    //MARK: UI Methods
    
    /**
    *   Adds, styles, and positions all of the UI subviews in the view
    */
    func addUI(){
        
        titleLabel.text = "&Chill"
        titleLabel.frame = CGRectMake(0, view.frame.height * 0.06, view.frame.size.width, view.frame.size.height * 0.08)
        titleLabel.textColor = UIColor.cSeafoam()
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.font = UIFont(name: "Helvetica-Bold", size: 35.0)
        view.addSubview(titleLabel)
        
        descriptionLabel.text = "Find Other Chill People Near You To Do Chill Things With"
        descriptionLabel.frame = CGRectMake(view.frame.size.width * 0.05, view.frame.size.height * 0.45, view.frame.size.width * 0.9, view.frame.size.height * 0.13)
        descriptionLabel.textColor = UIColor(red: (236.0/255.0), green: (240.0/255.0), blue: (241.0/255.0), alpha: 1.0)
        descriptionLabel.adjustsFontSizeToFitWidth = true;
        descriptionLabel.textAlignment = NSTextAlignment.Center
        descriptionLabel.numberOfLines = 2;
        descriptionLabel.font = UIFont(name: "Helvetica", size: 25.0)
        view.addSubview(descriptionLabel)
        
        assuranceLabel.text = "We'll never post to your Facebook or send invites or spam"
        assuranceLabel.frame = CGRectMake(view.frame.width * 0.125, CGRectGetMaxY(descriptionLabel.frame), view.frame.width * 0.75, view.frame.size.height * 0.125)
        assuranceLabel.textColor = UIColor(red: (230.0/255.0), green: (230.0/255.0), blue: (230.0/255.0), alpha: 1.0)
        assuranceLabel.textAlignment = NSTextAlignment.Center
        assuranceLabel.numberOfLines = 2;
        assuranceLabel.font = UIFont(name: "Helvetica", size: 15.0)
        view.addSubview(assuranceLabel)
        
        signUpButton.frame = CGRectMake(view.frame.size.width * 0.0625, CGRectGetMaxY(assuranceLabel.frame) + view.frame.height * 0.01, view.frame.size.width * 0.875, view.frame.height * 0.06)
        signUpButton.titleLabel?.textAlignment = NSTextAlignment.Center
        signUpButton.setTitle("Connect to Facebook", forState: UIControlState.Normal)
        signUpButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        signUpButton.titleLabel!.font = UIFont(name: "Helvetica", size: 15.0)
        signUpButton.backgroundColor = UIColor.cSeafoam()
        signUpButton.addTarget(self, action: "loginButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
        signUpButton.layer.cornerRadius = 5
        view.addSubview(signUpButton)
        
        backgroundImage.image = UIImage(named: "Friends.jpg")
        backgroundImage.contentMode = UIViewContentMode.ScaleAspectFill
        backgroundImage.frame = CGRectMake(0, 0, view.frame.width, view.frame.height)
        backgroundImage.alpha = 0.8
        view.addSubview(backgroundImage)
        view.sendSubviewToBack(backgroundImage)
        
    }
    
    //TODO: Add User Login Flow
    func loginButtonPressed(){
        
        let permissions = [ "public_profile", "email", "user_friends" ]

        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions,  block: {  (user: PFUser?, error: NSError?) -> Void in
            if let user = user {
                if user.isNew {
                    print("User signed up and logged in through Facebook!")
                    self.performSegueWithIdentifier("loginSegue", sender: self)
                } else {
                    self.performSegueWithIdentifier("loginSegue", sender: self)
                    print("User logged in through Facebook!")
                }
            } else {
                print("Uh oh. The user cancelled the Facebook login.")
            }
        })
    }
}


