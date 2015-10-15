//
//  AddAcitivityViewController.swift
//  Rooms!
//
//  Created by Justin Lennox on 10/14/15.
//  Copyright © 2015 Justin Lennox. All rights reserved.
//

import UIKit

class AddActivityViewController: UIViewController {

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.topItem?.title = "Add an Activity"
    }
    
}

