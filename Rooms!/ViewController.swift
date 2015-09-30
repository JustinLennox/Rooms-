//
//  ViewController.swift
//  Rooms!
//
//  Created by Justin Lennox on 9/30/15.
//  Copyright © 2015 Justin Lennox. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = UIColor(red: (231.0/255.0), green: (76.0/255.0), blue: (60.0/255.0), alpha: 1.0)
        
        let label = UILabel()
        label.text = "Rooms!"
        label.frame = CGRectMake(0, view.frame.height * 0.03, view.frame.size.width, view.frame.size.height * 0.2)
        label.textColor = UIColor(red: (236.0/255.0), green: (240.0/255.0), blue: (241.0/255.0), alpha: 1.0)
        label.textAlignment = NSTextAlignment.Center
        label.font = UIFont(name: "Avenir Next", size: 50.0)
        view.addSubview(label)
        
        let signUpButton = UIButton()
        signUpButton.frame = CGRectMake(view.frame.width/2.0 - view.frame.size.width * 0.25, view.frame.height * 0.4, view.frame.size.width * 0.50, view.frame.height * 0.1)
        signUpButton.titleLabel?.textAlignment = NSTextAlignment.Center
        signUpButton.setTitle("Sign Up!", forState: UIControlState.Normal)
        signUpButton.titleLabel!.textColor = UIColor(red: (236.0/255.0), green: (240.0/255.0), blue: (241.0/255.0), alpha: 1.0)
        signUpButton.backgroundColor = UIColor(red: (22.0/255.0), green: (160.0/255.0), blue: (133.0/255.0), alpha: 1.0)
        view.addSubview(signUpButton)
        
        let loginButton = UIButton()
        loginButton.frame = CGRectMake(view.frame.width/2.0 - view.frame.size.width * 0.25, view.frame.height * 0.55, view.frame.size.width * 0.50, view.frame.height * 0.1)
        loginButton.titleLabel?.textAlignment = NSTextAlignment.Center
        loginButton.setTitle("Login!", forState: UIControlState.Normal)
        loginButton.titleLabel!.font = UIFont(name: "Avenir Next", size: 30.0)
        loginButton.titleLabel!.textColor = UIColor(red: (236.0/255.0), green: (240.0/255.0), blue: (241.0/255.0), alpha: 1.0)
        loginButton.backgroundColor = UIColor(red: (22.0/255.0), green: (160.0/255.0), blue: (133.0/255.0), alpha: 1.0)
        view.addSubview(loginButton)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

