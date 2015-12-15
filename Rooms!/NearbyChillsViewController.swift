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

class NearbyChillsViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource, EnableLocationViewDelegate
{
    
    //Chill Variables
    var chillArray : [Chill] = []
    let chillTableCellHeight : CGFloat = 100.0
    
    //Suggestion Variables
    var suggestionArray = [[String:String]]()
    let suggestionTableCellHeight : CGFloat = 75.0
    
    //MARK: - UI
    let enableLocationView = EnableLocationView()
    let bannerBackground : UIView = UIView()
    let blankTextField : UITextField = UITextField()
    
    
    //MARK: - View Methods
    
    override func viewDidLoad()
    {
        addMainUI()
        addTableViews()
        if(NSUserDefaults.standardUserDefaults().objectForKey("FirstTime") != nil){
            let firstTime : Bool = NSUserDefaults.standardUserDefaults().objectForKey("FirstTime") as! Bool
            if(!firstTime && PFUser.currentUser() != nil){
                updateUserLocation()
            }
        }
        getSuggestions()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.topItem?.title = "Add an Activity"
        if(NSUserDefaults.standardUserDefaults().objectForKey("FirstTime") != nil){
            let firstTime : Bool = NSUserDefaults.standardUserDefaults().objectForKey("FirstTime") as! Bool
            if(!firstTime && PFUser.currentUser() != nil){
                getChills()
            }
        }
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        self.enableLocationView.enableLocationViewDelegate = self
        
        //If there's no user logged in, send them to the Landing Screen
        if(PFUser.currentUser() == nil){
            performSegueWithIdentifier("showLoginSegue", sender: self)
        }else{
            //If there is a user and it's their first time using the app, tell them they need to allow us to access their location
            if(NSUserDefaults.standardUserDefaults().objectForKey("FirstTime") != nil){
                let firstTime : Bool = NSUserDefaults.standardUserDefaults().objectForKey("FirstTime") as! Bool
                if(firstTime)
                {
                    self.tabBarController?.tabBar.hidden = true
                    self.view.addSubview( self.enableLocationView )
                    
                    self.enableLocationView.addEnableLocationAnimation { _ in
                        self.enableLocationView.addAmbientAnimation()
                    }
                    
                    
                    
//                    let alert = UIAlertController(title: "Allow &Chill to Access Your Location", message: "&Chill needs to use your location in order to find activities near you. Please allow &Chill access to your location when prompted.", preferredStyle: UIAlertControllerStyle.Alert)
//                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:
//                        { action in
//                            switch action.style{
//                            default:
//                                self.updateUserLocation()
//                            }
//                        }
//                    ))
//                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    
    func allowButtonPressed(allowButton: UIButton)
    {
        self.tabBarController?.tabBar.hidden = false
        self.enableLocationView.removeAllAnimations()
        self.enableLocationView.removeFromSuperview()
        self.updateUserLocation()
    }
    

    
    
    func addMainUI(){
        bannerBackground.frame = CGRectMake(0, 0, view.frame.width, view.frame.height * 0.1)
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
        blankTextField.returnKeyType = UIReturnKeyType.Done
        blankTextField.delegate = self
        blankTextField.tintColor = UIColor.whiteColor()
        view.addSubview(blankTextField)

        enableLocationView.frame = CGRectMake( 0, 0, view.frame.width, view.frame.height )
    }
    

    
    //MARK: - Adding & Getting Chills from the Backend
    
    /**
     * Downloads nearby chills from the backend
     */
    func getChills(){
        let query = PFQuery(className:"Chill")
        let userLocation : PFGeoPoint = PFUser.currentUser()?.objectForKey("location") as! PFGeoPoint
        query.whereKey("location", nearGeoPoint: userLocation, withinMiles: 5.0)
        query.limit = 25

        var chillType : String = blankTextField.text!
        if(chillType.characters.count > 6){
            chillType = chillType.lowercaseString
            chillType = chillType.stringByReplacingOccurrencesOfString("&chill", withString: "")
            query.whereKey("type", containsString:chillType)
        }
        query.addDescendingOrder("createdAt")

        
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                
                // Do something with the found objects
                if let objects = objects as [PFObject]! {
                    self.chillArray = []
                    for chillDictionary in objects {
                        
                        let chill = Chill(idString: chillDictionary.objectId!,
                            typeString: String(chillDictionary["type"]),
                            detailsString: String(chillDictionary["details"]),
                            hostString: String(chillDictionary["host"]),
                            profileString:String(chillDictionary["profilePic"]),
                            chillerArray: chillDictionary["chillers"] as! [String])
                        self.chillArray.append(chill)
                    }
                    self.chillTableView.reloadData()
                    self.refreshControl.endRefreshing()
                }
            } else {
                // Log details of the failure
                print("Error: \(error!)")
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    /**
     *  Adds the current user to the chill's chillers
     */
    func joinChill(sender: UIButton){

        let currentChill : Chill = chillArray[sender.tag]
        let parseChill : PFObject = PFObject(withoutDataWithClassName: "Chill", objectId: currentChill.id)
        parseChill.addObject(PFUser.currentUser()?.objectForKey("facebookID") as! String, forKey: "chillers")
        parseChill.incrementKey("chillersCount")
        parseChill.saveInBackground()
        
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
                            let alert = UIAlertController(title: "Oops!", message: "&Chill couldn't save your location. Please make sure you're connected to the internet.", preferredStyle: UIAlertControllerStyle.Alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                    })
                }else{
                    print("\(error)")
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
            return UIColor.grayColor()
        }
    }
    
    //MARK: - TextField Methods
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.text = textField.text!.componentsSeparatedByCharactersInSet(NSCharacterSet.letterCharacterSet().invertedSet).joinWithSeparator("")
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
        chillTableView.backgroundColor = UIColor(red: 236.0/255.0, green: 240.0/255.0, blue: 241.0/255.0, alpha: 1.0)
        view.addSubview(chillTableView)
        view.sendSubviewToBack(chillTableView)
        
        suggestionTableView.frame = CGRectMake(0, CGRectGetMaxY(bannerBackground.frame), view.frame.width, suggestionTableCellHeight * 4)
        suggestionTableView.delegate = self
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
            cell.backgroundColor = UIColor(red: 236.0/255.0, green: 240.0/255.0, blue: 241.0/255.0, alpha: 1.0)
            cell.selectionStyle = .None
            cell.chillButton.addTarget(self, action: "joinChill:", forControlEvents: UIControlEvents.TouchUpInside)
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
        }else{  //Settings for the Suggestion Table View
            let cell : UITableViewCell = UITableViewCell()
            let currentSuggestion = suggestionArray[indexPath.row]

            let suggestionLabel = UILabel()
            suggestionLabel.frame = CGRectMake(0, 0, view.frame.width, suggestionTableCellHeight)
            suggestionLabel.textAlignment = .Center
            suggestionLabel.backgroundColor = parseSuggestionColor(currentSuggestion)
            suggestionLabel.textColor = UIColor.whiteColor()
            suggestionLabel.text = "\(currentSuggestion["type"]!)&"
            suggestionLabel.font = UIFont(name: "Helvetica", size: 40.0)
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
            return chillArray.count
        }else{  //suggestion table view count
            return suggestionArray.count
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        blankTextField.resignFirstResponder()
        if(tableView == chillTableView){    //chill table view
            let cell :ChillTableViewCell = tableView.cellForRowAtIndexPath(indexPath) as! ChillTableViewCell
            let currentChill : Chill = chillArray[indexPath.row]
            cell.flipCell(currentChill)
        }else{  //suggestion table view
            let currentSuggestion = suggestionArray[indexPath.row]
            blankTextField.text = "\(currentSuggestion["type"]!)&Chill"
            getChills()
            suggestionTableView.alpha = 0
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
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




