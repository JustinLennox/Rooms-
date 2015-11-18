//
//  Chill.swift
//  Rooms!
//
//  Created by Justin Lennox on 11/11/15.
//  Copyright © 2015 Justin Lennox. All rights reserved.
//

import Foundation
import Parse

class Chill {
    
    var id : String
    var type : String
    var details : String
    var host : String
    var profilePic : String
    var flipped : Bool = false
    
    init(idString: String, typeString : String, detailsString: String, hostString : String, profileString : String){
        id = idString
        type = typeString
        details = detailsString
        host = hostString
        profilePic = profileString
    }
    
    class func parseClassName() -> String {
        return "Chill"
    }
}