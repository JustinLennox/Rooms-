//
//  NotificationTableViewCell.swift
//  AndChill
//
//  Created by Justin Lennox on 1/10/16.
//  Copyright © 2016 Justin Lennox. All rights reserved.
//

class NotificationTableViewCell: UITableViewCell {
    
    let containerView = UIView()
    let profileImage = UIImageView()
    let notificationLabel = UILabel()
    let instructionsLabel = UILabel()
    let chillOverviewLabel = UILabel()
    var request = false
    var invitation = false
    var currentChill = Chill()
    var myChillsVC = MyChillsViewController()
    
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
        
        profileImage.image = UIImage(named: "prof.jpg")
        profileImage.layer.masksToBounds = true
        containerView.addSubview(profileImage)
        
        notificationLabel.text = ""
        notificationLabel.adjustsFontSizeToFitWidth = true
        notificationLabel.layer.masksToBounds = true
        notificationLabel.font = UIFont.systemFontOfSize(14.0)
        notificationLabel.numberOfLines = -1
        containerView.addSubview(notificationLabel)
        
        instructionsLabel.text = "(Swipe left to reject, swipe right to accept)"
        instructionsLabel.textColor = UIColor.flatGray()
        instructionsLabel.alpha = 0.0
        instructionsLabel.textAlignment = .Center
        instructionsLabel.adjustsFontSizeToFitWidth = true
        instructionsLabel.layer.masksToBounds = true
        instructionsLabel.font = UIFont.systemFontOfSize(14.0)
        instructionsLabel.numberOfLines = -1
        containerView.addSubview(instructionsLabel)
        
