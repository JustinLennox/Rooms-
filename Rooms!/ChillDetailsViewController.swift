//
//  ChillDetailsViewController.swift
//  AndChill
//
//  Created by Justin Lennox on 1/3/16.
//  Copyright © 2016 Justin Lennox. All rights reserved.
//

import UIKit
import Parse

class ChillDetailsViewController: UIViewController, UITextViewDelegate {
    
    //MARK: - UI
    let titleLabel = UILabel()
    let scrollView = TPKeyboardAvoidingScrollView()
    let privateDetailsContainerView = UIView()
    let privateDetailsLabel = UILabel()
    let privateChillDetails = UILabel()
    let messageScroller = UIScrollView()
    let messageTextField = UITextView()
    let messageBackground = UIView()
    let sendButton = UIButton(type: .System)
    var currentChill = Chill()
    var currentChat = PFObject(className: "Message")
    var currentMessageY : CGFloat = 10.0
    var profilePicDictionary = [String: UIImage]()
    var temporaryMessageArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.backgroundGray()
        
        let bannerBackground = UIView()
        bannerBackground.frame = CGRectMake(0, 0, view.frame.width, 64)
        bannerBackground.backgroundColor = UIColor.icyBlue()
        view.addSubview(bannerBackground)
        
        let bannerY = bannerBackground.frame.height * 0.25
        let bannerHeight = bannerBackground.frame.height * 0.8
        
        titleLabel.frame = CGRectMake(view.frame.width * 0.125, bannerY, view.frame.width * 0.75, bannerHeight)
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.font = UIFont.systemFontOfSize(25.0)
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = "&Chill"
        view.addSubview(titleLabel)
        
        let backButton = UIButton(type: .System)
        backButton.setBackgroundImage(UIImage(named: "backArrow.png"), forState: .Normal)
        backButton.frame = CGRectMake(10, bannerY + 8, 32, 32)
        backButton.addTarget(self, action: "backButtonPressed", forControlEvents: .TouchUpInside)
        view.addSubview(backButton)

