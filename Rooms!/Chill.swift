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
    var overview : String
    var privateDetails : String
    var chillers : [String]
    var requestedChillers : [[String:String]]
    var invitedChillers : [String]
    var flipped : Bool = false
    var hostName : String
    var currentRequestedChiller : [String:String] = [String:String]()
    var invitation : Bool = false
    
    
    init(){
        id = ""
        type = ""
        overview = ""
        details = ""
        privateDetails = ""
        host = ""
        profilePic = ""
        hostName = ""
        chillers = []
        requestedChillers = []
        invitedChillers = []
    }
    
    init(idString: String, typeString : String, overviewString : String, detailsString: String, privateDetailsString : String, hostString : String, profileString : String, chillerArray : [String], chillRequests : [[String:String]], chillInvitations :[String], hostFirstName : String){
        id = idString
        type = typeString
        overview = overviewString
        details = detailsString
        privateDetails = privateDetailsString
        host = hostString
        profilePic = profileString
        chillers = chillerArray
        requestedChillers = chillRequests
        invitedChillers = chillInvitations
        hostName = hostFirstName
    }
    
    class func parseDictionaryIntoChill(chillDictionary : PFObject) -> Chill{
        return Chill(idString: chillDictionary.objectId!,
            typeString: String(chillDictionary["type"]),
            overviewString: String(chillDictionary["overview"]),
            detailsString: String(chillDictionary["details"]),
            privateDetailsString: String(chillDictionary["privateDetails"]),
            hostString: String(chillDictionary["host"]),
            profileString:String(chillDictionary["profilePic"]),
            chillerArray: chillDictionary["chillers"] as! [String],
            chillRequests: chillDictionary["requestedChillers"] as! [[String:String]],
            chillInvitations: chillDictionary["invitedChillers"] as! [String],
            hostFirstName: chillDictionary["hostName"] as! String)
    }
}