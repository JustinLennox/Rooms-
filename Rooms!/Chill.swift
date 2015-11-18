//
//  Chill.swift
//  Rooms!
//
//  Created by Justin Lennox on 11/11/15.
//  Copyright © 2015 Justin Lennox. All rights reserved.
//

import Foundation

class Chill{
    var type : String
    var details : String
    var host : String
    var profilePic : String
    
    init(typeString : String, detailsString: String, hostString : String, profileString : String){
        type = typeString
        details = detailsString
        host = hostString
        profilePic = profileString
    }
}