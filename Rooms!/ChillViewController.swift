//
//  AddAcitivityViewController.swift
//  Rooms!
//
//  Created by Justin Lennox on 10/14/15.
//  Copyright © 2015 Justin Lennox. All rights reserved.
//

import UIKit
import Parse

class ChillViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    //MARK- Main UI
    let bannerBackground : UIView = UIView()
    let andLabel : UILabel = UILabel()
    let chillLabel : UILabel = UILabel()
    let blankTextField : UITextField = UITextField()
    let addChillButton : UIButton = UIButton(type: UIButtonType.System)

    //MARK- Add Chill UI
    let addChillBackground : UIView = UIView()
    let addChillView : UIView = UIView()
    let addChillTitle : UITextField = UITextField()
    let addChillDetails : UITextView = UITextView()
    let doneAddingChillButton : UIButton = UIButton(type: UIButtonType.System)

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.topItem?.title = "Add an Activity"
        getChills()
    }
    
    override func viewDidLoad() {
        addMainUI()
        addAddChillUI()
        hideAddChillView()
    }
    
    func addMainUI(){
        bannerBackground.frame = CGRectMake(0, 0, view.frame.width, view.frame.height * 0.12)
        bannerBackground.backgroundColor = UIColor.pSeafoam()
        view.addSubview(bannerBackground)
        
        let bannerY = bannerBackground.frame.height * 0.1
        let bannerHeight = bannerBackground.frame.height * 0.8
        
        andLabel.frame = CGRectMake(view.frame.width * 0.47, bannerY, view.frame.width * 0.06, bannerHeight)
        andLabel.text = "&"
        andLabel.adjustsFontSizeToFitWidth = true
        andLabel.font = UIFont(name: "Helvetica-Bold", size: 30.0)
        andLabel.textColor = UIColor.whiteColor()
        view.addSubview(andLabel)
        
        chillLabel.frame = CGRectMake(view.frame.width * 0.53, bannerY, view.frame.width * 0.49, bannerHeight)
        chillLabel.text = "Chill"
        chillLabel.font = UIFont(name: "Helvetica-Bold", size: 30.0)
        chillLabel.textColor = UIColor.whiteColor()
        view.addSubview(chillLabel)
        
        blankTextField.frame = CGRectMake(0, bannerY, view.frame.width * 0.46, bannerHeight)
        blankTextField.textAlignment = NSTextAlignment.Right
        blankTextField.font = UIFont(name: "Helvetica-Bold", size: 30.0)
        blankTextField.textColor = UIColor.whiteColor()
        blankTextField.returnKeyType = UIReturnKeyType.Done
        blankTextField.delegate = self
        blankTextField.tintColor = UIColor.whiteColor()
        view.addSubview(blankTextField)
        
        let underline : UIView = UIView(frame: CGRectMake(blankTextField.frame.width * 0.2, blankTextField.frame.height - blankTextField.frame.size.height * 0.25, blankTextField.frame.width * 0.8, 1))
        underline.backgroundColor = UIColor.whiteColor()
        blankTextField.addSubview(underline)
        
        addChillButton.frame = CGRectMake(view.frame.size.width/2 - 25, view.frame.height - 100, 50, 50)
        addChillButton.backgroundColor = UIColor.pSeafoam()
        addChillButton.layer.cornerRadius = addChillButton.frame.width/2
        addChillButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        addChillButton.setTitle("+", forState: UIControlState.Normal)
        addChillButton.titleLabel?.font = UIFont(name: "Helvetica-Bold", size: 30.0)
        addChillButton.addTarget(self, action: "showAddChillView", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(addChillButton)
    }
    
    func addAddChillUI(){
        
        addChillBackground.frame = view.frame
        addChillBackground.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
        view.addSubview(addChillBackground)
        
        addChillView.frame = CGRectMake(view.frame.width * 0.1, view.frame.height * 0.33, view.frame.width * 0.8, view.frame.height * 0.33)
        addChillView.backgroundColor = UIColor.grayColor()
        addChillView.layer.cornerRadius = 8.0
        view.addSubview(addChillView)
        
        addChillTitle.frame = CGRectMake(0, 0, addChillView.frame.width, addChillView.frame.height * 0.3)
        addChillTitle.backgroundColor = UIColor.pSeafoam()
        addChillView.layer.masksToBounds = true
        addChillTitle.textColor = UIColor.whiteColor()
        addChillTitle.textAlignment = NSTextAlignment.Center
        addChillTitle.placeholder = "Type of Chill"
        addChillTitle.font = UIFont(name: "Helvetica-Bold", size: 25.0)
        addChillTitle.tintColor = UIColor.whiteColor()
        addChillView.addSubview(addChillTitle)
        
        addChillDetails.frame = CGRectMake(0, addChillTitle.frame.height, addChillView.frame.width, addChillView.frame.height * 0.7)
        addChillDetails.layer.masksToBounds = true
        addChillDetails.backgroundColor = UIColor.whiteColor()
        addChillDetails.textColor = UIColor.pSeafoam()
        addChillDetails.textAlignment = NSTextAlignment.Center
        addChillDetails.font = UIFont(name: "Helvetica", size: 20.0)
        addChillDetails.tintColor = UIColor.pSeafoam()
        addChillView.addSubview(addChillDetails)
        
        doneAddingChillButton.frame = CGRectMake(view.frame.width/2 - 25, CGRectGetMaxY(addChillView.frame) + view.frame.size.height * 0.01, 50, 50)
        doneAddingChillButton.setBackgroundImage(UIImage(named: "Snowflake.png"), forState: UIControlState.Normal)
        doneAddingChillButton.addTarget(self, action: "addChill", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(doneAddingChillButton)
        
    }
    
    /**
    * Downloads our chills from the backend
    */
    func getChills(){
        let query = PFQuery(className:"Chill")
        query.whereKey("host", equalTo: "Justin Lennox")
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                
                // Do something with the found objects
                if let objects = objects as [PFObject]! {
                    for chill in objects {
                        print(chill["details"])
                    }
                }
            } else {
                // Log details of the failure
                print("Error: \(error!)")
            }
        }
    }
    
    
    /**
    * Adds a new 'Chill' to the backend and then hides the Add-Chill views
    */
    func addChill(){
        let chill = PFObject(className: "Chill")
        chill["type"] = addChillTitle.text
        chill["details"] = addChillDetails.text
        chill.saveInBackground()
        hideAddChillView()
    }
    
    /**
    *   Show the 'Add Chill' view by setting all of the Add Chill UI alphas to 1
    */
    func showAddChillView(){
        addChillBackground.alpha = 1.0
        addChillView.alpha = 1.0
        doneAddingChillButton.alpha = 1.0
    }
    
    /**
     *   Hide the 'Add Chill' view by setting all of the Add Chill UI alphas to 0
     *   Also, removes the text from the addChillTitle and addChillDetails
     */
    func hideAddChillView(){
        addChillBackground.alpha = 0.0
        addChillView.alpha = 0.0
        doneAddingChillButton.alpha = 0.0
        
        addChillTitle.text = ""
        addChillDetails.text = ""
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

