//
//  AddChillTabViewController.swift
//  AndChill
//
//  Created by Justin Lennox on 1/3/16.
//  Copyright © 2016 Justin Lennox. All rights reserved.
//

import UIKit

class AddChillTabViewController: UIViewController, addChillDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.icyBlue()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if(PFUser.currentUser() == nil || PFUser.currentUser()?.objectForKey("facebookID") == nil){
            let alert = UIAlertController(title: "Sorry!", message: "You have to be connected to Facebook to post a chill", preferredStyle: .ActionSheet)
            alert.addAction(UIAlertAction(title: "Connect to Facebook", style: .Default, handler: { (handle: UIAlertAction) -> Void in
                self.performSegueWithIdentifier("showLandingSegue", sender: self)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .Destructive, handler: { (handle: UIAlertAction) -> Void in
                self.tabBarController?.selectedIndex = 0
            }))
            presentViewController(alert, animated: true, completion: nil)
        }else{
            performSegueWithIdentifier("showAddChillSegue", sender: self)
            self.tabBarController?.tabBar.hidden = true
        }
    }
    
    func finishedAddingChill() {
        self.tabBarController?.selectedIndex = 0
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "showAddChillSegue"){
            let vc : AddChillViewController = segue.destinationViewController as! AddChillViewController
            vc.modalPresentationStyle = .OverCurrentContext
            vc.delegate = self
        }
    }

}
