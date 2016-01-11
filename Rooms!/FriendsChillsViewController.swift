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
    var currentChill = Chill()
    
    //MARK: - UI
    let bannerBackground : UIView = UIView()
    let titleLabel : UILabel = UILabel()
    let nobodyChillingView = UIView()
    
    //MARK: - View Methods
    
    override func viewDidLoad() {
        print("View did load")
        addMainUI()
        addChillTableView()
        addFacebookUI()
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
        
        nobodyChillingView.frame = CGRectMake(0, 74, view.frame.width, view.frame.height - 74)
        nobodyChillingView.alpha = 0.0
        view.addSubview(nobodyChillingView)
        
        let snowflakeIcon = UIImageView(image: UIImage(named: "ChillSnowflakeSmall.png"))
        snowflakeIcon.frame = CGRectMake(CGRectGetMidX(view.frame) - 64, CGRectGetMidY(view.frame) - 128, 128, 128)
        snowflakeIcon.contentMode = .ScaleAspectFit
        nobodyChillingView.addSubview(snowflakeIcon)
        
        let nobodyLabel = UILabel(frame: CGRectMake(view.frame.size.width * 0.1, CGRectGetMaxY(snowflakeIcon.frame) + 10, view.frame.size.width * 0.8, 128))
        nobodyLabel.adjustsFontSizeToFitWidth = true
        nobodyLabel.textAlignment = .Center
        nobodyLabel.font = UIFont.systemFontOfSize(14.0)
        nobodyLabel.numberOfLines = -1
        nobodyLabel.text = "None of your friends are chilling :(\nI'm sorry. Your friends have no chill."
        nobodyLabel.textColor = UIColor.flatGray()
        nobodyChillingView.addSubview(nobodyLabel)
        
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
                self.refreshControl.endRefreshing()
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
                self.refreshControl.endRefreshing()
                let alert = UIAlertController(title: "Oops!", message: "&Chill couldn't load any chills. Please make sure you're connected to the internet and have enabled access to your location under Settings > &Chill > Location.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                
                self.refreshControl.endRefreshing()
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

        //***Added by Alan Guilfoyle
        //Setup the loading view, which will hold the moving graphics
        self.loadSnowView = SnowingView( frame: refreshControl.bounds )
        //  Center the mode of the UIView
        self.loadSnowView.contentMode = UIViewContentMode.Center
        //  Set background color of the animation
        self.loadSnowView.backgroundColor = UIColor.suggestionBlack()
        
        //Hide the original spinner icon
        self.refreshControl.tintColor = UIColor.clearColor()
        
        //Add the loading colors views to our refresh control
        self.refreshControl.addSubview( loadSnowView )
        
        //Initalize flags
        self.isRefreshAnimating = false;
        self.isRefreshIconsOverlap = false;
        
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: .ValueChanged)
        chillTableView.addSubview(refreshControl)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : ChillTableViewCell = tableView.dequeueReusableCellWithIdentifier("ChillCell") as! ChillTableViewCell
        let currentChill : Chill = chillArray[indexPath.row]
        cell.setUpWithChill(currentChill)
        cell.detailsButton.addTarget(self, action: "showDetails:", forControlEvents: .TouchUpInside)
        cell.reportButton.addTarget(self, action: "reportChill:", forControlEvents: .TouchUpInside)
        cell.profileImage.addTarget(self, action: "showFBPreview:", forControlEvents: .TouchUpInside)
        let swipeLeftRecognizer = UISwipeGestureRecognizer(target: self, action: "removeChill:")
        swipeLeftRecognizer.direction = .Left
        cell.tag = indexPath.row
        cell.addGestureRecognizer(swipeLeftRecognizer)
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return chillTableCellHeight
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(chillArray.count < 1){
            nobodyChillingView.alpha = 1.0
        }else{
            nobodyChillingView.alpha = 0.0
        }
        return chillArray.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell : ChillTableViewCell = tableView.cellForRowAtIndexPath(indexPath) as! ChillTableViewCell
        cell.flipCell()
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    //MARK: - Table Cell Methods
    
    func removeChill(gestureRecognizer : UISwipeGestureRecognizer){
        let chillCell = gestureRecognizer.view as! ChillTableViewCell
        chillArray.removeAtIndex(chillCell.tag)
        chillCell.removeChillFromTable(chillTableView)
    }
    
    //TODO: This is the worst code in the app... We're using the button's superview.superview to refer to the
    //Chill TableViewCell to get the currentChill the button is referring to... This needs to be fixed
    
    func reportChill(sender : UIButton){
        let reportButton = sender
        let chillCell : ChillTableViewCell = reportButton.superview?.superview as! ChillTableViewCell
        let originalColor = chillCell.containerView.backgroundColor
        chillCell.containerView.backgroundColor = UIColor.redColor()
        let currentChill = chillCell.currentChill
        
        let alert = UIAlertController(title: "Reporting Chill", message: "You have opted to report this user's chill. If you choose to continue, the &Chill team will review it for deletion. We can also block this user if you would like, hiding all of their Chills from you. This action cannot be undone and should not be taken lightly.", preferredStyle: UIAlertControllerStyle.ActionSheet)
        alert.addAction(UIAlertAction(title: "Nevermind", style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Report Chill", style: UIAlertActionStyle.Default, handler:{ (alert: UIAlertAction) -> Void in
            self.chillArray.removeAtIndex(chillCell.tag)
            chillCell.removeChillFromTable(self.chillTableView)
            self.updateReportedChill(currentChill)
        }))
        alert.addAction(UIAlertAction(title: "Block User", style: .Destructive, handler: { (alert: UIAlertAction) -> Void in
            self.chillArray.removeAtIndex(chillCell.tag)
            chillCell.removeChillFromTable(self.chillTableView)
            self.updateReportedChill(currentChill)
        }))
        chillCell.containerView.backgroundColor = originalColor
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func updateReportedChill(reportedChill: Chill){
        let parseChill : PFObject = PFObject(withoutDataWithClassName: "Chill", objectId: reportedChill.id)
        parseChill.incrementKey("reportCount")
        parseChill.saveInBackground()
    }
    
    func showDetails(sender : UIButton){
        let detailsButton = sender
        let chillCell : ChillTableViewCell = detailsButton.superview?.superview as! ChillTableViewCell
        currentChill = chillCell.currentChill
        performSegueWithIdentifier("showChillDetailsSegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "showChillDetailsSegue"){
            let vc = segue.destinationViewController as! ChillDetailsViewController
            vc.currentChill = currentChill
        }
    }
    
    //MARK: -Facebook
    
    let fbPreviewView = UIButton(type: .System)
    let fbProfileImage = UIImageView()
    let fbNameButton = UIButton()
    var currentFacebookProfileID = ""
    
    func addFacebookUI(){
        fbPreviewView.frame = CGRectMake(0, 64, view.frame.width, view.frame.height)
        fbPreviewView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        fbPreviewView.alpha = 0.0
        fbPreviewView.addTarget(self, action: "hideFBPreview", forControlEvents: .TouchUpInside)
        view.addSubview(fbPreviewView)
        
        fbProfileImage.frame = CGRectMake(CGRectGetMidX(view.frame) - 128, CGRectGetMidY(view.frame) - 256, 256, 256)
        fbProfileImage.layer.cornerRadius = 8.0
        fbProfileImage.backgroundColor = UIColor.flatGray()
        fbProfileImage.layer.masksToBounds = true
        fbPreviewView.addSubview(fbProfileImage)
        
        fbNameButton.frame = CGRectMake(fbProfileImage.frame.origin.x, CGRectGetMaxY(fbProfileImage.frame) + 10, 256, 40)
        fbNameButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        fbNameButton.backgroundColor = UIColor.icyBlue()
        fbNameButton.layer.cornerRadius = 8.0
        fbNameButton.addTarget(self, action: "openProfile", forControlEvents: .TouchUpInside)
        fbNameButton.layer.masksToBounds = true
        fbNameButton.titleLabel?.font = UIFont.systemFontOfSize(14.0)
        fbNameButton.titleLabel?.adjustsFontSizeToFitWidth = true
        fbPreviewView.addSubview(fbNameButton)
        
    }
    
    func showFBPreview(sender : UIButton){
        let profileButton = sender
        let chillCell : ChillTableViewCell = profileButton.superview?.superview as! ChillTableViewCell
        let profilePictureURL = NSURL(string: "https://graph.facebook.com/\(chillCell.currentChill.host)/picture?type=square&width=512&height=512&return_ssl_resources=1")
        currentFacebookProfileID = "\(chillCell.currentChill.host)"
        fbProfileImage.sd_setImageWithURL(profilePictureURL)
        fbNameButton.setTitle("View \(chillCell.currentChill.hostName)'s Profile", forState: .Normal)
        fbPreviewView.alpha = 1.0
    }
    
    func hideFBPreview(){
        fbPreviewView.alpha = 0.0
    }
    
    func openProfile(){
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.facebook.com/app_scoped_user_id/\(currentFacebookProfileID)")!)
    }


    
    //MARK: - REFRESH CONTROL
    
    //***Added by Alan Guilfoyle
    var isRefreshIconsOverlap   = false;
    var isRefreshAnimating      = false;
    var loadSnowView            = UIView()
    let refreshControl          = UIRefreshControl()
    
    func refresh(refreshControl: UIRefreshControl) {
        //***Added by Alan Guilfoyle
        //  Adding a delay to show the animation
        let delayInSeconds = 1.0;
        let popTime = dispatch_time( DISPATCH_TIME_NOW,
            Int64( delayInSeconds * Double( NSEC_PER_SEC )));
        
        dispatch_after( popTime, dispatch_get_main_queue()) { () -> Void in
            self.getFriendsChills()
        }
    }
    
    //***Added by Alan Guilfoyle
    func animateRefreshView()
    {
        //  Flag that we are animating
        self.isRefreshAnimating = true;
        
        //  Create an instance of the SnowingView
        let animateIt = self.loadSnowView as! SnowingView
        
        //  Start the animations and remove all animations once complete, resetAnimation flags
        animateIt.addSpinningAnimation() { success in
            animateIt.removeAllAnimations()
            animateIt.addSpinningAnimation( removedOnCompletion: true )
            self.resetAnimation()
        }
    }
    
    //***Added by Alan Guilfoyle
    func resetAnimation()
    {
        // Reset our flags and }background color
        self.isRefreshAnimating = false;
        self.isRefreshIconsOverlap = false;
    }
    
    
    //***Added by Alan Guilfoyle
    func scrollViewDidScroll(scrollView: UIScrollView)
    {
        // Get the current size of the refresh controller
        var refreshBounds = self.refreshControl.bounds;
        
        // Distance the table has been pulled >= 0
        let pullDistance = max(0.0, -self.refreshControl.frame.origin.y);
        
        // Set the encompassing view's frames
        refreshBounds.size.height = pullDistance;
        
        self.loadSnowView.frame = refreshBounds;
        
        // If we're refreshing and the animation is not playing, then play the animation
        if (self.refreshControl.refreshing && !self.isRefreshAnimating)
        {
            self.animateRefreshView()
        }
    }
    
}