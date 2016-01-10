//
//  MyChillsViewController.swift
//  AndChill
//
//  Created by Justin Lennox on 11/18/15.
//  Copyright © 2015 Justin Lennox. All rights reserved.
//

import UIKit
import Parse
import QuartzCore
import ParseFacebookUtilsV4
import FBSDKCoreKit

class MyChillsViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var chillArray : [Chill] = []
    let chillTableCellHeight : CGFloat = 100.0
    
    //MARK: - UI
    let bannerBackground : UIView = UIView()
    let titleLabel : UILabel = UILabel()
    
    //MARK: - View Methods
    
    override func viewDidLoad() {
        addMainUI()
        addChillTableView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.topItem?.title = "Add an Activity"
        if(PFUser.currentUser() != nil){
            getMyChills()
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //If there's no user logged in, send them to the Landing Screen
        if(PFUser.currentUser() == nil){
            performSegueWithIdentifier("showLoginSegue", sender: self)
        }
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
        titleLabel.text = "My Chills"
        view.addSubview(titleLabel)
        
        let settingsIcon = UIButton(type: .System)
        settingsIcon.setBackgroundImage(UIImage(named: "settingsIcon.png"), forState: .Normal)
        settingsIcon.imageView?.contentMode = .ScaleAspectFit
        settingsIcon.frame = CGRectMake(view.frame.width - 40, bannerY + 10, 30, 30)
        settingsIcon.addTarget(self, action: "settingsPressed", forControlEvents: .TouchUpInside)
        view.addSubview(settingsIcon)
        
    }
    
    func settingsPressed(){
        performSegueWithIdentifier("showSettingsSegue", sender: self)
    }
    
    //MARK: - Adding & Getting Chills from the Backend
    
    /**
    * Downloads our chills from the backend that we're the host of
    */
    func getMyChills(){
        let hostQuery = PFQuery(className:"Chill")
        hostQuery.whereKey("host", equalTo: PFUser.currentUser()?.objectForKey("facebookID") as! String)
        
        let chillerQuery = PFQuery(className: "Chill")
        chillerQuery.whereKey("chillers", equalTo: PFUser.currentUser()?.objectForKey("facebookID") as! String)
        
        let query = PFQuery.orQueryWithSubqueries([hostQuery, chillerQuery])
        query.limit = 25
        query.addDescendingOrder("createdAt")
        
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                
                // Do something with the found objects
                if let objects = objects as [PFObject]! {
                    self.chillArray = []
                    for chillDictionary in objects {
                        
                        let chill = Chill.parseDictionaryIntoChill(chillDictionary)
                        self.chillArray.append(chill)
                    }
                    self.chillTableView.reloadData()
                    
                }
            } else {
                // Log details of the failure
                print("Error: \(error!)")
            }
        }
    }
    
    //MARK: - Table View
    
    let chillTableView = UITableView()
    
    func addChillTableView(){
        chillTableView.frame = CGRectMake(0, CGRectGetMaxY(bannerBackground.frame), view.frame.width, view.frame.height - bannerBackground.frame.height - 49)
        chillTableView.delegate = self
        chillTableView.dataSource = self
        chillTableView.registerClass(ChillTableViewCell.self, forCellReuseIdentifier: "ChillCell")
        chillTableView.separatorStyle = .None
        chillTableView.backgroundColor = UIColor(red: 236.0/255.0, green: 240.0/255.0, blue: 241.0/255.0, alpha: 1.0)
        view.addSubview(chillTableView)
        view.sendSubviewToBack(chillTableView)
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = UIColor.redColor()
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: .ValueChanged)
        chillTableView.addSubview(refreshControl)
    }
    
    func refresh(refreshControl: UIRefreshControl) {
        // Do your job, when done:
        getMyChills()
        refreshControl.endRefreshing()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : ChillTableViewCell = tableView.dequeueReusableCellWithIdentifier("ChillCell") as! ChillTableViewCell
        cell.backgroundColor = UIColor(red: 236.0/255.0, green: 240.0/255.0, blue: 241.0/255.0, alpha: 1.0)
        cell.selectionStyle = .None
        cell.chillButton.addTarget(self, action: "removeChill:", forControlEvents: UIControlEvents.TouchUpInside)
        cell.chillButton.tag = indexPath.row
        
        let currentChill : Chill = chillArray[indexPath.row]
        cell.chillDetailsLabel.text = currentChill.details
        let profilePictureURL = NSURL(string: "https://graph.facebook.com/me/picture?width=200&height=200&return_ssl_resources=1&access_token=\(currentChill.profilePic)")
        cell.profileImage.sd_setImageWithURL(profilePictureURL)
        if(currentChill.flipped == true){
            cell.profileImage.alpha = 0.0
            cell.chillButton.alpha = 1.0
        }else{
            cell.profileImage.alpha = 1.0
            cell.chillButton.alpha = 0.0
        }
        
        cell.chillTypeLabel.text = "\(currentChill.type)&"

        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return chillTableCellHeight
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chillArray.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell :ChillTableViewCell = tableView.cellForRowAtIndexPath(indexPath) as! ChillTableViewCell
        let currentChill : Chill = chillArray[indexPath.row]
        cell.flipCell()
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
}
