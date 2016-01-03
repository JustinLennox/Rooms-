//
//  ChillDetailsViewController.swift
//  AndChill
//
//  Created by Justin Lennox on 1/3/16.
//  Copyright © 2016 Justin Lennox. All rights reserved.
//

import UIKit

class ChillDetailsViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: - UI
    let scrollView = TPKeyboardAvoidingScrollView()
    let publicDetailsContainerView = UIView()
    let publicDetailsLabel = UILabel()
    let publicChillDetails = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.backgroundGray()
        scrollView.frame = CGRectMake(0, 90, view.frame.width, view.frame.height - 90)
        view.addSubview(scrollView)
        
    }
    
    func addPublicDetailsUI(){
        
        publicDetailsContainerView.frame = CGRectMake(view.frame.width * 0.025, 10, view.frame.width * 0.95, 90)
        publicDetailsContainerView.backgroundColor = UIColor.whiteColor()
        publicDetailsContainerView.layer.cornerRadius = 8.0
        publicDetailsContainerView.layer.masksToBounds = true
        scrollView.addSubview(publicDetailsContainerView)
        
        publicDetailsLabel.frame = CGRectMake(0, 0, publicDetailsContainerView.frame.height, publicDetailsContainerView.frame.height)
        publicDetailsLabel.text = "Public\nDetails"
        publicDetailsLabel.numberOfLines = 2
        publicDetailsLabel.textColor = UIColor.whiteColor()
        publicDetailsLabel.textAlignment = .Center
        publicDetailsLabel.backgroundColor = UIColor.icyBlue()
        publicDetailsContainerView.addSubview(publicDetailsLabel)
        
        publicChillDetails.frame = CGRectMake(publicDetailsLabel.frame.width + 10, 5, publicDetailsContainerView.frame.width - publicDetailsContainerView.frame.width - 20, publicDetailsContainerView.frame.height * 0.8 - 5)
        publicChillDetails.layer.masksToBounds = true
        publicChillDetails.backgroundColor = UIColor.whiteColor()
        publicChillDetails.textColor = UIColor.flatGray()
        publicChillDetails.textAlignment = NSTextAlignment.Center
        publicChillDetails.font = UIFont.systemFontOfSize(14.0)
        publicDetailsContainerView.addSubview(publicChillDetails)
        
    }

}
