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
    let addChillBackground : UIButton = UIButton()
    let addChillView : UIView = UIView()
    let addChillTitle : UITextField = UITextField()
    let addChillDetails : UITextView = UITextView()
    let doneAddingChillButton : UIButton = UIButton(type: UIButtonType.System)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addUI()
    }

    /**
    *   This is where you can add/change/play with the UI for adding chills!
    */
    func addUI(){
        
        addChillBackground.frame = view.frame
        addChillBackground.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
        addChillBackground.addTarget(self, action: "chillBackgroundTapped", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(addChillBackground)
        
        addChillView.frame = CGRectMake(view.frame.width * 0.1, view.frame.height * 0.2, view.frame.width * 0.8, view.frame.height * 0.33)
        addChillView.backgroundColor = UIColor.grayColor()
        addChillView.layer.cornerRadius = 8.0
        view.addSubview(addChillView)
        
        addChillTitle.frame = CGRectMake(0, 0, addChillView.frame.width, addChillView.frame.height * 0.3)
        addChillTitle.backgroundColor = UIColor.cSeafoam()
        addChillView.layer.masksToBounds = true
        addChillTitle.textColor = UIColor.whiteColor()
        addChillTitle.textAlignment = NSTextAlignment.Center
        addChillTitle.placeholder = "Type of Chill"
        addChillTitle.delegate = self
        addChillTitle.font = UIFont(name: "Helvetica-Bold", size: 25.0)
        addChillTitle.tintColor = UIColor.whiteColor()
        addChillTitle.returnKeyType = .Next
        addChillView.addSubview(addChillTitle)
        
        addChillDetails.frame = CGRectMake(0, addChillTitle.frame.height, addChillView.frame.width, addChillView.frame.height * 0.7)
        addChillDetails.layer.masksToBounds = true
        addChillDetails.backgroundColor = UIColor.whiteColor()
        addChillDetails.delegate = self
        addChillDetails.returnKeyType = .Done
        addChillDetails.textColor = UIColor.cSeafoam()
        addChillDetails.textAlignment = NSTextAlignment.Center
        addChillDetails.font = UIFont(name: "Helvetica", size: 20.0)
        addChillDetails.tintColor = UIColor.cSeafoam()
        addChillView.addSubview(addChillDetails)
        
        doneAddingChillButton.frame = CGRectMake(view.frame.width/2 - 25, CGRectGetMaxY(addChillView.frame) + view.frame.size.height * 0.01, 50, 50)
        doneAddingChillButton.setBackgroundImage(UIImage(named: "Snowflake.png"), forState: UIControlState.Normal)
        doneAddingChillButton.addTarget(self, action: "addChill", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(doneAddingChillButton)
        
    }
    
    /**
     * Adds a new 'Chill' to the backend and then hides the Add-Chill views
     */
    func addChill(){
        let chill = PFObject(className: "Chill")
        var chillType = addChillTitle.text!.lowercaseString
        chillType = chillType.stringByReplacingOccurrencesOfString("&", withString: "")
        chillType = chillType.stringByReplacingOccurrencesOfString("chill", withString: "")
        chillType = chillType.stringByReplacingOccurrencesOfString(" ", withString: "")
        chill["type"] = chillType
        chill["details"] = addChillDetails.text
        chill["host"] = PFUser.currentUser()?.objectForKey("facebookID")
        chill["profilePic"] = FBSDKAccessToken.currentAccessToken().tokenString
        chill["chillers"] = []
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
    }
    
    func chillBackgroundTapped(){
        if(addChillTitle.isFirstResponder() || addChillDetails.isFirstResponder()){
            addChillTitle.resignFirstResponder()
            addChillDetails.resignFirstResponder()
        }else{
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.text = textField.text!.componentsSeparatedByCharactersInSet(NSCharacterSet.letterCharacterSet().invertedSet).joinWithSeparator("")
        if(addChillTitle.isFirstResponder()){
            addChillDetails.becomeFirstResponder()
        }else{
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        var blankText = textField.text
        blankText = blankText!.stringByReplacingOccurrencesOfString("&Chill", withString: "")
        textField.text = blankText
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n"){
            textView.resignFirstResponder()
            return false
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
