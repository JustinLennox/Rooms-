//
//  MyChillsViewController.swift
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

class MyChillsViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var chillArray : [Chill] = []
    var requestedChillersDictionary : [String: PFObject] = [String: PFObject]()
    let chillTableCellHeight : CGFloat = 100.0
    var currentChill = Chill()
    
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
            getMyChills()
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
        titleLabel.text = "My Chills"
        view.addSubview(titleLabel)
        
        let settingsIcon = UIButton(type: .System)
        settingsIcon.setBackgroundImage(UIImage(named: "settingsIcon.png"), forState: .Normal)
        settingsIcon.imageView?.contentMode = .ScaleAspectFit
        settingsIcon.frame = CGRectMake(view.frame.width - 40, bannerY + 10, 30, 30)
        settingsIcon.addTarget(self, action: "settingsPressed", forControlEvents: .TouchUpInside)
        view.addSubview(settingsIcon)
        
    }
    
    func settingsPressed(){
        performSegueWithIdentifier("showSettingsSegue", sender: self)
    }
    
    //MARK: - Adding & Getting Chills from the Backend
    
    /**
    * Downloads our chills from the backend that we're the host of
    */
    func getMyChills(){
        let hostQuery = PFQuery(className:"Chill")
        hostQuery.whereKey("host", equalTo: PFUser.currentUser()?.objectForKey("facebookID") as! String)
        
        let chillerQuery = PFQuery(className: "Chill")
        chillerQuery.whereKey("chillers", equalTo: PFUser.currentUser()?.objectForKey("facebookID") as! String)
        
        let invitedQuery = PFQuery(className: "Chill")
        invitedQuery.whereKey("invitedChillers", equalTo: PFUser.currentUser()?.objectForKey("facebookID") as! String)
        
        let query = PFQuery.orQueryWithSubqueries([hostQuery, chillerQuery, invitedQuery])
        query.limit = 25
        query.addDescendingOrder("createdAt")
        
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                
                // Do something with the found objects
                if let objects = objects as [PFObject]! {
                    self.chillArray = []
                    for pfChill in objects {
                        if(pfChill.objectForKey("host") as! String == PFUser.currentUser()?.objectForKey("facebookID") as! String){
                            for requestedChiller in pfChill.objectForKey("requestedChillers") as! [[String:String]]{
                                let requestedChill = Chill.parseDictionaryIntoChill(pfChill)
                                requestedChill.currentRequestedChiller = requestedChiller
                                self.chillArray.append(requestedChill)
                            }
                        }
                        self.chillArray.append(Chill.parseDictionaryIntoChill(pfChill))
                    }
                    self.chillTableView.reloadData()
                    
                }
            } else {
                // Log details of the failure
                print("Error: \(error!)")
            }
        }
    }
    
    //MARK: - Table View
    
    let chillTableView = UITableView()
    
    func addChillTableView(){
        chillTableView.frame = CGRectMake(0, CGRectGetMaxY(bannerBackground.frame), view.frame.width, view.frame.height - bannerBackground.frame.height - 49)
        chillTableView.delegate = self
        chillTableView.dataSource = self
        chillTableView.registerClass(NotificationTableViewCell.self, forCellReuseIdentifier: "NotificationCell")
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
        getMyChills()
        refreshControl.endRefreshing()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let currentChill : Chill = chillArray[indexPath.row]
        if(getChillTypeFromPFObject(currentChill) == "Invited"){
            let cell : NotificationTableViewCell = tableView.dequeueReusableCellWithIdentifier("NotificationCell") as! NotificationTableViewCell
            cell.setUpWithInvitation(currentChill)
            let swipeLeftRecognizer = UISwipeGestureRecognizer(target: self, action: "rejectInvitation:")
            swipeLeftRecognizer.direction = .Left
            cell.tag = indexPath.row
            cell.addGestureRecognizer(swipeLeftRecognizer)
            let swipeRightRecognizer = UISwipeGestureRecognizer(target: self, action: "acceptInvitation:")
            swipeRightRecognizer.direction = .Right
            cell.addGestureRecognizer(swipeRightRecognizer)
            return cell
            
        }else if(getChillTypeFromPFObject(currentChill) == "Requested"){
            let cell : NotificationTableViewCell = tableView.dequeueReusableCellWithIdentifier("NotificationCell") as! NotificationTableViewCell
            cell.setUpWithRequest(currentChill)
            let swipeLeftRecognizer = UISwipeGestureRecognizer(target: self, action: "rejectRequest:")
            swipeLeftRecognizer.direction = .Left
            cell.tag = indexPath.row
            cell.addGestureRecognizer(swipeLeftRecognizer)
            let swipeRightRecognizer = UISwipeGestureRecognizer(target: self, action: "acceptRequest:")
            swipeRightRecognizer.direction = .Right
            cell.addGestureRecognizer(swipeRightRecognizer)
            return cell
            
        }else{
            //Just a regular chill
            let cell : ChillTableViewCell = tableView.dequeueReusableCellWithIdentifier("ChillCell") as! ChillTableViewCell
            cell.setUpWithChill(currentChill)
            cell.detailsButton.addTarget(self, action: "showDetails:", forControlEvents: .TouchUpInside)
            cell.reportButton.addTarget(self, action: "reportChill:", forControlEvents: .TouchUpInside)
            let swipeLeftRecognizer = UISwipeGestureRecognizer(target: self, action: "removeChill:")
            swipeLeftRecognizer.direction = .Left
            cell.tag = indexPath.row
            cell.addGestureRecognizer(swipeLeftRecognizer)
            return cell
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return chillTableCellHeight
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chillArray.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let currentPFChill = chillArray[indexPath.row]
        if(getChillTypeFromPFObject(currentPFChill) == "Chill"){
            let cell :ChillTableViewCell = tableView.cellForRowAtIndexPath(indexPath) as! ChillTableViewCell
            cell.flipCell()
        }else if(getChillTypeFromPFObject(currentPFChill) == "Invited"){
            let cell : NotificationTableViewCell = tableView.cellForRowAtIndexPath(indexPath) as! NotificationTableViewCell
            cell.flipCell()
        }else if(getChillTypeFromPFObject(currentPFChill) == "Requested"){
            let cell : NotificationTableViewCell = tableView.cellForRowAtIndexPath(indexPath) as! NotificationTableViewCell
            cell.flipCell()
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    func getChillTypeFromPFObject(chill : Chill) -> String{
        if(chill.invitedChillers.contains(PFUser.currentUser()?.objectForKey("facebookID") as! String)){
            return "Invited"
        }else if(chill.currentRequestedChiller["name"] != nil){
            return "Requested"
        }else{
            return "Chill"
        }

    }
    
    //MARK: - TableCell Helper Methods
    
    func acceptInvitation(gestureRecognizer : UISwipeGestureRecognizer){
        let chillCell = gestureRecognizer.view as! NotificationTableViewCell
        chillArray.removeAtIndex(chillCell.tag)
        chillCell.acceptInviteWithTable(chillTableView)
    }
    
    func rejectInvitation(gestureRecognizer : UISwipeGestureRecognizer){
        let chillCell = gestureRecognizer.view as! NotificationTableViewCell
        chillArray.removeAtIndex(chillCell.tag)
        chillCell.rejectInviteWithTable(chillTableView)
    }
    
    func acceptRequest(gestureRecognizer : UISwipeGestureRecognizer){
        let chillCell = gestureRecognizer.view as! NotificationTableViewCell
        chillArray.removeAtIndex(chillCell.tag)
        chillCell.acceptRequestWithTable(chillTableView)
    }
    
    func rejectRequest(gestureRecognizer : UISwipeGestureRecognizer){
        let chillCell = gestureRecognizer.view as! NotificationTableViewCell
        chillArray.removeAtIndex(chillCell.tag)
        chillCell.rejectRequestWithTable(chillTableView)
    }
    
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
    
    
}
