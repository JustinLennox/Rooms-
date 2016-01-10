//
//  EnableLocationViewController.swift
//  AndChill
//
//  Created by Alan Guilfoyle
//  Copyright © 2016 Justin Lennox. All rights reserved.
//

import UIKit

class EnableLocationViewController: UIViewController {
    let animationView = EnableLocationView()
    
    override func viewDidLoad() {
        animationView.frame = CGRectMake(0, 0, view.frame.width, view.frame.height)
        view.addSubview(animationView)
    }
    
    override func viewDidAppear(animated: Bool) {
        animationView.addEnableLocationAnimation()
        performSelector("updateUserLocation", withObject: nil, afterDelay: 1.0)
    }
    
    /**
     * Updates and stores the user's current GeoLocation
     */
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
        }else{
            dismissViewControllerAnimated(true, completion: nil)
        }
    }


}
