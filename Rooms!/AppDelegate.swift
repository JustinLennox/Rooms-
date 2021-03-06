//
//  AppDelegate.swift
//  Rooms!
//
//  Created by Justin Lennox on 9/30/15.
//  Copyright © 2015 Justin Lennox. All rights reserved.
//

import UIKit
import Parse
import Bolts
import ParseFacebookUtilsV4

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Initialize Parse.
        Parse.setApplicationId("rUVUGBIlk5RlOxnOOvzxdNp1bVIPeyo63vlk3lV4",
            clientKey: "N2x4tjLHp4kg71rJPvV03QluyndEOMkKVcRd5BeA")
        
        // [Optional] Track statistics around application opens.
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        
        //Sends a request to Facebook for the current facebook user and stores their ID
        updateFacebookID()
    
        UITabBar.appearance().tintColor = UIColor.icyBlue()
        print("did finish launching")
        //HANDLING PUSH NOTIFICATIONS: Opens the chat when recieved
        if let notificationPayload = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? NSDictionary
        {
            print("payload")
            handleNotifications(notificationPayload)
        }
    
        // Override point for customization after application launch.
        return true
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.channels = ["global"]
        installation.saveInBackground()
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        if let window = self.window {
            if let presentedViewController = window.rootViewController!.presentedViewController{
                print("Presented view controller")
                if (presentedViewController.isKindOfClass(ChillDetailsViewController))
                {
                        print("chill details class")
                    let chatVC = presentedViewController as! ChillDetailsViewController
                    chatVC.loadMessages()
                }else{
                    handleNotifications(userInfo)
                    PFPush.handlePush(userInfo)
                }
            }else{
                handleNotifications(userInfo)
                print("Not presented view controller")
                PFPush.handlePush(userInfo)
            }
        }else{
            handleNotifications(userInfo)
            PFPush.handlePush(userInfo)
        }
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func application(application: UIApplication,
        openURL url: NSURL,
        sourceApplication: String?,
        annotation: AnyObject?) -> Bool {
            return FBSDKApplicationDelegate.sharedInstance().application(application,
                openURL: url,
                sourceApplication: sourceApplication,
                annotation: annotation)
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
    }
    
    func applicationDidBecomeActive(application: UIApplication) { // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        let currentInstallation = PFInstallation.currentInstallation()
        if (currentInstallation.badge != 0) {
            currentInstallation.badge = 0;
            currentInstallation.saveEventually()
        }
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func updateFacebookID(){
        if(PFUser.currentUser() != nil){
            let fbRequest = FBSDKGraphRequest(graphPath:"/me", parameters: nil);
            fbRequest.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
                if error == nil {   //There wasn't a problem, this FB user exists
                    PFUser.currentUser()?.setObject(result.objectForKey("id") as! String, forKey: "facebookID")
                    PFUser.currentUser()?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                    })
                } else {
                    print("Error Getting FB Info")
                }
            }
        }
    }
    
    func handleNotifications(notificationPayload : NSDictionary){
        print("Handle")
        // Create a pointer to the Photo object
        if let chatID = notificationPayload["chillID"]
        {
            print("Contains chillID")
            let vc = ChillDetailsViewController()
            let chillQuery = PFQuery(className: "Chill")
            chillQuery.whereKey("objectId", equalTo: chatID as! String)
            chillQuery.getFirstObjectInBackgroundWithBlock({ (pfChill : PFObject?, error: NSError?) -> Void in
                if(error == nil && pfChill != nil)
                {
                    print("No error")
                    let chill = Chill.parseDictionaryIntoChill(pfChill!)
                    if let window = self.window{
                        let navigationController = window.rootViewController as! UITabBarController
                        vc.currentChill = chill
                        navigationController.presentViewController(vc, animated: false, completion: nil)
                    }
                }
                
            })
        }
    }
    
}

