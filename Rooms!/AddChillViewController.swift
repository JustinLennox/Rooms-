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

class AddChillViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, CLLocationManagerDelegate {
    
    var delegate: addChillDelegate! = nil
    
    //MARK: - UI
    let addChillTitle : UITextField = UITextField()
    let doneAddingChillButton : UIButton = UIButton(type: UIButtonType.System)
    let backArrow = UIButton(type: .System)
    let scrollView : TPKeyboardAvoidingScrollView = TPKeyboardAvoidingScrollView()
    
    //MARK - Public Overview Cell
    let frontContainerView = UIView()
    let profileImage = UIImageView()
    let publicChillOverview : UITextView = UITextView()
    let chillTypeLabel = UILabel()
    let publicOverviewPlaceholderText = "Public Overview (e.g. Main Description)"
    
    //MARK - Public Details Cell
    let publicDetailsContainerView = UIView()
    let publicDetailsLabel = UILabel()
    let publicChillDetails : UITextView = UITextView()
    let publicDetailsPlaceholderText = "Public Details (e.g. Time, Likes/Dislikes)"

    
    //MARK - Private Cell
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
    }
    
    func addUI(){
        
        scrollView.frame = CGRectMake(0, 0, view.frame.width, view.frame.height)
        view.addSubview(scrollView)
        
        addChillTitle.frame = CGRectMake(view.frame.width * 0.025, CGRectGetMidY(view.frame) - 200, view.frame.width * 0.95, 50)
        addChillTitle.backgroundColor = UIColor.icyBlue()
        addChillTitle.textColor = UIColor.whiteColor()
        addChillTitle.layer.cornerRadius = 8.0
        addChillTitle.layer.masksToBounds = true
        addChillTitle.clearButtonMode = .WhileEditing
        addChillTitle.textAlignment = NSTextAlignment.Center
        addChillTitle.placeholder = "Type of Chill"
        addChillTitle.delegate = self
        addChillTitle.font = UIFont(name: "Helvetica-Bold", size: 25.0)
        addChillTitle.tintColor = UIColor.whiteColor()
        addChillTitle.returnKeyType = .Done
        scrollView.addSubview(addChillTitle)
        
        backArrow.frame = CGRectMake(CGRectGetMinX(addChillTitle.frame), CGRectGetMinY(addChillTitle.frame) - 15, 30, 30)
        backArrow.contentMode = .ScaleAspectFit
        backArrow.imageView?.contentMode = .ScaleAspectFit
        backArrow.setBackgroundImage(UIImage(named: "backArrow.png"), forState: .Normal)
        backArrow.addTarget(self, action: "backPressed", forControlEvents: .TouchUpInside)
        view.addSubview(backArrow)
        
        doneAddingChillButton.frame = CGRectMake(view.frame.width/2 - 25, CGRectGetMidY(view.frame) + 160, 50, 50)
        doneAddingChillButton.setBackgroundImage(UIImage(named: "ChillSnowflakeSmall.png"), forState: UIControlState.Normal)
        doneAddingChillButton.addTarget(self, action: "doneAddingChill", forControlEvents: UIControlEvents.TouchUpInside)
        scrollView.addSubview(doneAddingChillButton)
    
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
        publicDetailsLabel.backgroundColor = UIColor.icyBlue()
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
        chillLabel.backgroundColor = UIColor.icyBlue()
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
        if(publicChillOverview.text != publicOverviewPlaceholderText && publicChillOverview.text.characters.count >= 1){
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
        if let currentUser = PFUser.currentUser(){
            let chill = PFObject(className: "Chill")
            var chillType = addChillTitle.text!.lowercaseString
            chillType = chillType.stringByReplacingOccurrencesOfString("&", withString: "")
            chillType = chillType.stringByReplacingOccurrencesOfString("chill", withString: "")
            chillType = chillType.stringByReplacingOccurrencesOfString(" ", withString: "")
            chill["type"] = chillType
            chill["overview"] = publicChillOverview.text
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
            chill["profilePic"] = FBSDKAccessToken.currentAccessToken().tokenString
            chill["chillers"] = []
            chill["chillersCount"] = 0
            PFGeoPoint.geoPointForCurrentLocationInBackground {
                (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
                if error == nil {
                    print("\(geoPoint)")
                    // do something with the new geoPoint
                    chill["location"] = geoPoint
                    chill.saveInBackground()
                    self.dismissViewControllerAnimated(true, completion: nil)
                    self.delegate!.finishedAddingChill()

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
    
    func backPressed(){
        self.dismissViewControllerAnimated(true, completion: nil)
        self.delegate!.finishedAddingChill()
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
            return textView.text.characters.count + (text.characters.count - range.length) <= 80;
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
    
}

protocol addChillDelegate {
    func finishedAddingChill()
}
