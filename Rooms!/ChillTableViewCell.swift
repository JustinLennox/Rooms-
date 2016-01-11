//
//  ChillTableViewCell.swift
//  AndChill
//
//  Created by Justin Lennox on 11/18/15.
//  Copyright © 2015 Justin Lennox. All rights reserved.
//

class ChillTableViewCell: UITableViewCell {
    
    let containerView = UIView()
    let profileImage = UIButton(type: UIButtonType.System)
    let chillButton = UIButton(type: UIButtonType.System)
    let detailsButton = UIButton(type: UIButtonType.System)
    let chillOverviewLabel = UILabel()
    let chillDetailsLabel = UILabel()
    let chillTypeLabel = UILabel()
    var currentChill = Chill()
    let reportButton = UIButton(type: UIButtonType.System)
    
    //MARK - Setup
    
    /**
    *   This is where we add all of the UI for the chill table view cell
    */
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = UIColor(red: 236.0/255.0, green: 240.0/255.0, blue: 241.0/255.0, alpha: 1.0)
        selectionStyle = .None
        
        containerView.backgroundColor = UIColor.whiteColor()
        containerView.layer.cornerRadius = 8.0
        containerView.layer.masksToBounds = true
        addSubview(containerView)
        
        profileImage.layer.masksToBounds = true
        containerView.addSubview(profileImage)
        
        chillOverviewLabel.text = ""
        chillOverviewLabel.adjustsFontSizeToFitWidth = true
        chillOverviewLabel.layer.masksToBounds = true
        chillOverviewLabel.font = UIFont.systemFontOfSize(14.0)
        chillOverviewLabel.numberOfLines = -1
        containerView.addSubview(chillOverviewLabel)
        
        chillDetailsLabel.text = ""
        chillDetailsLabel.alpha = 0.0
        chillDetailsLabel.adjustsFontSizeToFitWidth = true
        chillDetailsLabel.layer.masksToBounds = true
        chillDetailsLabel.font = UIFont.systemFontOfSize(14.0)
        chillDetailsLabel.numberOfLines = -1
        containerView.addSubview(chillDetailsLabel)
        
        chillTypeLabel.text = ""
        chillTypeLabel.textAlignment = .Right
        chillTypeLabel.textColor = UIColor.icyBlue()
        chillTypeLabel.font = UIFont.systemFontOfSize(14.0)
        containerView.addSubview(chillTypeLabel)
        
        chillButton.setTitle("Chill", forState: .Normal)
        chillButton.backgroundColor = UIColor.icyBlue()
        chillButton.alpha = 0.0
        chillButton.titleLabel?.numberOfLines = 0
        chillButton.titleLabel?.textAlignment = .Center
        chillButton.titleLabel?.adjustsFontSizeToFitWidth = true
        chillButton.addTarget(self, action: "joinChill", forControlEvents: .TouchUpInside)
        chillButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        chillButton.titleLabel?.font = UIFont.systemFontOfSize(18.0)
        containerView.addSubview(chillButton)
        
        detailsButton.setTitle("Chat", forState: .Normal)
        detailsButton.backgroundColor = UIColor.icyBlue()
        detailsButton.alpha = 0.0
        detailsButton.titleLabel?.textAlignment = .Center
        detailsButton.titleLabel?.adjustsFontSizeToFitWidth = true
        detailsButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        detailsButton.titleLabel?.font = UIFont.systemFontOfSize(18.0)
        containerView.addSubview(detailsButton)
        
