//
//  FriendsChillsViewController.swift
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

class FriendsChillsViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
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
            getFacebookFriends()
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
        titleLabel.text = "Friends' Chills"
        view.addSubview(titleLabel)
        
    }
    
    //MARK: - Adding & Getting Chills from the Backend
    
    /**
    * Downloads our chills from the backend that our friends are hosting
    */
    func getFriendsChills(){
        print("Get friends chills")
        let query = PFQuery(className:"Chill")
        query.whereKey("host", containedIn: PFUser.currentUser()?.objectForKey("facebookFriends") as! [String])
        query.limit = 25
        query.addDescendingOrder("createdAt")
        print(PFUser.currentUser()?.objectForKey("facebookFriends") as! [String])
        
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
    
    func getFacebookFriends() {
        let fbRequest = FBSDKGraphRequest(graphPath:"/me/friends", parameters: nil);
        print(fbRequest)
        fbRequest.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
            
            if error == nil {
                let facebookFriendArray : NSArray = result.objectForKey("data") as! NSArray
                var parseFriendArray : [String] = []
                for(index, friend) in facebookFriendArray.enumerate(){
                    parseFriendArray.append(friend.objectForKey("id") as! String)
                }
                print("Parse friend array: \(parseFriendArray)")
                PFUser.currentUser()?.setObject(parseFriendArray, forKey: "facebookFriends")
                PFUser.currentUser()?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                    self.getFriendsChills()
                })
                
            } else {
                
                print("Error Getting Friends \(error)");
                
            }
        }
    }
    
    func joinChill(sender: UIButton){
        let currentChill : Chill = chillArray[sender.tag]
        let parseChill : PFObject = PFObject(withoutDataWithClassName: "Chill", objectId: currentChill.id)
        parseChill.addObject(PFUser.currentUser()?.objectForKey("facebookID") as! String, forKey: "chillers")
        parseChill.incrementKey("chillersCount")
        parseChill.saveInBackground()
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
        getFriendsChills()
        refreshControl.endRefreshing()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : ChillTableViewCell = tableView.dequeueReusableCellWithIdentifier("ChillCell") as! ChillTableViewCell
        cell.backgroundColor = UIColor(red: 236.0/255.0, green: 240.0/255.0, blue: 241.0/255.0, alpha: 1.0)
        cell.selectionStyle = .None
        cell.chillButton.addTarget(self, action: "joinChill:", forControlEvents: UIControlEvents.TouchUpInside)
        cell.chillButton.tag = indexPath.row
        
        let currentChill : Chill = chillArray[indexPath.row]
        cell.chillDetailsLabel.text = currentChill.details
        let profilePictureURL = NSURL(string: "https://graph.facebook.com/me/picture?width=200&height=200&return_ssl_resources=1&access_token=\(currentChill.profilePic)")
        cell.profileImage.sd_setImageWithURL(profilePictureURL)
        cell.chillTypeLabel.text = "\(currentChill.type)&"
        if(currentChill.flipped == true){
            cell.profileImage.alpha = 0.0
            cell.chillButton.alpha = 1.0
        }else{
            cell.profileImage.alpha = 1.0
            cell.chillButton.alpha = 0.0
        }
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return chillTableCellHeight
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chillArray.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell : ChillTableViewCell = tableView.cellForRowAtIndexPath(indexPath) as! ChillTableViewCell
        cell.flipCell()
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
}