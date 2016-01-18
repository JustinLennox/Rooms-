//
//  AddChillViewController.swift
//  Rooms!
//
//  Created by Justin Lennox on 11/15/15.
//  Copyright © 2015 Justin Lennox. All rights reserved.
//

import UIKit
import Parse
import CoreLocation

class AddChillViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var delegate: addChillDelegate! = nil
    
    //MARK: - UI
    let addChillTitle : UITextField = UITextField()
    let doneAddingChillButton : UIButton = UIButton(type: UIButtonType.System)
    let backArrow = UIButton(type: .System)
    let nextArrow = UIButton(type: .System)
    let scrollView : TPKeyboardAvoidingScrollView = TPKeyboardAvoidingScrollView()
    
    //MARK: - Public Overview Cell
    let frontContainerView = UIView()
    let profileImage = UIImageView()
    let publicChillOverview : UITextView = UITextView()
    let chillTypeLabel = UILabel()
    let publicOverviewPlaceholderText = "Public Overview (e.g. Main Description)"
    
    //MARK: - Public Details Cell
    let publicDetailsContainerView = UIView()
    let publicDetailsLabel = UILabel()
    let publicChillDetails : UITextView = UITextView()
    let publicDetailsPlaceholderText = "Public Details (e.g. Time, Likes/Dislikes)"

    
    //MARK: - Private Cell
    let backContainerView = UIView()
    let chillLabel = UILabel()
    let privateChillDetails = UITextView()
    let privatePlaceholderText = "Private Details (e.g. Address/Location, Phone Number)"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clearColor()
        addUI()
        addFrontCellUI()
        addPublicDetailsUI()
        addBackCellUI()
        addFacebookUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        showStepOne()
        getFacebookFriends()
        invitedFriends = []
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if(NSUserDefaults.standardUserDefaults().objectForKey("AgreedToRules") == nil || NSUserDefaults.standardUserDefaults().objectForKey("AgreedToRules") as! String != "YES"){
            NSUserDefaults.standardUserDefaults().setObject("NO", forKey: "AgreedToRules")
            performSegueWithIdentifier("showRulesSegue", sender: self)
        }
    }
    
    //MARK: - Facebook
    
    let facebookContainerView = UIView()
    let facebookLabel = UILabel()
    let facebookTableView = UITableView()
    var invitedFriends : [String] = []
    var friendsArray : [AnyObject] = []
    var currentChillType: String = ""
    
    func addFacebookUI(){
        
        facebookContainerView.frame = CGRectMake(view.frame.width * 0.025, CGRectGetMidY(view.frame) - 200, view.frame.width * 0.95, 300)
        facebookContainerView.layer.cornerRadius = 8.0
        facebookContainerView.layer.masksToBounds = true
        view.addSubview(facebookContainerView)
        
        facebookLabel.frame = CGRectMake(0, 0, facebookContainerView.frame.width, 50)
        facebookLabel.text = "Chill With Friends"
        facebookLabel.backgroundColor = UIColor(red: 59.0/255.0, green: 89.0/255.0, blue: 152.0/255.0, alpha: 1.0)
        facebookLabel.textAlignment = .Center
        facebookLabel.textColor = UIColor.whiteColor()
        facebookLabel.font = UIFont.systemFontOfSize(20.0)
        facebookContainerView.addSubview(facebookLabel)
        
        facebookTableView.frame = CGRectMake(0, 50, facebookContainerView.frame.width, 250)
        facebookTableView.backgroundColor = UIColor.backgroundGray()
        facebookTableView.dataSource = self
        facebookTableView.delegate = self
        facebookTableView.layer.borderColor = UIColor.whiteColor().CGColor
        facebookTableView.layer.borderWidth = 1.0
        facebookTableView.allowsMultipleSelection = true
        facebookContainerView.addSubview(facebookTableView)
    }
    
    func addUI(){
        
        scrollView.frame = CGRectMake(0, 0, view.frame.width, view.frame.height)
        view.addSubview(scrollView)
        
        addChillTitle.frame = CGRectMake(view.frame.width * 0.025 + 45, CGRectGetMidY(view.frame) - 200, view.frame.width * 0.95 - 45, 50)
        addChillTitle.backgroundColor = UIColor.whiteColor()
        addChillTitle.textColor = UIColor.icyBlue()
        addChillTitle.layer.cornerRadius = 8.0
        addChillTitle.layer.masksToBounds = true
        addChillTitle.clearButtonMode = .WhileEditing
        addChillTitle.textAlignment = NSTextAlignment.Center
        addChillTitle.placeholder = "Type of Chill"
        addChillTitle.delegate = self
        addChillTitle.font = UIFont.systemFontOfSize(25.0)
        addChillTitle.tintColor = UIColor.icyBlue()
        addChillTitle.returnKeyType = .Done
        scrollView.addSubview(addChillTitle)
        
        backArrow.frame = CGRectMake(view.frame.width * 0.025 + 5, CGRectGetMidY(view.frame) - 190, 30, 30)
        backArrow.contentMode = .ScaleAspectFit
        backArrow.imageView?.contentMode = .ScaleAspectFit
        backArrow.setBackgroundImage(UIImage(named: "backArrow.png"), forState: .Normal)
        backArrow.addTarget(self, action: "backPressed", forControlEvents: .TouchUpInside)
        view.addSubview(backArrow)
        
        doneAddingChillButton.frame = CGRectMake(view.frame.width/2 - 25, CGRectGetMidY(view.frame) + 160, 50, 50)
        doneAddingChillButton.setBackgroundImage(UIImage(named: "rightArrow.png"), forState: UIControlState.Normal)
        doneAddingChillButton.addTarget(self, action: "doneAddingChill", forControlEvents: UIControlEvents.TouchUpInside)
//        doneAddingChillButton.layer.borderWidth = 1.0
//        doneAddingChillButton.layer.borderColor = UIColor.whiteColor().CGColor
//        doneAddingChillButton.layer.cornerRadius = 8.0
//        doneAddingChillButton.layer.masksToBounds = true
        scrollView.addSubview(doneAddingChillButton)
        
        nextArrow.frame = doneAddingChillButton.frame
        nextArrow.contentMode = .ScaleAspectFit
        nextArrow.imageView?.contentMode = .ScaleAspectFit
        nextArrow.setBackgroundImage(UIImage(named: "rightArrow.png"), forState: .Normal)
        nextArrow.addTarget(self, action: "showStepTwo", forControlEvents: .TouchUpInside)
        scrollView.addSubview(nextArrow)
    
    }
    
    func showStepOne(){
        nextArrow.alpha = 1.0
        addChillTitle.alpha = 1.0
        frontContainerView.alpha = 1.0
        publicDetailsContainerView.alpha = 1.0
        backContainerView.alpha = 1.0
        facebookContainerView.alpha = 0.0
        doneAddingChillButton.alpha = 0.0
    }
    
    func showStepTwo(){
        nextArrow.alpha = 0.0
        addChillTitle.alpha = 0.0
        frontContainerView.alpha = 0.0
        publicDetailsContainerView.alpha = 0.0
        backContainerView.alpha = 0.0
        facebookContainerView.alpha = 1.0
        doneAddingChillButton.alpha = 1.0
        view.bringSubviewToFront(backArrow)
    }

    /**
    *   This is where you can add/change/play with the UI for adding chills!
    */
    func addFrontCellUI(){
        
        frontContainerView.frame = CGRectMake(view.frame.width * 0.025, CGRectGetMaxY(addChillTitle.frame) + 10, view.frame.width * 0.95, 90)
        frontContainerView.backgroundColor = UIColor.whiteColor()
        frontContainerView.layer.cornerRadius = 8.0
        frontContainerView.layer.masksToBounds = true
        scrollView.addSubview(frontContainerView)
        
        profileImage.image = UIImage(named: "prof.jpg")
        if let accessToken = FBSDKAccessToken.currentAccessToken() {
            let profilePictureURL = NSURL(string: "https://graph.facebook.com/me/picture?width=200&height=200&return_ssl_resources=1&access_token=\(accessToken.tokenString)")
            profileImage.sd_setImageWithURL(profilePictureURL)
        }
        profileImage.frame = CGRectMake(0, 0, frontContainerView.frame.height, frontContainerView.frame.height)
        profileImage.layer.masksToBounds = true
        frontContainerView.addSubview(profileImage)
        
        publicChillOverview.frame = CGRectMake(profileImage.frame.width + 10, 5, frontContainerView.frame.width - profileImage.frame.width - 20, frontContainerView.frame.height * 0.8 - 5)
        publicChillOverview.layer.masksToBounds = true
        publicChillOverview.backgroundColor = UIColor.whiteColor()
        publicChillOverview.delegate = self
        publicChillOverview.returnKeyType = .Done
        publicChillOverview.text = publicOverviewPlaceholderText
        publicChillOverview.textColor = UIColor.flatGray()
        publicChillOverview.textAlignment = NSTextAlignment.Center
        publicChillOverview.font = UIFont.systemFontOfSize(14.0)
        frontContainerView.addSubview(publicChillOverview)
        
        chillTypeLabel.frame = CGRectMake(profileImage.frame.width + 10, publicChillOverview.frame.height + 5, frontContainerView.frame.width - profileImage.frame.width - 20, frontContainerView.frame.height * 0.2)
        chillTypeLabel.text = ""
        chillTypeLabel.textAlignment = .Right
        chillTypeLabel.textColor = UIColor.icyBlue()
        chillTypeLabel.font = UIFont.systemFontOfSize(14.0)
        frontContainerView.addSubview(chillTypeLabel)
        
    }
    
    func addPublicDetailsUI(){
        
        publicDetailsContainerView.frame = CGRectMake(view.frame.width * 0.025, CGRectGetMaxY(frontContainerView.frame) + 10, view.frame.width * 0.95, 90)
        publicDetailsContainerView.backgroundColor = UIColor.whiteColor()
        publicDetailsContainerView.layer.cornerRadius = 8.0
        publicDetailsContainerView.layer.masksToBounds = true
        scrollView.addSubview(publicDetailsContainerView)
        
        publicDetailsLabel.frame = CGRectMake(0, 0, publicDetailsContainerView.frame.height, publicDetailsContainerView.frame.height)
        publicDetailsLabel.text = "Public\nDetails"
        publicDetailsLabel.numberOfLines = 2
        publicDetailsLabel.textColor = UIColor.whiteColor()
        publicDetailsLabel.textAlignment = .Center
        publicDetailsLabel.backgroundColor = UIColor.suggestionBlack()
        publicDetailsContainerView.addSubview(publicDetailsLabel)
        
        publicChillDetails.frame = CGRectMake(profileImage.frame.width + 10, 5, frontContainerView.frame.width - profileImage.frame.width - 20, frontContainerView.frame.height * 0.8 - 5)
        publicChillDetails.layer.masksToBounds = true
        publicChillDetails.backgroundColor = UIColor.whiteColor()
        publicChillDetails.delegate = self
        publicChillDetails.returnKeyType = .Done
        publicChillDetails.text = publicDetailsPlaceholderText
        publicChillDetails.textColor = UIColor.flatGray()
        publicChillDetails.textAlignment = NSTextAlignment.Center
        publicChillDetails.font = UIFont.systemFontOfSize(14.0)
        publicDetailsContainerView.addSubview(publicChillDetails)
        
    }
    
    func addBackCellUI(){
        
        backContainerView.frame = CGRectMake(view.frame.width * 0.025, CGRectGetMaxY(publicDetailsContainerView.frame) + 10, view.frame.width * 0.95, 90)
        backContainerView.backgroundColor = UIColor.whiteColor()
        backContainerView.layer.cornerRadius = 8.0
        backContainerView.layer.masksToBounds = true
        scrollView.addSubview(backContainerView)
        
        chillLabel.frame = CGRectMake(0, 0, backContainerView.frame.height, backContainerView.frame.height)
        chillLabel.text = "Private\nDetails"
        chillLabel.numberOfLines = 2
        chillLabel.textColor = UIColor.whiteColor()
        chillLabel.textAlignment = .Center
        chillLabel.backgroundColor = UIColor.suggestionBlack()
        backContainerView.addSubview(chillLabel)
        
        privateChillDetails.frame = CGRectMake(chillLabel.frame.width + 10, 5, backContainerView.frame.width - profileImage.frame.width - 20, backContainerView.frame.height * 0.8 - 5)
        privateChillDetails.layer.masksToBounds = true
        privateChillDetails.backgroundColor = UIColor.whiteColor()
        privateChillDetails.delegate = self
        privateChillDetails.text = privatePlaceholderText
        privateChillDetails.returnKeyType = .Done
        privateChillDetails.textColor = UIColor.flatGray()
        privateChillDetails.textAlignment = NSTextAlignment.Center
        privateChillDetails.font = UIFont.systemFontOfSize(14.0)
        backContainerView.addSubview(privateChillDetails)
        

        
    }
    
    /**
    * Checks to make sure we've met the conditions to add the chill
    */
     
    func doneAddingChill(){
        if(publicChillOverview.text != publicOverviewPlaceholderText &&
            publicChillOverview.text.characters.count >= 1 &&
            PFUser.currentUser() != nil && PFUser.currentUser()?.objectForKey("facebookID") != nil
            && publicChillOverview.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) != ""
            && publicOverviewPlaceholderText.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) != ""){//ESA WAS HERE
            addChill()
        }else{
            let noOverviewAlert = UIAlertController(title: "Sorry!", message: "You must add a Public Overview for your Chill.", preferredStyle: UIAlertControllerStyle.Alert)
            noOverviewAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(noOverviewAlert, animated: true, completion: nil)
        }
    }
    
    /**
     * Adds a new 'Chill' to the backend and then hides the Add-Chill views
     */
    func addChill(){
        doneAddingChillButton.enabled = false
        if let currentUser = PFUser.currentUser(){
            let chill = PFObject(className: "Chill")
            var chillType = addChillTitle.text!.lowercaseString
            chillType = chillType.stringByReplacingOccurrencesOfString("&", withString: "")
            chillType = chillType.stringByReplacingOccurrencesOfString("chill", withString: "")
            chillType = chillType.stringByReplacingOccurrencesOfString(" ", withString: "")
            chill["type"] = chillType
            currentChillType = chillType
            chill["reportCount"] = 0
            chill["overview"] = publicChillOverview.text
            chill["hostName"] = PFUser.currentUser()?.objectForKey("name") == nil ? "Guest" : PFUser.currentUser()?.objectForKey("name")
            if(publicChillDetails.text == publicDetailsPlaceholderText){
                chill["details"] = "❄️"
            }else{
                chill["details"] = publicChillDetails.text
            }
            if(privateChillDetails.text == privatePlaceholderText){
                chill["privateDetails"] = "❄️"
            }else{
                chill["privateDetails"] = privateChillDetails.text
            }
    
            chill["host"] = PFUser.currentUser()?.objectForKey("facebookID")
            chill["chillers"] = []
            chill["requestedChillers"] = []
            chill["invitedChillers"] = invitedFriends
            chill["chillersCount"] = 0
            PFGeoPoint.geoPointForCurrentLocationInBackground {
                (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
                if error == nil {
                    print("\(geoPoint)")
                    // do something with the new geoPoint
                    chill["location"] = geoPoint
                    chill.saveInBackgroundWithBlock({ (success: Bool, error:NSError?) -> Void in
                        if(error != nil){
                            let failureAlert = UIAlertController(title: "Sorry!", message: "We couldn't save your Chill. Make sure you have an internet connection and try again!", preferredStyle: UIAlertControllerStyle.Alert)
                            failureAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                            self.presentViewController(failureAlert, animated: true, completion: nil)

                        }else{
                            self.sendInvitePushes()
                            self.createChat(chill.objectId!)
                        }
                    })

                }else{
                    let locationAlert = UIAlertController(title: "Sorry!", message: "We couldn't get your location. Make sure you've enabled Location tracking under Settings > &Chill > Location.", preferredStyle: UIAlertControllerStyle.Alert)
                    locationAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(locationAlert, animated: true, completion: nil)

                }
            }
        }else{
            let loggedInAlert = UIAlertController(title: "Sorry!", message: "You have to be logged in to post a Chill! Make sure that you are logged in and connected to the internet.", preferredStyle: UIAlertControllerStyle.Alert)
            loggedInAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(loggedInAlert, animated: true, completion: nil)
        }
        
    }
    
    func sendInvitePushes(){
        for facebookID in invitedFriends {
            let pushQuery = PFInstallation.query()
            pushQuery!.whereKey("facebookID", equalTo: facebookID)
            
            // Send push notification to query
            let push = PFPush()
            let data = [
                "badge" : "Increment",
            ]
            push.setData(data)
            push.setQuery(pushQuery) // Set our Installation query
            push.setMessage("\(PFUser.currentUser()!.objectForKey("name")!) has invited you to \(currentChillType)&chill.")
            push.sendPushInBackground()
        }
    }
    
    func createChat(chillID: String){
        let chat = PFObject(className: "Message")
        chat["Chill"] = chillID
        chat["messageArray"] = []
        chat["participants"] = [PFUser.currentUser()?.objectForKey("facebookID") as! String]
        chat.saveInBackground()
        doneAddingChillButton.enabled = true
        self.dismissViewControllerAnimated(true, completion: nil)
        self.delegate!.finishedAddingChill()
        

    }
    
    func backPressed(){
        if(nextArrow.alpha == 0.0){
            showStepOne()
        }else{
            self.dismissViewControllerAnimated(true, completion: nil)
            self.delegate!.finishedAddingChill()
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        addChillTitle.resignFirstResponder()
        publicChillDetails.resignFirstResponder()
        publicChillOverview.resignFirstResponder()
        privateChillDetails.resignFirstResponder()
    }
    
    //MARK: - Text Field/View Delegate
    
    func textViewDidBeginEditing(textView: UITextView) {
        if(textView == publicChillOverview && publicChillOverview.text == publicOverviewPlaceholderText){
            publicChillOverview.text = ""
            publicChillOverview.textColor = UIColor.blackColor()
        }else if(textView == publicChillDetails && publicChillDetails.text == publicDetailsPlaceholderText){
            publicChillDetails.text = ""
            publicChillDetails.textColor = UIColor.blackColor()
        }else if(textView == privateChillDetails && privateChillDetails.text == privatePlaceholderText){
            privateChillDetails.text = ""
            privateChillDetails.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if(textView == publicChillOverview && publicChillOverview.text == ""){
            publicChillOverview.text = publicOverviewPlaceholderText
            publicChillOverview.textColor = UIColor.flatGray()
        }else if(textView == publicChillDetails && publicChillDetails.text == ""){
            publicChillDetails.text = publicDetailsPlaceholderText
            publicChillDetails.textColor = UIColor.flatGray()
        }else if(textView == privateChillDetails && privateChillDetails.text == ""){
            privateChillDetails.text = privatePlaceholderText
            privateChillDetails.textColor = UIColor.flatGray()
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if(textField == addChillTitle){
            var blankText = textField.text
            blankText = blankText!.stringByReplacingOccurrencesOfString("&Chill", withString: "")
            textField.text = blankText
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if(textField == addChillTitle){
            if let chillTitle = addChillTitle.text {
                var newChillTitle = chillTitle
                newChillTitle = newChillTitle.stringByReplacingOccurrencesOfString("&", withString: "")
                newChillTitle = newChillTitle.stringByReplacingOccurrencesOfString("chill", withString: "")
                newChillTitle = newChillTitle.stringByReplacingOccurrencesOfString("Chill", withString: "")
                newChillTitle = newChillTitle.stringByReplacingOccurrencesOfString(" ", withString: "")
                newChillTitle = "\(newChillTitle)&Chill"
                let chillTypeText = newChillTitle.stringByReplacingOccurrencesOfString("&Chill", withString: "")
                chillTypeLabel.text = "\(chillTypeText.lowercaseString)&"

                addChillTitle.text = newChillTitle
            }
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n"){
            textView.resignFirstResponder()
            return false
        }else{
            return textView.text.characters.count + (text.characters.count - range.length) <= 100;
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if(textField == addChillTitle){
            let currentCharacterCount = textField.text?.characters.count ?? 0
            if (range.length + range.location > currentCharacterCount){
                return false
            }
            let newLength = currentCharacterCount + string.characters.count - range.length
            return newLength <= 15
        }else{
            return true
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        var textViewText = textView.text
        textViewText = textViewText.stringByReplacingOccurrencesOfString("\n", withString: "")
        textView.text = textViewText
    }
    
    func addGuides(){
        let xMid = UIView(frame: CGRectMake(CGRectGetMidX(self.view.frame), 0, 1, self.view.frame.height))
        xMid.backgroundColor = UIColor.blueColor()
        view.addSubview(xMid)
    }
    
    //MARK: - Table View Methods
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "cell")
        let currentFBID = friendsArray[indexPath.row].objectForKey("id") as! String
        if(invitedFriends.contains(currentFBID)){
            cell.backgroundColor = UIColor.icyBlue()
        }else{
            cell.backgroundColor = UIColor.backgroundGray()
        }
        cell.selectionStyle = .None
        
        let nameLabel = UILabel(frame: CGRectMake(40, 0, cell.frame.width - 30, cell.frame.height))
        nameLabel.text = friendsArray[indexPath.row].objectForKey("name") as? String
        nameLabel.backgroundColor = UIColor.clearColor()
        cell.addSubview(nameLabel)
        
        let profileImage = UIImageView(frame: CGRectMake(5, 5, 30, 30))
        profileImage.layer.cornerRadius = profileImage.frame.width/2
        profileImage.layer.masksToBounds = true
        let profilePictureURL = NSURL(string: "https://graph.facebook.com/\(friendsArray[indexPath.row].objectForKey("id") as! String)/picture?type=square&width=60&height=60&return_ssl_resources=1")
        profileImage.sd_setImageWithURL(profilePictureURL)
        
        cell.addSubview(profileImage)
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendsArray.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.backgroundColor = UIColor.icyBlue()
        invitedFriends.append(friendsArray[indexPath.row].objectForKey("id") as! String)
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.backgroundColor = UIColor.backgroundGray()
        for(var i = 0; i < invitedFriends.count; i++){
            if(invitedFriends[i] == friendsArray[indexPath.row].objectForKey("id") as! String){
                invitedFriends.removeAtIndex(i)
            }
        }
    }
    
    func getFacebookFriends() {
        let fbRequest = FBSDKGraphRequest(graphPath:"/me/friends", parameters: nil);
        print(fbRequest)
        fbRequest.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
            
            if error == nil {
                let facebookFriendArray : NSArray = result.objectForKey("data") as! NSArray
                for(index, friend) in facebookFriendArray.enumerate(){
                    self.friendsArray.append(friend)
                }
                self.facebookTableView.reloadData()
            } else {
                print("Error Getting Friends \(error)");
                
            }
        }
    }

    
}

protocol addChillDelegate {
    func finishedAddingChill()
}