        reportButton.setTitle("report", forState: .Normal)
        reportButton.alpha = 0.0
        reportButton.contentHorizontalAlignment = .Right
        reportButton.titleLabel?.textAlignment = .Right
        reportButton.setTitleColor(UIColor.redColor(), forState: .Normal)
        reportButton.titleLabel?.font = UIFont.systemFontOfSize(14.0)
        containerView.addSubview(reportButton)
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("FATAL ERROR")
    }
    
    /**
    *   This is where we position the UI for the chill table view cell
    */
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.frame = CGRectMake(frame.width * 0.025, frame.height * 0.05, frame.width * 0.95, frame.height * 0.9)
        profileImage.frame = CGRectMake(0, 0, containerView.frame.height, containerView.frame.height)
        chillOverviewLabel.frame = CGRectMake(profileImage.frame.width + 10, 5, containerView.frame.width - profileImage.frame.width - 20, containerView.frame.height * 0.8 - 5)
        chillDetailsLabel.frame = chillOverviewLabel.frame
        chillTypeLabel.frame = CGRectMake(profileImage.frame.width + 10, chillDetailsLabel.frame.height + 5, containerView.frame.width - profileImage.frame.width - 20, containerView.frame.height * 0.2)
        chillButton.frame = profileImage.frame
        reportButton.frame = CGRectMake(containerView.frame.width * 0.725, chillDetailsLabel.frame.height + 5, containerView.frame.width * 0.25, containerView.frame.height * 0.2)
        detailsButton.frame = chillButton.frame

    }
    
    func setUpWithChill(cellChill : Chill){
        self.currentChill = cellChill
        chillOverviewLabel.text = currentChill.overview
        chillDetailsLabel.text = currentChill.details
        let profilePictureURL = NSURL(string: "https://graph.facebook.com/\(currentChill.host)/picture?type=square&width=200&height=200&return_ssl_resources=1")
        profileImage.sd_setBackgroundImageWithURL(profilePictureURL, forState: .Normal)
        if(currentChill.flipped == true){   //SHOW BACK
            showBackUI()
            hideFrontUI()
        }else{  //SHOW FRONT
            showFrontUI()
            hideBackUI()
        }
        chillTypeLabel.text = "\(currentChill.type)&"
    }
    
    /**
    *   This animates the chill cell when we tap it. It flip/rotates it and shows the front or back
    */
    func flipCell(){
        if(currentChill.flipped == false){  //We're flipping the cell over to show the BACK
            
            UIView.animateWithDuration(0.3) { () -> Void in
                self.containerView.layer.transform = CATransform3DMakeRotation(3.14, 1.0, 0.0, 0.0)
            }
            
            UIView.animateWithDuration(0.15, animations: { () -> Void in //HIDE THE FRONT UI
                self.hideFrontUI()
                
                }) { (Bool) -> Void in //SHOW THE BACK UI
                    self.currentChill.flipped = true
                    self.showBackUI()
            }
            
        }else{  //We're flipping the cell to its original position to show the FRONT
            UIView.animateWithDuration(0.3) { () -> Void in
                self.containerView.layer.transform = CATransform3DMakeRotation(3.14, 1.0, 0.0, 0.0)
            }
            
            UIView.animateWithDuration(0.15, animations: { () -> Void in //HIDE THE BACK UI
                self.hideBackUI()
                
                }) { (Bool) -> Void in  // SHOW THE FRONT UI
                    self.currentChill.flipped = false
                    self.showFrontUI()
                    self.containerView.layer.transform = CATransform3DMakeRotation(3.14, 0.0, 0.0, 0.0)
            }
        }
    }
    
    func showBackUI(){
        
        self.reportButton.alpha = 1.0
        self.chillDetailsLabel.alpha = 1.0
        var request = false
        if let facebookID = PFUser.currentUser()?.objectForKey("facebookID"){
            for requestDictionary in currentChill.requestedChillers{
                if(requestDictionary["facebookID"] == facebookID as? String){
                    //THE USER HAS REQUESTED TO CHILL
                    self.chillButton.setTitle("Request\nSent", forState: .Normal)
                    self.chillButton.alpha = 1.0
                    self.chillButton.backgroundColor = UIColor.flatGray()
                    self.chillButton.enabled = false
                    request = true
                }
            }
            if(request == false && (currentChill.chillers.contains((facebookID as? String)!) || currentChill.host == (facebookID as? String)!)){
                //THE USER IS ALREADY IN THE CHILL, EITHER AS HOST OR CHILLER
                self.detailsButton.alpha = 1.0
                self.detailsButton.enabled = true
                self.chillButton.alpha = 0.0
                
            }else if(request == false){
                //THE USER HASN'T REQUESTED TO CHILL NOR IS ALREADY CHILLING
                print(" THE HASN'T REQUESTED TO CHILL NOR IS ALREADY CHILLING")
                self.chillButton.alpha = 1.0
                self.chillButton.setTitle("Chill", forState: .Normal)
                self.chillButton.backgroundColor = UIColor.icyBlue()
                self.detailsButton.alpha = 0.0
                print("ENABLED")
                self.chillButton.enabled = true
            }
            self.containerView.layer.transform = CATransform3DMakeRotation(3.14, 0.0, 0.0, 0.0)

        }
    }
    
    //MARK: - Button Actions
    
    /**
     *  Adds the current user to the chill's chillers
     */
    func joinChill(){
        
        let parseChill : PFObject = PFObject(withoutDataWithClassName: "Chill", objectId: currentChill.id)
        let request = ["facebookID" : PFUser.currentUser()?.objectForKey("facebookID") as! String, "name":PFUser.currentUser()?.objectForKey("name") as! String]
        parseChill.addObject(request, forKey: "requestedChillers")
        parseChill.incrementKey("chillersCount")
        parseChill.saveInBackground()
        chillButton.setTitle("Request\nSent", forState: .Normal)
        chillButton.backgroundColor = UIColor.flatGray()
        currentChill.requestedChillers.append(["facebookID":(PFUser.currentUser()?.objectForKey("facebookID"))! as! String, "name":PFUser.currentUser()?.objectForKey("name") as! String])
        chillButton.enabled = false
        joinChillPush()
        
    }
    
    /**
     *  Removes the current user from the chill's chillers and deletes it if they're the host
     */
    func removeChillFromTable(tableView: UITableView){
        UIView.animateWithDuration(0.3, animations: { () -> Void in
                        self.containerView.frame = CGRectMake(-600, self.containerView.frame.origin.y, self.containerView.frame.width, self.containerView.frame.height)
            }) { (completed: Bool) -> Void in
                tableView.reloadData()
        }
        let parseChillQuery = PFQuery(className: "Chill")
        parseChillQuery.whereKey("objectId", equalTo: currentChill.id)
        parseChillQuery.getFirstObjectInBackgroundWithBlock { (parseChill : PFObject?, error: NSError?) -> Void in
            if(error == nil){
                if(parseChill!.objectForKey("host") as! String == PFUser.currentUser()?.objectForKey("facebookID") as! String){
                    parseChill!.deleteInBackground()
                }else{
                    parseChill!.removeObject(PFUser.currentUser()?.objectForKey("facebookID") as! String, forKey: "chillers")
                    parseChill!.incrementKey("chillersCount", byAmount: -1)
                    parseChill!.saveInBackground()
                }
            }
        }
    }
    
    func joinChillPush(){
        if let userName = PFUser.currentUser()?.objectForKey("name"){
            let pushQuery = PFInstallation.query()
            pushQuery!.whereKey("facebookID", equalTo: currentChill.host)
            
            // Send push notification to query
            let push = PFPush()
            push.setQuery(pushQuery) // Set our Installation query
            push.setMessage("\(userName) wants to join your \(currentChill.type)&chill.")
            push.sendPushInBackground()
        }
    }
    
    //MARK: - Hide/Show UI
    
    func showFrontUI(){
        profileImage.alpha = 1.0
        chillOverviewLabel.alpha = 1.0
        chillTypeLabel.alpha = 1.0
    }
    
    func hideFrontUI(){
        profileImage.alpha = 0.0
        chillOverviewLabel.alpha = 0.0
        chillTypeLabel.alpha = 0.0
    }
    
    func hideBackUI(){
        reportButton.alpha = 0.0
        chillDetailsLabel.alpha = 0.0
        chillButton.alpha = 0.0
        detailsButton.alpha = 0.0
    }
    
}