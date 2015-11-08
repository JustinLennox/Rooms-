//
//  Chill.swift
//  Rooms!
//
//  Created by Justin Lennox on 11/2/15.
//  Copyright © 2015 Justin Lennox. All rights reserved.
//

import UIKit

class Chill: NSObject {
    
    var type : String = ""
    var details : String = ""
    
    override var description: String {
        return "Type: \(type); Details: \(details)"
    }

}