        chillOverviewLabel.text = ""
        chillOverviewLabel.alpha = 0.0
        chillOverviewLabel.textAlignment = .Center
        chillOverviewLabel.adjustsFontSizeToFitWidth = true
        chillOverviewLabel.layer.masksToBounds = true
        chillOverviewLabel.font = UIFont.systemFontOfSize(14.0)
        chillOverviewLabel.numberOfLines = -1
        containerView.addSubview(chillOverviewLabel)
        
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
        notificationLabel.frame = CGRectMake(profileImage.frame.width + 10, 5, containerView.frame.width - profileImage.frame.width - 20, containerView.frame.height * 0.8 - 5)
        instructionsLabel.frame = CGRectMake(-frame.width * 0.025, -frame.height * 0.05, frame.width, frame.height)
        chillOverviewLabel.frame = CGRectMake(containerView.frame.width * 0.025, 0, containerView.frame.width * 0.95, containerView.frame.height * 0.95)
        
    }
    
    func setUpWithInvitation(chill : Chill){
        print("Set up")
        currentChill = chill
        invitation = true
        request = false
        notificationLabel.text = "\(chill.hostName) has invited you to \(chill.type)&chill."
        let profilePictureURL = NSURL(string: "https://graph.facebook.com/\(chill.host)/picture?type=square&width=200&height=200&return_ssl_resources=1")
        chillOverviewLabel.text = chill.overview
        profileImage.sd_setImageWithURL(profilePictureURL)

        if(currentChill.flipped == true){   //SHOW BACK
            showBackUI()
            hideFrontUI()
        }else{  //SHOW FRONT
            showFrontUI()
            hideBackUI()
        }
    }
    
    func setUpWithRequest(chill : Chill){
        request = true
        invitation = false
        currentChill = chill
        notificationLabel.text = "\(chill.currentRequestedChiller["name"]!) wants to join your \(chill.type)&chill."
        let profilePictureURL = NSURL(string: "https://graph.facebook.com/\(chill.currentRequestedChiller["facebookID"]!)/picture?type=square&width=200&height=200&return_ssl_resources=1")
        profileImage.sd_setImageWithURL(profilePictureURL)
        if(currentChill.flipped == true){   //SHOW BACK
            showBackUI()
            hideFrontUI()
        }else{  //SHOW FRONT
            showFrontUI()
            hideBackUI()
        }
    }
    
    func showBackUI(){
        containerView.layer.transform = CATransform3DMakeRotation(3.14, 0.0, 0.0, 0.0)
        if(request){
            instructionsLabel.alpha = 1.0
        }
        if(invitation){
            chillOverviewLabel.alpha = 1.0
        }

    }
    
    func hideBackUI(){
        instructionsLabel.alpha = 0.0
        chillOverviewLabel.alpha = 0.0
    }
    
    func showFrontUI(){
        profileImage.alpha = 1.0
        notificationLabel.alpha = 1.0
        
    }
    
    func hideFrontUI(){
        profileImage.alpha = 0.0
        notificationLabel.alpha = 0.0
        
    }
    
    func acceptInviteWithTable(tableView:UITableView){
        let parseChill : PFObject = PFObject(withoutDataWithClassName: "Chill", objectId: currentChill.id)
            if let facebookID = PFUser.currentUser()?.objectForKey("facebookID"){
                addUserWithIDToChatWithChillID(facebookID as! String, chillID: currentChill.id)
                parseChill.removeObject(PFUser.currentUser()?.objectForKey("facebookID") as! String, forKey: "invitedChillers")
                parseChill.removeObject(PFUser.currentUser()?.objectForKey("facebookID") as! String, forKey: "requestedChillers")
                parseChill.addObject(PFUser.currentUser()?.objectForKey("facebookID") as! String, forKey: "chillers")
                parseChill.incrementKey("chillersCount")
                parseChill.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                    if(error == nil){
                        self.myChillsVC.getMyChills()
                    }
                })
                pushChillFromTable(tableView)
                acceptedInvitationPush()
        }
    }
    
    func rejectInviteWithTable(tableView:UITableView){
        let parseChill : PFObject = PFObject(withoutDataWithClassName: "Chill", objectId: currentChill.id)
        if let facebookID = PFUser.currentUser()?.objectForKey("facebookID"){
            parseChill.removeObject(PFUser.currentUser()?.objectForKey("facebookID") as! String, forKey: "invitedChillers")
            parseChill.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                if(error == nil){
                    self.myChillsVC.getMyChills()
                }
            })
            removeChillFromTable(tableView)
        }
    }
    
    func acceptedInvitationPush(){
        if let userName = PFUser.currentUser()?.objectForKey("name"){
            let pushQuery = PFInstallation.query()
            pushQuery!.whereKey("facebookID", equalTo: currentChill.host)
            
            // Send push notification to query
            let push = PFPush()
            let data = [
                "badge" : "Increment",
            ]
            push.setData(data)
            push.setQuery(pushQuery) // Set our Installation query
            push.setMessage("\(userName) accepted your invitation to \(currentChill.type)&chill.")
            push.sendPushInBackground()
        }
    }
    
    func acceptRequestWithTable(tableView:UITableView){
        let parseChill : PFObject = PFObject(withoutDataWithClassName: "Chill", objectId: currentChill.id)
        if let facebookID = currentChill.currentRequestedChiller["facebookID"] {
            addUserWithIDToChatWithChillID(facebookID, chillID: currentChill.id)
            parseChill.removeObject(currentChill.currentRequestedChiller, forKey: "requestedChillers")
            parseChill.removeObject(currentChill.currentRequestedChiller, forKey: "invitedChillers")
            parseChill.addObject(facebookID, forKey: "chillers")
            parseChill.incrementKey("chillersCount")
            parseChill.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                if(error == nil){
                    self.myChillsVC.getMyChills()
                }
            })
            pushChillFromTable(tableView)
            acceptedRequestPush()
        }
    }
    
    func rejectRequestWithTable(tableView:UITableView){
        let parseChill : PFObject = PFObject(withoutDataWithClassName: "Chill", objectId: currentChill.id)
        if let facebookID = currentChill.currentRequestedChiller["facebookID"] {
            parseChill.removeObject(currentChill.currentRequestedChiller, forKey: "requestedChillers")
            parseChill.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                if(error == nil){
                    self.myChillsVC.getMyChills()
                }
            })
            removeChillFromTable(tableView)
        }
    }
    
    func acceptedRequestPush(){
        if let facebookID = currentChill.currentRequestedChiller["facebookID"] {
            let pushQuery = PFInstallation.query()
            pushQuery!.whereKey("facebookID", equalTo: facebookID)
            
            // Send push notification to query
            let push = PFPush()
            let data = [
                "badge" : "Increment",
            ]
            push.setData(data)
            push.setQuery(pushQuery) // Set our Installation query
            push.setMessage("\(PFUser.currentUser()!.objectForKey("name")!) accepted your request to \(currentChill.type)&chill.")
            push.sendPushInBackground()
        }
    }
    
    func addUserWithIDToChatWithChillID(userID: String, chillID: String){
        let chatQuery = PFQuery(className: "Message")
        chatQuery.whereKey("Chill", equalTo: chillID)
        chatQuery.getFirstObjectInBackgroundWithBlock { (pfChat: PFObject?, error: NSError?) -> Void in
            if(error != nil){
                if let chat = pfChat {
                    chat.addObject(PFUser.currentUser()?.objectForKey("facebookID") as! String, forKey: "participants")
                    chat.saveEventually()
                }
            }
        }
    }
    
    
    func removeChillFromTable(tableView: UITableView){
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.containerView.frame = CGRectMake(-600, self.containerView.frame.origin.y, self.containerView.frame.width, self.containerView.frame.height)
            }) { (completed: Bool) -> Void in
                tableView.reloadData()
        }
    }
    
    func pushChillFromTable(tableView: UITableView){
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.containerView.frame = CGRectMake(1000, self.containerView.frame.origin.y, self.containerView.frame.width, self.containerView.frame.height)
            }) { (completed: Bool) -> Void in
                tableView.reloadData()
        }
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



}
