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
    let scrollView = TPKeyboardAvoidingScrollView()
    let privateDetailsContainerView = UIView()
    let privateDetailsLabel = UILabel()
    let privateChillDetails = UILabel()
    let messageScroller = UIScrollView()
    let messageTextField = UITextView()
    let messageBackground = UIView()
    let sendButton = UIButton(type: .System)
    let currentChill = Chill()
    var currentChat = PFObject(className: "Message")
    var currentMessageY : CGFloat = 0.0
    var temporaryMessageArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.backgroundGray()
        scrollView.frame = CGRectMake(0, 90, view.frame.width, view.frame.height - 90)
        view.addSubview(scrollView)
        currentChill.id = "0100"
        loadMessages()
        scrollView.scrollEnabled = false
        addPrivateDetailsUI()
        addMessageUI()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        getCurrentChat()
    }
    
    func addPrivateDetailsUI(){
        
        privateDetailsContainerView.frame = CGRectMake(view.frame.width * 0.025, 10, view.frame.width * 0.95, 90)
        privateDetailsContainerView.backgroundColor = UIColor.whiteColor()
        privateDetailsContainerView.layer.cornerRadius = 8.0
        privateDetailsContainerView.layer.masksToBounds = true
        scrollView.addSubview(privateDetailsContainerView)
        
        privateDetailsLabel.frame = CGRectMake(0, 0, privateDetailsContainerView.frame.height, privateDetailsContainerView.frame.height)
        privateDetailsLabel.text = "Private\nDetails"
        privateDetailsLabel.numberOfLines = 2
        privateDetailsLabel.textColor = UIColor.whiteColor()
        privateDetailsLabel.textAlignment = .Center
        privateDetailsLabel.backgroundColor = UIColor.icyBlue()
        privateDetailsContainerView.addSubview(privateDetailsLabel)
        
        privateChillDetails.frame = CGRectMake(privateDetailsLabel.frame.width + 10, 5, privateDetailsContainerView.frame.width - privateDetailsLabel.frame.width - 20, privateDetailsContainerView.frame.height * 0.8 - 5)
        privateChillDetails.layer.masksToBounds = true
        privateChillDetails.text = "❄️"
        privateChillDetails.backgroundColor = UIColor.whiteColor()
        privateChillDetails.textColor = UIColor.flatGray()
        privateChillDetails.font = UIFont.systemFontOfSize(14.0)
        privateDetailsContainerView.addSubview(privateChillDetails)
        
    }
    
    func addMessageUI(){
        
        messageTextField.frame = CGRectMake(5, scrollView.frame.height - 38, view.frame.width - 65, 33)
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
        
        messageScroller.frame = CGRectMake(0, CGRectGetMaxY(privateDetailsContainerView.frame) + 10, view.frame.size.width, CGRectGetMinY(messageBackground.frame) - CGRectGetMaxY(privateDetailsContainerView.frame) - 15)
        messageScroller.backgroundColor = UIColor.backgroundGray()
        messageScroller.contentSize = messageScroller.frame.size
        scrollView.addSubview(messageScroller)
        
        sendButton.frame = CGRectMake(CGRectGetMaxX(messageTextField.frame) + 5, messageTextField.frame.origin.y, 50, messageTextField.frame.size.height)
        sendButton.setTitle("Send", forState: .Normal)
        sendButton.setTitleColor(UIColor.icyBlue(), forState: .Normal)
        sendButton.titleLabel?.font = UIFont.systemFontOfSize(18.0, weight: 0.35)
        sendButton.addTarget(self, action: "sendButtonPressed", forControlEvents: .TouchUpInside)
        scrollView.addSubview(sendButton)
        
        let dismissalTap = UITapGestureRecognizer(target: self, action: "dismissMessage")
        messageScroller.addGestureRecognizer(dismissalTap)
        
    }
    
    //MARK: - Message Methods
    
    func getCurrentChat(){
        let messageQuery = PFQuery(className: "Message")
        print("Current chill id: \(currentChill.id)")
        messageQuery.whereKey("Chill", equalTo: currentChill.id)
        messageQuery.getFirstObjectInBackgroundWithBlock { (chat : PFObject?, error: NSError?) -> Void in
            if(error == nil){
                if let cChat = chat{
                    self.currentChat = cChat
                    
                }
            }
        }
    }
    
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
            var newMessage = ["text":messageText, "sender":facebookID]
            currentChat.addObject(newMessage, forKey: "messageArray")
            currentChat.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                self.loadMessages()
            }
        }
    }
    
    func loadMessages(){
        let chatQuery = PFQuery(className: "Message")
        print("Current chill id: \(currentChill.id)")
        chatQuery.whereKey("Chill", equalTo: currentChill.id)
        chatQuery.addAscendingOrder("createdAt")
        chatQuery.getFirstObjectInBackgroundWithBlock { (pfChat : PFObject?, error: NSError?) -> Void in
            if(error == nil){
                if let chat = pfChat{
                    for view in self.temporaryMessageArray{
                        view.removeFromSuperview()
                    }
                    self.messageScroller.contentSize = self.messageScroller.frame.size
                    self.currentMessageY = 0.0
                    for message in chat.objectForKey("messageArray") as! [[String:String]]{
                        print(message["text"])
                        self.generateMessageUIForMessage(message)
                    }
                }
            }else{
                print("ERRORRR")
                print("\(error.debugDescription)")
            }
        }
    }
    
    func generateMessageUIForMessage(message : [String:String]){
        
        let messageView = UIView()
        messageView.backgroundColor = UIColor.whiteColor()
        messageView.layer.cornerRadius = 8.0
        messageView.layer.masksToBounds = true
        
        let messageLabel = UILabel()
        messageLabel.numberOfLines = 0
        messageLabel.text = message["text"]!
        
        var messageViewFrame = CGRectMake(view.frame.width * 0.025, currentMessageY, view.frame.width * 0.95, 90)
        messageView.frame = messageViewFrame
        
        var messageLabelFrame = CGRectMake(5, 5, messageView.frame.width - 10, messageView.frame.height - 5)
        messageLabel.frame = messageLabelFrame

        messageView.addSubview(messageLabel)
        messageScroller.addSubview(messageView)
        messageLabel.sizeToFit()
        temporaryMessageArray.addObject(messageView)
        
        let finalLabelHeight = messageLabel.frame.height < 30 ? 30 : messageLabel.frame.height
        messageViewFrame = CGRectMake(messageViewFrame.origin.x, messageViewFrame.origin.y , messageViewFrame.width, finalLabelHeight + 10)
        messageLabelFrame = CGRectMake(messageLabelFrame.origin.x, messageLabelFrame.origin.y, messageLabelFrame.width, finalLabelHeight)
        messageView.frame = messageViewFrame
        messageLabel.frame = messageLabelFrame
        currentMessageY += messageView.frame.height + 10
        
        if(messageScroller.contentSize.height < currentMessageY){
            messageScroller.contentSize = CGSizeMake(view.frame.width, currentMessageY)
            
        }
        messageScroller.contentOffset = CGPoint(x: 0, y: messageScroller.contentSize.height - messageScroller.bounds.size.height)

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
        messageScroller.frame = CGRectMake(messageScroller.frame.origin.x, CGRectGetMaxY(privateDetailsContainerView.frame) + 10 - (messageBackground.frame.height - 51), messageScroller.frame.width, messageScroller.frame.height)
        
    }


}
