//
//  EnableLocationViewController.swift
//  AndChill
//
//  Created by Alan Guilfoyle
//  Copyright © 2016 Justin Lennox. All rights reserved.
//

import UIKit

class EnableLocationViewController: UIViewController, CLLocationManagerDelegate {
    let animationView = EnableLocationView()
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        animationView.frame = CGRectMake(0, 0, view.frame.width, view.frame.height)
        view.addSubview(animationView)
    }
    
    override func viewDidAppear(animated: Bool) {
        animationView.addEnableLocationAnimation()
        performSelector("updateUserLocation", withObject: nil, afterDelay: 2.5)
    }
    
    /**
     * Updates and stores the user's current GeoLocation
     */
    func updateUserLocation(){
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestAlwaysAuthorization()
        
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
                            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "FirstTime")
                            NSUserDefaults.standardUserDefaults().synchronize()
                            self.performSegueWithIdentifier("showNearbySegue", sender: self)
                        }else{
                            let alert = UIAlertController(title: "Oops!", message: "&Chill couldn't save your location. Please make sure you're connected to the internet.", preferredStyle: UIAlertControllerStyle.Alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                    })
                }else{
                    let alert = UIAlertController(title: "Oops!", message: "&Chill couldn't save your location. Please make sure you're connected to the internet.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)

                }
            }
        }else{
            dismissViewControllerAnimated(true, completion: nil)
        }
    }


}
