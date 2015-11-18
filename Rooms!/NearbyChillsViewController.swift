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
    
    var chillArray : [Chill] = []
    let chillTableCellHeight : CGFloat = 100.0
    
    //MARK: - UI
    let bannerBackground : UIView = UIView()
    let blankTextField : UITextField = UITextField()
    
    
    //MARK: - View Methods
    
    override func viewDidLoad() {
        addMainUI()
        addChillTableView()
        if(NSUserDefaults.standardUserDefaults().objectForKey("FirstTime") != nil){
            let firstTime : Bool = NSUserDefaults.standardUserDefaults().objectForKey("FirstTime") as! Bool
            if(!firstTime && PFUser.currentUser() != nil){
                updateUserLocation()
            }
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
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //If there's no user logged in, send them to the Landing Screen
        if(PFUser.currentUser() == nil){
            performSegueWithIdentifier("showLoginSegue", sender: self)
        }else{
            //If there is a user and it's their first time using the app, tell them they need to allow us to access their location
            if(NSUserDefaults.standardUserDefaults().objectForKey("FirstTime") != nil){
                let firstTime : Bool = NSUserDefaults.standardUserDefaults().objectForKey("FirstTime") as! Bool
                if(firstTime){
                    let alert = UIAlertController(title: "Allow &Chill to Access Your Location", message: "&Chill needs to use your location in order to find activities near you. Please allow &Chill access to your location when prompted.", preferredStyle: UIAlertControllerStyle.Alert)
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
        bannerBackground.frame = CGRectMake(0, 0, view.frame.width, view.frame.height * 0.1)
        bannerBackground.backgroundColor = UIColor.cSeafoam()
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
     * Downloads our chills from the backend
     */
    func getChills(){
        let query = PFQuery(className:"Chill")
        let userLocation : PFGeoPoint = PFUser.currentUser()?.objectForKey("location") as! PFGeoPoint
        query.whereKey("location", nearGeoPoint: userLocation, withinMiles: 5.0)
        query.limit = 25

        var chillType : String = blankTextField.text!
        if(chillType.characters.count > 6){
            chillType = chillType.stringByReplacingOccurrencesOfString("&Chill", withString: "")
            chillType = chillType.lowercaseString
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
                            profileString:String(chillDictionary["profilePic"]))
                        
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
        }
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        var blankText = textField.text
        blankText = blankText!.stringByReplacingOccurrencesOfString("&Chill", withString: "")
        textField.text = blankText
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
        refreshControl.backgroundColor = UIColor.cRed()
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: .ValueChanged)
        chillTableView.addSubview(refreshControl)
    }
    
    func refresh(refreshControl: UIRefreshControl) {
        // Do your job, when done:
        getChills()
        refreshControl.endRefreshing()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : ChillTableViewCell = tableView.dequeueReusableCellWithIdentifier("ChillCell") as! ChillTableViewCell
        cell.backgroundColor = UIColor(red: 236.0/255.0, green: 240.0/255.0, blue: 241.0/255.0, alpha: 1.0)
        cell.selectionStyle = .None
        cell.chillButton.addTarget(self, action: "addChill:", forControlEvents: UIControlEvents.TouchUpInside)
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
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return chillTableCellHeight
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chillArray.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        blankTextField.resignFirstResponder()
        let cell :ChillTableViewCell = tableView.cellForRowAtIndexPath(indexPath) as! ChillTableViewCell
        let currentChill : Chill = chillArray[indexPath.row]
        
        if(currentChill.flipped == false){  //We're flipping the cell over to show the Add Chill UI
            UIView.animateWithDuration(0.3) { () -> Void in
                cell.containerView.layer.transform = CATransform3DMakeRotation(3.14, 1.0, 0.0, 0.0)

            }
            
            UIView.animateWithDuration(0.15, animations: { () -> Void in
                cell.profileImage.alpha = 0.0

                }) { (Bool) -> Void in
                    currentChill.flipped = true
                    cell.chillButton.alpha = 1.0
                    cell.containerView.layer.transform = CATransform3DMakeRotation(3.14, 0.0, 0.0, 0.0)

            }
        }else{  //We're flipping the cell to its original position to show the FBProfilePic
            UIView.animateWithDuration(0.3) { () -> Void in
                cell.containerView.layer.transform = CATransform3DMakeRotation(3.14, 1.0, 0.0, 0.0)
                
            }
            
            UIView.animateWithDuration(0.15, animations: { () -> Void in
                cell.chillButton.alpha = 0.0
                
                }) { (Bool) -> Void in
                    currentChill.flipped = false
                    cell.profileImage.alpha = 1.0
                    cell.containerView.layer.transform = CATransform3DMakeRotation(3.14, 0.0, 0.0, 0.0)
                    
            }
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    func addChill(sender: UIButton){
        print("Button tag:\(sender.tag)")
        let currentChill : Chill = chillArray[sender.tag]
        let parseChill : PFObject = PFObject(withoutDataWithClassName: "Chill", objectId: currentChill.id)
        parseChill.addObject(PFUser.currentUser()?.objectForKey("facebookID") as! String, forKey: "chillers")
        parseChill.saveInBackground()
    }
    
    
    
}




