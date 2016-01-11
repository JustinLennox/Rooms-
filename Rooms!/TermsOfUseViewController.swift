//
//  PrivacyPolicyViewController.swift
//  AndChill
//
//  Created by Justin Lennox on 1/11/16.
//  Copyright © 2016 Justin Lennox. All rights reserved.
//

import UIKit

class TermsOfUseViewController: UIViewController, UIWebViewDelegate {
    
    let webView = UIWebView()
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.icyBlue()
        let bannerBackground = UIView(frame:CGRectMake(0, 0, view.frame.width, 34))
        bannerBackground.backgroundColor = UIColor.icyBlue()
        
        let titleLabel = UILabel(frame: CGRectMake(0, 30, view.frame.width, 24))
        titleLabel.text = "Terms of Use"
        titleLabel.font = UIFont.systemFontOfSize(20.0)
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.textAlignment = .Center
        titleLabel.backgroundColor = UIColor.icyBlue()
        view.addSubview(titleLabel)
        
        let cancelButton = UIButton(type: .System)
        cancelButton.backgroundColor = UIColor.icyBlue()
        cancelButton.frame = CGRectMake(0, 30, view.frame.width * 0.25, 24)
        cancelButton.setTitle("Cancel", forState: .Normal)
        cancelButton.titleLabel?.textAlignment = .Left
        cancelButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        cancelButton.titleLabel?.font = UIFont.systemFontOfSize(18.0)
        cancelButton.addTarget(self, action: "cancelButtonPressed", forControlEvents: .TouchUpInside)
        view.addSubview(cancelButton)
        
        webView.frame = CGRectMake(0,64,self.view.frame.size.width, self.view.frame.size.height-64)
        view.addSubview(webView)
    }
    
    override func viewDidAppear(animated: Bool) {
        let pdf = NSBundle.mainBundle().pathForResource("termsUse", ofType: "pdf")
        let pdfURL = NSURL(fileURLWithPath:pdf!)
        let req = NSURLRequest(URL: pdfURL)
        webView.delegate = self
        webView.loadRequest(req)
    }
    
    func cancelButtonPressed(){
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
}
