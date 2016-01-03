//
//  AddChillTabViewController.swift
//  AndChill
//
//  Created by Justin Lennox on 1/3/16.
//  Copyright © 2016 Justin Lennox. All rights reserved.
//

import UIKit

class AddChillTabViewController: UIViewController, addChillDelegate {
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        performSegueWithIdentifier("showAddChillSegue", sender: self)
        self.tabBarController?.tabBar.hidden = true
    }
    
    func finishedAddingChill() {
        self.tabBarController?.selectedIndex = 0
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc : AddChillViewController = segue.destinationViewController as! AddChillViewController
        vc.modalPresentationStyle = .OverCurrentContext
        vc.delegate = self
    }

}