        scrollView.frame = CGRectMake(0, 164, view.frame.width, view.frame.height - 164)
        view.addSubview(scrollView)
        scrollView.scrollEnabled = false
        addPrivateDetailsUI()
        addMessageUI()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        titleLabel.text = "\(currentChill.type)"
        privateChillDetails.text = currentChill.privateDetails
        loadMessages()
    }
    
    func addPrivateDetailsUI(){
        
        privateDetailsContainerView.frame = CGRectMake(view.frame.width * 0.025, 74, view.frame.width * 0.95, 90)
        privateDetailsContainerView.backgroundColor = UIColor.whiteColor()
        privateDetailsContainerView.layer.cornerRadius = 8.0
        privateDetailsContainerView.layer.masksToBounds = true
        view.addSubview(privateDetailsContainerView)
        
        privateDetailsLabel.frame = CGRectMake(0, 0, privateDetailsContainerView.frame.height, privateDetailsContainerView.frame.height)
        privateDetailsLabel.text = "Private\nDetails"
        privateDetailsLabel.numberOfLines = 2
        privateDetailsLabel.textColor = UIColor.whiteColor()
        privateDetailsLabel.textAlignment = .Center
        privateDetailsLabel.backgroundColor = UIColor.icyBlue()
        privateDetailsContainerView.addSubview(privateDetailsLabel)
        
        privateChillDetails.frame = CGRectMake(privateDetailsLabel.frame.width + 10, 5, privateDetailsContainerView.frame.width - privateDetailsLabel.frame.width - 20, privateDetailsContainerView.frame.height * 0.8 - 5)
        privateChillDetails.text = "❄️"
        privateChillDetails.adjustsFontSizeToFitWidth = true
        privateChillDetails.numberOfLines = 0
        privateChillDetails.textColor = UIColor.flatGray()
        privateChillDetails.font = UIFont.systemFontOfSize(14.0)
        privateDetailsContainerView.addSubview(privateChillDetails)
        
    }
    
    func addMessageUI(){
        
        messageTextField.frame = CGRectMake(5, scrollView.frame.height - 40, view.frame.width - 65, 33)
        messageTextField.layer.cornerRadius = 5.0
        messageTextField.font = UIFont.systemFontOfSize(14.0)
        messageTextField.layer.masksToBounds = true
        messageTextField.layer.borderColor = UIColor.lightGrayColor().CGColor
        messageTextField.layer.borderWidth = 1.0
        messageTextField.backgroundColor = UIColor.whiteColor()
        messageTextField.delegate = self
        messageTextField.text = "Chill Message"
        messageTextField.textColor = UIColor.flatGray()
        messageTextField.tintColor = UIColor.icyBlue()
        scrollView.addSubview(messageTextField)
        
        messageBackground.frame = CGRectMake(0, messageTextField.frame.origin.y - 9, view.frame.width, messageTextField.frame.height + 18)
        messageBackground.backgroundColor = UIColor.backgroundGray()
        messageBackground.layer.borderWidth = 1.0
        messageBackground.layer.borderColor = UIColor.lightGrayColor().CGColor
        scrollView.addSubview(messageBackground)
        scrollView.bringSubviewToFront(messageTextField)
        
        messageScroller.frame = CGRectMake(0, 10, view.frame.size.width, scrollView.frame.height - messageBackground.frame.height - 10)
        messageScroller.backgroundColor = UIColor.backgroundGray()
        messageScroller.contentSize = messageScroller.frame.size
        scrollView.addSubview(messageScroller)
        
        sendButton.frame = CGRectMake(CGRectGetMaxX(messageTextField.frame) + 5, messageTextField.frame.origin.y, 50, messageTextField.frame.size.height)
        sendButton.setTitle("Send", forState: .Normal)
        sendButton.setTitleColor(UIColor.icyBlue(), forState: .Normal)
        if #available(iOS 8.2, *) {
            sendButton.titleLabel?.font = UIFont.systemFontOfSize(18.0, weight: 0.35)
        } else {
            sendButton.titleLabel?.font = UIFont.systemFontOfSize(18.0)
        }
        sendButton.addTarget(self, action: "sendButtonPressed", forControlEvents: .TouchUpInside)
        scrollView.addSubview(sendButton)
        
        let dismissalTap = UITapGestureRecognizer(target: self, action: "dismissMessage")
        messageScroller.addGestureRecognizer(dismissalTap)
        scrollView.sendSubviewToBack(messageScroller)
    }
    
    //MARK: - Message Methods
    
    func sendButtonPressed(){
        print("Send!")
        sendMessage(messageTextField.text)
        messageTextField.text = "Chill Message"
        messageTextField.textColor = UIColor.flatGray()
        resizeMessageUI()
        messageTextField.resignFirstResponder()
    }
    
    func sendMessage(messageText: String){
        if let facebookID = PFUser.currentUser()?.objectForKey("facebookID"){
            let newMessage = ["text":messageText, "sender":facebookID, "senderName": PFUser.currentUser()?.objectForKey("name") as! String]
            currentChat.addObject(newMessage, forKey: "messageArray")
            currentChat.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                self.sendMessagePushNotification(messageText)
                self.loadMessages()
            }
        }
    }
    
    func sendMessagePushNotification(messageText: String){
        if let userName = PFUser.currentUser()?.objectForKey("name"){
            for user in currentChat.objectForKey("participants") as! [String]{
                    if(user != PFUser.currentUser()?.objectForKey("facebookID") as! String){
                    let pushQuery = PFInstallation.query()
                    pushQuery!.whereKey("facebookID", equalTo: user)
                    
                    // Send push notification to query
                    let push = PFPush()
                    push.setQuery(pushQuery) // Set our Installation query
                    push.setMessage("\(userName): \(messageText)")
                    push.sendPushInBackground()
                }
            }
        }
    }
    
    func loadMessages(){
        let chatQuery = PFQuery(className: "Message")
        chatQuery.whereKey("Chill", equalTo: currentChill.id)
        chatQuery.addAscendingOrder("createdAt")
        chatQuery.getFirstObjectInBackgroundWithBlock { (pfChat : PFObject?, error: NSError?) -> Void in
            if(error == nil){
                if let chat = pfChat{
                    self.currentChat = chat
                    for view in self.temporaryMessageArray{
                        view.removeFromSuperview()
                    }
                    self.messageScroller.contentSize = self.messageScroller.frame.size
                    self.currentMessageY = 10.0
                    for message in chat.objectForKey("messageArray") as! [[String:String]]{
                        self.generateMessageUIForMessage(message)
                    }
                }
            }else{
                print("ERRORRR")
                print("\(error.debugDescription)")
            }
        }
    }
    
    func loadProfilePicDictionary(){
        print("load profile pic dictionary")
        profilePicDictionary = [String: UIImage]()
        for facebookID in currentChat.objectForKey("participants") as! [String]{
            print("Facebookid:", facebookID)
            let profilePictureURL = NSURL(string: "https://graph.facebook.com/\(facebookID)/picture?type=square&width=60&height=60&return_ssl_resources=1")
            let sdImageManager = SDWebImageDownloader.sharedDownloader()
            sdImageManager.downloadImageWithURL(profilePictureURL, options: .IgnoreCachedResponse, progress: nil, completed: { (profilePicture : UIImage!, data: NSData!, error: NSError!, success: Bool) -> Void in
                print("Completed")
                if(error == nil){
                    print("No error")
                    self.profilePicDictionary[facebookID] = profilePicture
                }else{
                    print("Error")
                }
            })
        
        }
    }
    
    func generateMessageUIForMessage(message : [String:String]){
        
        let messageView = UIView()
        messageView.backgroundColor = UIColor.whiteColor()
        messageView.layer.cornerRadius = 8.0
        messageView.layer.masksToBounds = true
        
        let messageProfileImage = UIImageView()
        messageProfileImage.frame = CGRectMake(0, 0, 30, 30)
        let profilePictureURL = NSURL(string: "https://graph.facebook.com/\(message["sender"]!)/picture?type=square&width=60&height=60&return_ssl_resources=1")
        messageProfileImage.sd_setImageWithURL(profilePictureURL)
        messageProfileImage.layer.cornerRadius = messageProfileImage.frame.height/2.0
        messageProfileImage.layer.masksToBounds = true
        messageView.addSubview(messageProfileImage)
        
        let messageLabel = UILabel()
        messageLabel.numberOfLines = 0
        messageLabel.font = UIFont.systemFontOfSize(14.0)
        messageLabel.text = message["text"]!
        
        var messageViewFrame = CGRectMake(view.frame.width * 0.025, currentMessageY, view.frame.width * 0.95, 90)
        messageView.frame = messageViewFrame
        
        let messageNameLabel = UILabel()
        messageNameLabel.font = UIFont.systemFontOfSize(10.0)
        messageNameLabel.textColor = UIColor.flatGray()
        messageNameLabel.frame = CGRectMake(CGRectGetMaxX(messageProfileImage.frame) + 5, 7.5, messageView.frame.width - CGRectGetMaxX(messageProfileImage.frame) - 10, 15)
        messageNameLabel.text = message["senderName"]!
        messageView.addSubview(messageNameLabel)
        
        var messageLabelFrame = CGRectMake(CGRectGetMaxX(messageProfileImage.frame) + 5, 22.5, messageView.frame.width - CGRectGetMaxX(messageProfileImage.frame) - 10, messageView.frame.height - 35)
        messageLabel.frame = messageLabelFrame

        messageView.addSubview(messageLabel)
        messageScroller.addSubview(messageView)
        messageLabel.sizeToFit()
        temporaryMessageArray.addObject(messageView)
        
        messageViewFrame = CGRectMake(messageViewFrame.origin.x, messageViewFrame.origin.y , messageViewFrame.width, messageLabel.frame.height + 30)
        messageLabelFrame = CGRectMake(messageLabelFrame.origin.x, messageLabelFrame.origin.y, messageLabelFrame.width, messageLabel.frame.height)
        messageView.frame = messageViewFrame
        messageLabel.frame = messageLabelFrame
        currentMessageY += messageView.frame.height + 10
        
        if(messageScroller.contentSize.height < currentMessageY){
            messageScroller.contentSize = CGSizeMake(view.frame.width, currentMessageY)
            
        }
        messageScroller.contentOffset = CGPoint(x: 0, y: messageScroller.contentSize.height - messageScroller.bounds.size.height)

    }
    
    //MARK: - Navigation
    
    func backButtonPressed(){
        dismissViewControllerAnimated(true, completion: nil)
    }


    //MARK: - TextView Methods

    func textViewDidChange(textView: UITextView) {
        resizeMessageUI()
    }

    func textViewDidBeginEditing(textView: UITextView) {
        if(textView.text == "Chill Message"){
            textView.text = ""
            textView.textColor = UIColor.blackColor()
        }
        
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        scrollView.contentOffset = CGPoint(x: 0, y: -scrollView.contentInset.top)
        
        if(textView.text.characters.count <= 0){
            textView.text = "Chill Message"
            textView.textColor = UIColor.flatGray()
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        messageTextField.resignFirstResponder()
    }
    
    func dismissMessage(){
        messageTextField.resignFirstResponder()
    }
    
    func resizeMessageUI(){
        var messageFrame : CGRect = messageTextField.frame
        messageTextField.sizeToFit()
        messageFrame = CGRectMake(messageFrame.origin.x, scrollView.frame.height - messageTextField.frame.height - 5, messageFrame.width, messageTextField.frame.height)
        messageTextField.frame = messageFrame
        messageBackground.frame = CGRectMake(0, messageTextField.frame.origin.y - 9, view.frame.width, messageTextField.frame.height + 18)
        messageScroller.frame = CGRectMake(messageScroller.frame.origin.x, 10 - (messageBackground.frame.height - 51), messageScroller.frame.width, messageScroller.frame.height)
        
    }


}
