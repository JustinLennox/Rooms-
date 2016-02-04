//
//  AddAcitivityViewController.swift
//  Rooms!
//
//  Created by Justin Lennox on 10/14/15.
//  Copyright © 2015 Justin Lennox. All rights reserved.
//

import UIKit
import Parse
import QuartzCore
import ParseFacebookUtilsV4
import FBSDKCoreKit

class NearbyChillsViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var currentChill = Chill() //The chill the user wishes to see the details/chat of
    
    //Chill Variables
    var chillArray : [Chill] = []
    let chillTableCellHeight : CGFloat = 100.0
    
    //Suggestion Variables
    var suggestionArray = [[String:String]]()
    let suggestionTableCellHeight : CGFloat = 64.0
    
    //MARK: - UI
    let bannerBackground : UIView = UIView()
    let blankTextField : UITextField = UITextField()
    let nobodyChillingView = UIView()
    
    //MARK: - View Methods
    
    override func viewDidLoad() {
        addMainUI()
        addTableViews()
        getSuggestions()
        if(PFUser.currentUser() != nil || FBSDKAccessToken.currentAccessToken() != nil){
            updateUserLocation()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.topItem?.title = "Add an Activity"
        if(NSUserDefaults.standardUserDefaults().objectForKey("FirstTime") != nil){
            let firstTime : Bool = NSUserDefaults.standardUserDefaults().objectForKey("FirstTime") as! Bool
            if(!firstTime && PFUser.currentUser() != nil){
                getChills()
            }
        }
        if(NSUserDefaults.standardUserDefaults().objectForKey("TapForChill") == nil){
            blankTextField.text = "Tap Here to Search!"
        }
        self.tabBarController?.tabBar.hidden = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //If there's no user logged in, send them to the Landing Screen
        if(PFUser.currentUser() == nil){
            performSegueWithIdentifier("showLoginSegue", sender: self)

        //If there user is logged in but there isn't a valid facebook session
        }else if(PFUser.currentUser()?.objectForKey("name") == nil || (PFUser.currentUser()?.objectForKey("name") as! String != "guest" && FBSDKAccessToken.currentAccessToken() == nil)){
            performSegueWithIdentifier("showLoginSegue", sender: self)
        }else{
            if(NSUserDefaults.standardUserDefaults().objectForKey("FirstTime") != nil)
            {
                let firstTime : Bool = NSUserDefaults.standardUserDefaults().objectForKey("FirstTime") as! Bool
                if(firstTime)
                {
                    askForLocationAndNotification()
                }else{
                    let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
                    UIApplication.sharedApplication().registerUserNotificationSettings(settings)
                    UIApplication.sharedApplication().registerForRemoteNotifications()
                }
            }else{
                NSUserDefaults.standardUserDefaults().setObject(true, forKey: "FirstTime")
                NSUserDefaults.standardUserDefaults().synchronize()
                askForLocationAndNotification()
            }
        }
    }
        
        func askForLocationAndNotification(){
            print("ask location")
            let alert = UIAlertController(title: "Allow &Chill to Send You Notifications", message: "We're about to ask you if &Chill can send you notifications. &Chill needs to send you notifications when people invite you to chill, want to join your chills, or allow you to chill with them. Please consider allowing notifications.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (handler:UIAlertAction) -> Void in
                
                let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
                UIApplication.sharedApplication().registerUserNotificationSettings(settings)
                UIApplication.sharedApplication().registerForRemoteNotifications()
                
                let alert = UIAlertController(title: "Allow &Chill to Access Your Location", message: "&Chill needs to use your location in order to find activities near you. Please make sure you're connected to the internet and have enabled access to your location under Settings > &Chill > Location.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (handler:UIAlertAction) -> Void in
                    self.updateUserLocation()
                }))
                self.presentViewController(alert, animated: true, completion: nil)
            }))
            presentViewController(alert, animated: true, completion:nil)

        }
    
    let nobodyLabel = UILabel()
    
    func addMainUI(){
        bannerBackground.frame = CGRectMake(0, 0, view.frame.width, 64)
        bannerBackground.backgroundColor = UIColor.icyBlue()
        view.addSubview(bannerBackground)
        
        let bannerY = bannerBackground.frame.height * 0.25
        let bannerHeight = bannerBackground.frame.height * 0.8
        
        blankTextField.frame = CGRectMake(view.frame.width * 0.125, bannerY, view.frame.width * 0.75, bannerHeight)
        blankTextField.textAlignment = NSTextAlignment.Center
        blankTextField.font = UIFont.systemFontOfSize(25.0)
        blankTextField.textColor = UIColor.whiteColor()
        blankTextField.text = "&Chill"
        blankTextField.clearButtonMode = .WhileEditing
        blankTextField.returnKeyType = UIReturnKeyType.Search
        blankTextField.delegate = self
        blankTextField.tintColor = UIColor.whiteColor()
        view.addSubview(blankTextField)
        
        addFacebookUI()
        
        nobodyChillingView.frame = CGRectMake(0, 74, view.frame.width, view.frame.height - 74)
        nobodyChillingView.alpha = 0.0
        view.addSubview(nobodyChillingView)
        
        let snowflakeIcon = UIImageView(image: UIImage(named: "ChillSnowflakeSmall.png"))
        snowflakeIcon.frame = CGRectMake(CGRectGetMidX(view.frame) - 64, CGRectGetMidY(view.frame) - 128, 128, 128)
        snowflakeIcon.contentMode = .ScaleAspectFit
        nobodyChillingView.addSubview(snowflakeIcon)
        
        nobodyLabel.frame = CGRectMake(view.frame.size.width * 0.1, CGRectGetMaxY(snowflakeIcon.frame) + 10, view.frame.size.width * 0.8, 128)
        nobodyLabel.adjustsFontSizeToFitWidth = true
        nobodyLabel.textAlignment = .Center
        nobodyLabel.font = UIFont.systemFontOfSize(14.0)
        nobodyLabel.numberOfLines = -1
        nobodyLabel.text = "Loading Chills..."
        nobodyLabel.textColor = UIColor.flatGray()
        nobodyChillingView.addSubview(nobodyLabel)
        

    }
    
    //MARK: -Facebook
    
    let fbPreviewView = UIButton(type: .System)
    let fbProfileImage = UIImageView()
    let fbNameButton = UIButton()
    let chillersLabel = UILabel()
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
        
        chillersLabel.frame = CGRectMake(fbNameButton.frame.origin.x, CGRectGetMaxY(fbNameButton.frame) + 10, 256, 40)
        chillersLabel.text = "Chillers"
        chillersLabel.textColor = UIColor.whiteColor()
        chillersLabel.textAlignment = .Center
        chillersLabel.font = UIFont.systemFontOfSize(17.0)
        fbPreviewView.addSubview(chillersLabel)
        
    }
    
    func showFBPreview(sender : UIButton){
        let profileButton = sender
        let chillCell : ChillTableViewCell = profileButton.superview?.superview as! ChillTableViewCell
        let profilePictureURL = NSURL(string: "https://graph.facebook.com/\(chillCell.currentChill.host)/picture?type=square&width=512&height=512&return_ssl_resources=1")
        currentFacebookProfileID = "\(chillCell.currentChill.host)"
        fbProfileImage.sd_setImageWithURL(profilePictureURL)
        fbNameButton.setTitle("View \(chillCell.currentChill.hostName)'s Profile", forState: .Normal)
        fbPreviewView.alpha = 1.0
        showChillerProfilePics(chillCell.currentChill)
    }
    
    var profilePicArray = [UIImageView]()
    
    func showChillerProfilePics(currentChill : Chill){
        let originalX = fbNameButton.frame.origin.x + 5
        var currentX = originalX
        var currentY = CGRectGetMaxY(chillersLabel.frame) + 10
        for chillerFBID in currentChill.chillers{
            let profilePic = UIImageView()
            let profilePictureURL = NSURL(string: "https://graph.facebook.com/\(chillerFBID)/picture?type=square&width=60&height=60&return_ssl_resources=1")
            profilePic.sd_setImageWithURL(profilePictureURL)
            profilePic.frame = CGRectMake(currentX, currentY, 30, 30)
            profilePic.layer.cornerRadius = 8.0
            profilePic.layer.masksToBounds = true
            fbPreviewView.addSubview(profilePic)
            profilePicArray.append(profilePic)
            
            if(currentX + 40 > CGRectGetMaxX(fbNameButton.frame) - 5){
                currentX = originalX
                currentY += 40
            }else{
                currentX += 35
            }
        }
    }
    
    func hideFBPreview(){
        fbPreviewView.alpha = 0.0
        for profilePic in profilePicArray{
            profilePic.removeFromSuperview()
        }
        profilePicArray = []
    }
    
    func openProfile(){
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.facebook.com/app_scoped_user_id/\(currentFacebookProfileID)")!)
    }

    
    //MARK: - Adding & Getting Chills from the Backend
    
    /**
     * Downloads nearby chills from the backend
     */
    func getChills(){
        let query = PFQuery(className:"Chill")
        if let location = PFUser.currentUser()?.objectForKey("location"){
            let userLocation : PFGeoPoint = PFUser.currentUser()?.objectForKey("location") as! PFGeoPoint
            query.whereKey("location", nearGeoPoint: userLocation, withinMiles: 5.0)
            query.limit = 25

            var chillType : String = blankTextField.text!
            if(chillType.characters.count > 6 && chillType != "Tap Here to Search!"){
                chillType = chillType.lowercaseString
                chillType = chillType.stringByReplacingOccurrencesOfString("&chill", withString: "")
                query.whereKey("type", containsString:chillType)
            }
            query.addDescendingOrder("createdAt")

            
            query.findObjectsInBackgroundWithBlock {
                (objects: [PFObject]?, error: NSError?) -> Void in
                
                if error == nil {
                    print("no error getting chills")
                    // Do something with the found objects
                    if let objects = objects as [PFObject]! {
                        self.chillArray = []
                        for chillDictionary in objects {
                            
                            let chill = Chill.parseDictionaryIntoChill(chillDictionary)
                            self.chillArray.append(chill)
                        }
                        self.chillTableView.reloadData()
                        self.refreshControl.endRefreshing()
                    }
                    if self.chillArray.count < 1 {
                        dispatch_async(dispatch_get_main_queue(),{
                            self.nobodyLabel.text = "Nobody near you is chilling :(\nTap the snowflake tab at the bottom of the screen to be the first! :)"
                        })
                    }
                } else {
                    print("GET CHILL ERROR: \(error!)")
                    let alert = UIAlertController(title: "Oops!", message: "&Chill couldn't load any chills. Please make sure you're connected to the internet and have enabled access to your location under Settings > &Chill > Location.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)

                    // Log details of the failure
                    self.refreshControl.endRefreshing()
                }
            }
        }
    }
    
    /**
     * Updates and stores the user's current GeoLocation
     */
    func updateUserLocation(){
        if(PFUser.currentUser() != nil){
            PFGeoPoint.geoPointForCurrentLocationInBackground {
                (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
                if error == nil {
                    print("Get geo point")
                    // do something with the new geoPoint
                    PFUser.currentUser()?.setObject(geoPoint!, forKey: "location")
                    PFUser.currentUser()?.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                        print("Save geopoint")
                        if(error == nil){
                            print("No error saving geopoint")
                            self.getChills()
                            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "FirstTime")
                            NSUserDefaults.standardUserDefaults().synchronize()
                        }else{
                            print("Error saving user: \(error)")
                            let alert = UIAlertController(title: "Oops!", message: "&Chill couldn't save your location. Please make sure you're connected to the internet and have enabled access to your location under Settings > &Chill > Location.", preferredStyle: UIAlertControllerStyle.Alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                    })
                }else{
                    print("\(error)")
                    let alert = UIAlertController(title: "Oops!", message: "&Chill couldn't save your location. Please make sure you're connected to the internet and have enabled access to your location under Settings > &Chill > Location.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    //MARK: - Getting Suggestions from the Backend
    
    func getSuggestions(){
        let query = PFQuery(className:"Suggestion")
    
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                
                // Do something with the found objects
                if let objects = objects as [PFObject]!  {
                    self.suggestionArray = [[String:String]]()
                    for suggestionObject in objects {
                        let suggestionDictionary : [String:String] = ["type":suggestionObject["type"] as! String, "color":suggestionObject["color"] as! String]
                        self.suggestionArray.append(suggestionDictionary)
                    }
                    self.suggestionTableView.reloadData()
                    
                }
            } else {
                // Log details of the failure
                print("Error: \(error!)")
            }
        }

    }
    
    func parseSuggestionColor(suggestion : [String:String]) -> UIColor {
        let colorName = suggestion["color"]
        if(colorName == "Blue"){
            return UIColor.suggestionBlue()
        }else if(colorName == "Red"){
            return UIColor.suggestionRed()
        }else if(colorName == "Yellow"){
            return UIColor.suggestionYellow()
        }else if(colorName == "Green"){
            return UIColor.suggestionGreen()
        }else if(colorName == "Black"){
            return UIColor.suggestionBlack()
        }else{
            return UIColor.suggestionBlack()
        }
    }
    
    //MARK: - TextField Methods
    func textFieldShouldReturn(textField: UITextField) -> Bool {
//        textField.text = textField.text!.componentsSeparatedByCharactersInSet(NSCharacterSet.letterCharacterSet().invertedSet).joinWithSeparator("")
        if(blankTextField.isFirstResponder()){
            var blankText = blankTextField.text
            blankText = blankText!.stringByReplacingOccurrencesOfString(" ", withString: "")
            blankText = blankText!.stringByReplacingOccurrencesOfString("&", withString: "")
            blankText = blankText!.stringByReplacingOccurrencesOfString("Chill", withString: "")
            blankTextField.text = "\(blankText!)&Chill"
            textField.resignFirstResponder()
            getChills()
            suggestionTableView.alpha = 0
        }
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if(NSUserDefaults.standardUserDefaults().objectForKey("TapForChill") == nil){
            NSUserDefaults.standardUserDefaults().setObject(true, forKey: "TapForChill")
            blankTextField.text = ""
        }
        suggestionTableView.alpha = 1
        var blankText = textField.text
        blankText = blankText!.stringByReplacingOccurrencesOfString("&Chill", withString: "")
        textField.text = blankText
    }
    

    //MARK: - Table Views
    
    let chillTableView = UITableView()
    let suggestionTableView = UITableView()
    
    func addTableViews(){
        chillTableView.frame = CGRectMake(0, CGRectGetMaxY(bannerBackground.frame), view.frame.width, view.frame.height - bannerBackground.frame.height - 49)
        chillTableView.delegate = self
        chillTableView.dataSource = self
        chillTableView.registerClass(ChillTableViewCell.self, forCellReuseIdentifier: "ChillCell")
        chillTableView.separatorStyle = .None
        chillTableView.rowHeight = UITableViewAutomaticDimension
        chillTableView.estimatedRowHeight = 160.0
        chillTableView.backgroundColor = UIColor(red: 236.0/255.0, green: 240.0/255.0, blue: 241.0/255.0, alpha: 1.0)
        view.addSubview(chillTableView)
        view.sendSubviewToBack(chillTableView)
        
        suggestionTableView.frame = CGRectMake(0, CGRectGetMaxY(bannerBackground.frame), view.frame.width, view.frame.height)
        suggestionTableView.delegate = self
        suggestionTableView.backgroundColor = UIColor.backgroundGray()
        suggestionTableView.dataSource = self
        suggestionTableView.separatorStyle = .None
        suggestionTableView.alpha = 0
        view.addSubview(suggestionTableView)

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
        
        if(tableView == chillTableView){    //Settings for the Nearby Chill Table View
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
        }else{  //Settings for the Suggestion Table View
            let cell : UITableViewCell = UITableViewCell()
            let currentSuggestion = suggestionArray[indexPath.row]
            cell.backgroundColor = UIColor.backgroundGray()

            let suggestionLabel = UILabel()
            suggestionLabel.frame = CGRectMake(0, 5, view.frame.width, suggestionTableCellHeight - 10)
            suggestionLabel.textAlignment = .Center
            suggestionLabel.backgroundColor = UIColor.whiteColor()
            suggestionLabel.textColor = UIColor.icyBlue()
            suggestionLabel.layer.cornerRadius = 8.0
            suggestionLabel.layer.masksToBounds = true
            suggestionLabel.text = "\(currentSuggestion["type"]!)&"
            suggestionLabel.font = UIFont.systemFontOfSize(17.0)
            suggestionLabel.adjustsFontSizeToFitWidth = true
            cell.addSubview(suggestionLabel)
            return cell
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(tableView == chillTableView){    //chill table view height
            return chillTableCellHeight
        }else{  //Suggestion table view height
            return suggestionTableCellHeight
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == chillTableView){    //chill table view count
            if(chillArray.count > 0){
                nobodyChillingView.alpha = 0.0
            }else{
                nobodyChillingView.alpha = 1.0
            }
            return chillArray.count
        }else{  //suggestion table view count
            return suggestionArray.count
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        blankTextField.resignFirstResponder()
        suggestionTableView.alpha = 0
        if(tableView == chillTableView){    //chill table view
            let cell :ChillTableViewCell = tableView.cellForRowAtIndexPath(indexPath) as! ChillTableViewCell
            cell.flipCell()
        }else{  //suggestion table view
            let currentSuggestion = suggestionArray[indexPath.row]
            blankTextField.text = "\(currentSuggestion["type"]!)&Chill"
            getChills()
        }
        
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
            self.getChills()
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




