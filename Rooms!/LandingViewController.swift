//
//  ViewController.swift
//  Rooms!
//
//  Created by Justin Lennox on 9/30/15.
//  Copyright © 2015 Justin Lennox. All rights reserved.
//

import UIKit
import Darwin
import ParseFacebookUtilsV4

class LandingViewController: UIViewController {
    
    //Random images variable
    var imageIndex = 1
    
    //MARK: UI Properties
    let backgroundImage = UIImageView()
    let titleLabel = UILabel()
    let descriptionLabel = UILabel()
    let assuranceLabel = UILabel()
    let connectToFacebookButton = UIButton(type: UIButtonType.System)
    
    //MARK: View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        view.backgroundColor = UIColor(red: (50.0/255.0), green: (50.0/255.0), blue: (50.0/255.0), alpha: 1.0)
        view.backgroundColor = UIColor.blackColor()
        addUI()
        if(NSUserDefaults.standardUserDefaults().objectForKey("FirstTime") == nil){
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "FirstTime")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let myTimer = NSTimer.scheduledTimerWithTimeInterval(2.5, target: self, selector: "cycleImages", userInfo: nil, repeats: true)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if(PFUser.currentUser() != nil){
            self.performSegueWithIdentifier("loginSegue", sender: self)
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    //MARK: UI Methods
    
    /**
    *   Adds, styles, and positions all of the UI subviews in the view.
    * This is where you can change/add/play with the landing screen UI!
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
        
        connectToFacebookButton.frame = CGRectMake(view.frame.size.width * 0.0625, CGRectGetMaxY(assuranceLabel.frame) + view.frame.height * 0.01, view.frame.size.width * 0.875, view.frame.height * 0.06)
        connectToFacebookButton.titleLabel?.textAlignment = NSTextAlignment.Center
        connectToFacebookButton.setTitle("Connect to Facebook", forState: UIControlState.Normal)
        connectToFacebookButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        connectToFacebookButton.titleLabel!.font = UIFont(name: "Helvetica", size: 15.0)
        connectToFacebookButton.backgroundColor = UIColor.cSeafoam()
        connectToFacebookButton.addTarget(self, action: "facebookButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
        connectToFacebookButton.layer.cornerRadius = 5
        view.addSubview(connectToFacebookButton)
        
        backgroundImage.image = UIImage(named: "Party.png")
        backgroundImage.contentMode = UIViewContentMode.ScaleAspectFill
        backgroundImage.frame = CGRectMake(0, 0, view.frame.width, view.frame.height)
        backgroundImage.alpha = 0.5
        view.addSubview(backgroundImage)
        view.sendSubviewToBack(backgroundImage)
    }
    
    /**
    *   The user has pressed the 'Connect to Facebook' button. We log them into facebook
    *   with the proper permissions and then segue to the NearbyChills View Controller
    */
    func facebookButtonPressed(){
        
        let permissions = ["public_profile", "email", "user_friends"]
        
        //Log the user into parse with the facebook permissions above
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions,  block: {  (user: PFUser?, error: NSError?) -> Void in
            if let user = user {
                
                //We can check if the user is a new user here. Just in case we want to.
                if user.isNew {

                } else {

                }
                
                //Send a request to Facebook for the current facebook user
                let fbRequest = FBSDKGraphRequest(graphPath:"/me", parameters: nil);
                fbRequest.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
                    if error == nil {   //There wasn't a problem, this FB user exists
                        PFUser.currentUser()?.setObject(result.objectForKey("id") as! String, forKey: "facebookID")
                        PFUser.currentUser()?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                            if(error == nil){
                                self.performSegueWithIdentifier("loginSegue", sender: self)
                            }
                        })
                    } else {
                        print("Error Getting Friends \(error)");
                    }
                }
            } else {
                print("Uh oh. The user cancelled the Facebook login.")
            }
        })
    }
    
    
    func cycleImages(){
        
        //**Images complements of Jeffrey Nguyen
        switch (imageIndex)
        {
            case 0:
                backgroundImage.image = UIImage(named: "Party.png")
                break
                
            case 1:
                backgroundImage.image = UIImage(named: "Camp.png")
                break
                
            case 2:
                backgroundImage.image = UIImage(named: "cooler.png")
                break
            
            case 3:
                backgroundImage.image = UIImage(named: "Camping.png")
                break
            
            case 4:
                backgroundImage.image = UIImage(named: "Cafe.png")
                break
            
            case 5:
                backgroundImage.image = UIImage(named: "Movies.png")
                break
            
            case 6:
                backgroundImage.image = UIImage(named: "CampFire.png")
                break
            
            default:
                break
        }
        imageIndex = imageIndex < 6 ? imageIndex + 1 : 0
    }
}


