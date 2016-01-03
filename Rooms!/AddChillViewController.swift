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
    
    //MARK: - UI
    let addChillTitle : UITextField = UITextField()
    let doneAddingChillButton : UIButton = UIButton(type: UIButtonType.System)
    
    //MARK - Front Cell
    let frontContainerView = UIView()
    let profileImage = UIImageView()
    let publicChillDetails : UITextView = UITextView()
    let chillTypeLabel = UILabel()
    
    //MARK - Back Cell
    let backContainerView = UIView()
    let chillLabel = UILabel()
    let privateChillDetails = UITextView()
    
    //MARK: - UnusedUI
    let snowflakeImageView = UIImageView(image: UIImage(named: "Snowflake.png"))
    let addressLine1 : UITextField = UITextField()
    let addressLine2 : UITextField = UITextField()
    let hoursLabel : UILabel = UILabel()
    let startHoursFirstTF = UITextField()
    let startHoursColon = UILabel()
    let startHoursSecondTF = UITextField()
    let hoursDash = UILabel()
    let endHoursFirstTF = UITextField()
    let endHoursColon = UILabel()
    let endHoursSecondTF = UITextField()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.flatGray()
        addUI()
        addFrontCellUI()
        addBackCellUI()
    }
    
    func addUI(){
        
        doneAddingChillButton.frame = CGRectMake(view.frame.width/2 - 25, 500, 50, 50)
        doneAddingChillButton.setBackgroundImage(UIImage(named: "Snowflake.png"), forState: UIControlState.Normal)
        doneAddingChillButton.addTarget(self, action: "addChill", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(doneAddingChillButton)
    
    }

    /**
    *   This is where you can add/change/play with the UI for adding chills!
    */
    func addFrontCellUI(){
        
        addChillTitle.frame = CGRectMake(0, 100, view.frame.width, 100)
        addChillTitle.backgroundColor = UIColor.icyBlue()
        addChillTitle.textColor = UIColor.whiteColor()
        addChillTitle.textAlignment = NSTextAlignment.Center
        addChillTitle.placeholder = "Type of Chill"
        addChillTitle.delegate = self
        addChillTitle.font = UIFont(name: "Helvetica-Bold", size: 25.0)
        addChillTitle.tintColor = UIColor.whiteColor()
        addChillTitle.returnKeyType = .Next
        view.addSubview(addChillTitle)
        
        frontContainerView.frame = CGRectMake(view.frame.width * 0.025, CGRectGetMaxY(addChillTitle.frame) + 10, view.frame.width * 0.95, 90)
        frontContainerView.backgroundColor = UIColor.whiteColor()
        frontContainerView.layer.cornerRadius = 8.0
        frontContainerView.layer.masksToBounds = true
        view.addSubview(frontContainerView)
        
        profileImage.image = UIImage(named: "prof.jpg")
        if let accessToken = FBSDKAccessToken.currentAccessToken() {
            let profilePictureURL = NSURL(string: "https://graph.facebook.com/me/picture?width=200&height=200&return_ssl_resources=1&access_token=\(accessToken.tokenString)")
            profileImage.sd_setImageWithURL(profilePictureURL)
        }
        profileImage.frame = CGRectMake(0, 0, frontContainerView.frame.height, frontContainerView.frame.height)
        profileImage.layer.masksToBounds = true
        frontContainerView.addSubview(profileImage)
        
        publicChillDetails.frame = CGRectMake(profileImage.frame.width + 10, 5, frontContainerView.frame.width - profileImage.frame.width - 20, frontContainerView.frame.height * 0.8 - 5)
        publicChillDetails.layer.masksToBounds = true
        publicChillDetails.backgroundColor = UIColor.whiteColor()
        publicChillDetails.delegate = self
        publicChillDetails.returnKeyType = .Next
        publicChillDetails.textColor = UIColor.blackColor()
        publicChillDetails.textAlignment = NSTextAlignment.Center
        publicChillDetails.font = UIFont.systemFontOfSize(14.0)
        frontContainerView.addSubview(publicChillDetails)
        
        chillTypeLabel.frame = CGRectMake(profileImage.frame.width + 10, publicChillDetails.frame.height + 5, frontContainerView.frame.width - profileImage.frame.width - 20, frontContainerView.frame.height * 0.2)
        chillTypeLabel.text = ""
        chillTypeLabel.textAlignment = .Right
        chillTypeLabel.textColor = UIColor.icyBlue()
        chillTypeLabel.font = UIFont.systemFontOfSize(14.0)
        frontContainerView.addSubview(chillTypeLabel)
        
    }
    
    func addBackCellUI(){
        
        backContainerView.frame = CGRectMake(view.frame.width * 0.025, CGRectGetMaxY(frontContainerView.frame) + 10, view.frame.width * 0.95, 90)
        backContainerView.backgroundColor = UIColor.whiteColor()
        backContainerView.layer.cornerRadius = 8.0
        backContainerView.layer.masksToBounds = true
        view.addSubview(backContainerView)
        
        chillLabel.frame = CGRectMake(0, 0, backContainerView.frame.height, backContainerView.frame.height)
        chillLabel.text = "Chill"
        chillLabel.textColor = UIColor.whiteColor()
        chillLabel.textAlignment = .Center
        chillLabel.backgroundColor = UIColor.icyBlue()
        backContainerView.addSubview(chillLabel)
        
        privateChillDetails.frame = CGRectMake(profileImage.frame.width + 10, 5, frontContainerView.frame.width - profileImage.frame.width - 20, frontContainerView.frame.height * 0.8 - 5)
        privateChillDetails.layer.masksToBounds = true
        privateChillDetails.backgroundColor = UIColor.whiteColor()
        privateChillDetails.delegate = self
        privateChillDetails.returnKeyType = .Next
        privateChillDetails.textColor = UIColor.blackColor()
        privateChillDetails.textAlignment = NSTextAlignment.Center
        privateChillDetails.font = UIFont.systemFontOfSize(14.0)
        frontContainerView.addSubview(privateChillDetails)
        

        
    }
    
    /**This is unused UI that could be added in later**/
    func addOtherUI(){
        
        addressLine1.frame = CGRectMake(snowflakeImageView.frame.width, backContainerView.frame.height * 0.2, backContainerView.frame.width - 200.0, frontContainerView.frame.height * 0.3)
        addressLine1.textAlignment = .Center
        addressLine1.placeholder = "Address Line 1"
        addressLine1.font = UIFont.systemFontOfSize(14.0)
        backContainerView.addSubview(addressLine1)
        
        addressLine2.frame = CGRectMake(snowflakeImageView.frame.width, CGRectGetMaxY(addressLine1.frame), backContainerView.frame.width - 200.0, backContainerView.frame.height * 0.3)
        addressLine2.placeholder = "Address Line 2"
        addressLine2.textAlignment = .Center
        addressLine2.font = UIFont.systemFontOfSize(14.0)
        backContainerView.addSubview(addressLine2)
        
        let blueLine = UIView(frame: CGRectMake(CGRectGetMaxX(addressLine1.frame), 0, 1, backContainerView.frame.height))
        blueLine.backgroundColor = UIColor.icyBlue()
        backContainerView.addSubview(blueLine)
        
        hoursLabel.frame = CGRectMake(CGRectGetMaxX(addressLine1.frame), 0, 100.0, backContainerView.frame.height)
        hoursLabel.text = "??:?? PM\n-\n??:?? PM"
        hoursLabel.numberOfLines = 3
        hoursLabel.adjustsFontSizeToFitWidth = true
        hoursLabel.textAlignment = .Center
        hoursLabel.font = UIFont.systemFontOfSize(14.0)
        backContainerView.addSubview(hoursLabel)
        
        let yPosition = CGRectGetMaxY(backContainerView.frame) + self.view.frame.size.height * 0.1
        let midX = CGRectGetMidX(self.view.frame)
        
        startHoursFirstTF.frame = CGRectMake(midX - 115, yPosition, 40, 30)
        startHoursFirstTF.text = "??"
        startHoursFirstTF.layer.borderColor = UIColor.icyBlue().CGColor
        startHoursFirstTF.layer.borderWidth = 1.0
        startHoursFirstTF.layer.cornerRadius = 8.0
        startHoursFirstTF.keyboardType = .NumberPad
        startHoursFirstTF.textAlignment = .Center
        startHoursFirstTF.delegate = self
        startHoursFirstTF.font = UIFont.systemFontOfSize(20.0)
        view.addSubview(startHoursFirstTF)
        
        startHoursColon.frame = CGRectMake(CGRectGetMaxX(startHoursFirstTF.frame) + 5, yPosition, 10, 30)
        startHoursColon.text = ":"
        startHoursColon.textAlignment = .Center
        startHoursColon.font = UIFont.systemFontOfSize(20.0)
        view.addSubview(startHoursColon)
        
        startHoursSecondTF.frame = CGRectMake(CGRectGetMaxX(startHoursColon.frame) + 5, yPosition, 40, 30)
        startHoursSecondTF.text = "??"
        startHoursSecondTF.textAlignment = .Center
        startHoursSecondTF.layer.borderColor = UIColor.icyBlue().CGColor
        startHoursSecondTF.layer.borderWidth = 1.0
        startHoursSecondTF.layer.cornerRadius = 8.0
        startHoursSecondTF.delegate = self
        startHoursSecondTF.keyboardType = .NumberPad
        startHoursSecondTF.font = UIFont.systemFontOfSize(20.0)
        view.addSubview(startHoursSecondTF)
        
        hoursDash.frame = CGRectMake(midX - 10, yPosition, 20, 30)
        hoursDash.text = "-"
        hoursDash.textAlignment = .Center
        hoursDash.font = UIFont.systemFontOfSize(14.0)
        view.addSubview(hoursDash)

        endHoursFirstTF.frame = CGRectMake(midX + 15, yPosition, 40, 30)
        endHoursFirstTF.text = "??"
        endHoursFirstTF.layer.borderColor = UIColor.icyBlue().CGColor
        endHoursFirstTF.layer.borderWidth = 1.0
        endHoursFirstTF.textAlignment = .Center
        endHoursFirstTF.layer.cornerRadius = 8.0
        endHoursFirstTF.keyboardType = .NumberPad
        endHoursFirstTF.delegate = self
        endHoursFirstTF.font = UIFont.systemFontOfSize(20.0)
        view.addSubview(endHoursFirstTF)
        
        endHoursColon.frame = CGRectMake(CGRectGetMaxX(endHoursFirstTF.frame) + 5, yPosition, 10, 30)
        endHoursColon.text = ":"
        endHoursColon.textAlignment = .Center
        endHoursColon.font = UIFont.systemFontOfSize(20.0)
        view.addSubview(endHoursColon)
        
        endHoursSecondTF.frame = CGRectMake(CGRectGetMaxX(endHoursColon.frame) + 5, yPosition, 40, 30)
        endHoursSecondTF.text = "??"
        endHoursSecondTF.textAlignment = .Center
        endHoursSecondTF.layer.cornerRadius = 8.0
        endHoursSecondTF.layer.borderColor = UIColor.icyBlue().CGColor
        endHoursSecondTF.layer.borderWidth = 1.0
        endHoursSecondTF.keyboardType = .NumberPad
        endHoursSecondTF.delegate = self
        endHoursSecondTF.font = UIFont.systemFontOfSize(20.0)
        view.addSubview(endHoursSecondTF)
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
            chill["details"] = publicChillDetails.text
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

                }else{
                    print("\(error)")
                }
            }
        }else{
            let one = UIAlertController(title: "Sorry!", message: "You have to be logged in to post a Chill! Make sure that you are logged in and connected to the internet", preferredStyle: UIAlertControllerStyle.Alert)
            one.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(one, animated: true, completion: nil)
        }
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        addressLine1.resignFirstResponder()
        addressLine2.resignFirstResponder()
        addChillTitle.resignFirstResponder()
        publicChillDetails.resignFirstResponder()
        startHoursFirstTF.resignFirstResponder()
        startHoursSecondTF.resignFirstResponder()
        endHoursFirstTF.resignFirstResponder()
        endHoursSecondTF.resignFirstResponder()
    }
    
    //MARK - Text Field/View Delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if(addChillTitle.isFirstResponder()){
            textField.text = textField.text!.componentsSeparatedByCharactersInSet(NSCharacterSet.letterCharacterSet().invertedSet).joinWithSeparator("")
            publicChillDetails.becomeFirstResponder()
        }else if(publicChillDetails.isFirstResponder()){
            privateChillDetails.becomeFirstResponder()
        }else{
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if(textField == addChillTitle){
            var blankText = textField.text
            blankText = blankText!.stringByReplacingOccurrencesOfString("&Chill", withString: "")
            textField.text = blankText
        }else if(textField == startHoursFirstTF || textField == startHoursSecondTF || textField == endHoursFirstTF || textField == endHoursSecondTF){
            textField.text = ""
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
        }else{
            if(textField.text?.characters.count <= 0){
                textField.text = "??"
            }
            hoursLabel.text = "\(startHoursFirstTF.text!):\(startHoursSecondTF.text!)\n-\n\(endHoursFirstTF.text!):\(endHoursSecondTF.text!)"
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n"){
            textView.resignFirstResponder()
            return false
        }else{
            return true
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if(textField == startHoursFirstTF || textField == endHoursFirstTF || textField == startHoursSecondTF || textField == endHoursSecondTF){
            let currentCharacterCount = textField.text?.characters.count ?? 0
            if (range.length + range.location > currentCharacterCount){
                return false
            }
            let newLength = currentCharacterCount + string.characters.count - range.length
            return newLength <= 2
        }else{
            return true
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        var textViewText = textView.text
        textViewText = textViewText.stringByReplacingOccurrencesOfString("\n", withString: "")
        textView.text = textViewText
    }
    
}
