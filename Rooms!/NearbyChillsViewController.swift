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
    let suggestionTableCellHeight : CGFloat = 75.0
    
    //MARK: - UI
    let bannerBackground : UIView = UIView()
    let blankTextField : UITextField = UITextField()
    
    
    //MARK: - View Methods
    
    override func viewDidLoad() {
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.topItem?.title = "Add an Activity"
        if(NSUserDefaults.standardUserDefaults().objectForKey("FirstTime") != nil){
            let firstTime : Bool = NSUserDefaults.standardUserDefaults().objectForKey("FirstTime") as! Bool
            if(!firstTime && PFUser.currentUser() != nil){
                getChills()
            }
        }
        self.tabBarController?.tabBar.hidden = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        //If there's no user logged in, send them to the Landing Screen
        if(PFUser.currentUser() == nil || FBSDKAccessToken.currentAccessToken() == nil){
            performSegueWithIdentifier("showLoginSegue", sender: self)
        }else{
            //If there is a user and it's their first time using the app, tell them they need to allow us to access their location
            if(NSUserDefaults.standardUserDefaults().objectForKey("FirstTime") != nil){
                let firstTime : Bool = NSUserDefaults.standardUserDefaults().objectForKey("FirstTime") as! Bool
                if(firstTime){
                    let alert = UIAlertController(title: "Allow &Chill to Access Your Location", message: "&Chill needs to use your location in order to find activities near you. Please make sure you're connected to the internet and have enabled access to your location under Settings > &Chill > Location.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:
                        { action in
                            switch action.style{
                            default:
                                self.updateUserLocation()
                            }
                        }
                    ))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
    }
    

    
    
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
        blankTextField.returnKeyType = UIReturnKeyType.Done
        blankTextField.delegate = self
        blankTextField.tintColor = UIColor.whiteColor()
        view.addSubview(blankTextField)

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
                        
                        let chill = Chill.parseDictionaryIntoChill(chillDictionary)
                        self.chillArray.append(chill)
                    }
                    self.chillTableView.reloadData()
                    self.refreshControl.endRefreshing()
                }
            } else {
                let alert = UIAlertController(title: "Oops!", message: "&Chill couldn't save your location. Please make sure you're connected to the internet and have enabled access to your location under Settings > &Chill > Location.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)

                // Log details of the failure
                print("Error: \(error!)")
                self.refreshControl.endRefreshing()
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
            let currentChill : Chill = chillArray[indexPath.row]
            cell.setUpWithChill(currentChill)
            cell.detailsButton.addTarget(self, action: "showDetails:", forControlEvents: .TouchUpInside)
            cell.reportButton.addTarget(self, action: "reportChill:", forControlEvents: .TouchUpInside)
            let swipeLeftRecognizer = UISwipeGestureRecognizer(target: self, action: "removeChill:")
            swipeLeftRecognizer.direction = .Left
            cell.tag = indexPath.row
            cell.addGestureRecognizer(swipeLeftRecognizer)
            
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
    
    //MARK : - Navigation
    
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




