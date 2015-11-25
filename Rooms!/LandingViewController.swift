//
//  ViewController.swift
//  Rooms!
//
//  Created by Justin Lennox on 9/30/15.
//  Copyright © 2015 Justin Lennox. All rights reserved.
//

import UIKit

class LandingViewController: UIViewController {
    
    //MARK: UI Properties
    let backgroundImage = UIImageView()
    let titleLabel = UILabel()
    let descriptionLabel = UILabel()
    let loginButton = UIButton(type: UIButtonType.System)
    let signUpButton = UIButton(type: UIButtonType.System)

    //MARK: View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = UIColor(red: (50.0/255.0), green: (50.0/255.0), blue: (50.0/255.0), alpha: 1.0)
        
        addUI()
    }
    
    //MARK: UI Methods
    
    /**
    *   Adds, styles, and positions all of the UI subviews in the view
    */
    func addUI(){
        
        titleLabel.text = "Rooms"
        titleLabel.frame = CGRectMake(0, view.frame.height * 0.12, view.frame.size.width, view.frame.size.height * 0.08)
        titleLabel.textColor = UIColor(red: (236.0/255.0), green: (240.0/255.0), blue: (241.0/255.0), alpha: 1.0)
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.font = UIFont(name: "AvenirNext-Demibold", size: 50.0)
        view.addSubview(titleLabel)
        
        descriptionLabel.text = "A location-based activities app"
        descriptionLabel.frame = CGRectMake(0, CGRectGetMaxY(titleLabel.frame), view.frame.size.width, view.frame.size.height * 0.05)
        descriptionLabel.textColor = UIColor(red: (236.0/255.0), green: (240.0/255.0), blue: (241.0/255.0), alpha: 1.0)
        descriptionLabel.textAlignment = NSTextAlignment.Center
        descriptionLabel.font = UIFont(name: "Avenir Next", size: 20.0)
        view.addSubview(descriptionLabel)
        
        signUpButton.frame = CGRectMake(view.frame.width/2.0 - view.frame.size.width * 0.25, view.frame.height * 0.4, view.frame.size.width * 0.50, view.frame.height * 0.1)
        signUpButton.titleLabel?.textAlignment = NSTextAlignment.Center
        signUpButton.setTitle("Sign Up", forState: UIControlState.Normal)
        signUpButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        signUpButton.titleLabel!.font = UIFont(name: "AvenirNext-Medium", size: 30.0)
        signUpButton.backgroundColor = UIColor.clearColor()
        signUpButton.addTarget(self, action: "loginButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
        signUpButton.layer.borderColor = UIColor.whiteColor().CGColor
        signUpButton.layer.borderWidth = 1
        signUpButton.layer.cornerRadius = 5
        view.addSubview(signUpButton)
        
        loginButton.frame = CGRectMake(view.frame.width/2.0 - view.frame.size.width * 0.25, view.frame.height * 0.55, view.frame.size.width * 0.50, view.frame.height * 0.1)
        loginButton.titleLabel?.textAlignment = NSTextAlignment.Center
        loginButton.addTarget(self, action: "loginButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
        loginButton.setTitle("Login", forState: UIControlState.Normal)
        loginButton.titleLabel!.font = UIFont(name: "Avenir Next", size: 30.0)
        loginButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        loginButton.backgroundColor = UIColor.clearColor()
        loginButton.layer.borderColor = UIColor.whiteColor().CGColor
        loginButton.layer.borderWidth = 1
        loginButton.layer.cornerRadius = 5
        view.addSubview(loginButton)
        
        backgroundImage.image = UIImage(named: "LaunchBack.jpg")
        backgroundImage.frame = CGRectMake(0, 0, view.frame.width, view.frame.height)
        backgroundImage.alpha = 0.5
        view.addSubview(backgroundImage)
        view.sendSubviewToBack(backgroundImage)
        
    }
    
    //TODO: Add User Login Flow
    func loginButtonPressed(){
        performSegueWithIdentifier("loginSegue", sender: self)
    }


}

