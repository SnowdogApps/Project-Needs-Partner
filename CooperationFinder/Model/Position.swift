//
//  Position.swift
//  CooperationFinder
//
//  Created by Rafal Kwiatkowski on 25.02.2015.
//  Copyright (c) 2015 Snowdog. All rights reserved.
//

class Position {

    var id : String?
    var name : String?
    var tags : [String]?
    
    init() {
    }
    
    class func parsePosition(parsePosition: PFObject) -> Position {
        let position = Position()
        position.id = parsePosition.valueForKey("objectId") as? String
        position.name = parsePosition.valueForKey("name") as? String
        position.tags = parsePosition.valueForKey("tags") as? [String]
        return position;
    }
    
    class func serializePosition(position: Position) -> PFObject {
        let pPosition = PFObject(className: "Position");
        pPosition.setIfNotNil(position.id, key: "objectId")
        pPosition.setIfNotNil(position.name, key: "name")
        pPosition.setIfNotNil(position.tags, key: "tags")
        return pPosition
    }
}
