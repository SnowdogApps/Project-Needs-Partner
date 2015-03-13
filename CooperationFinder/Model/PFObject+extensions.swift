//
//  PFObject+extensions.swift
//  CooperationFinder
//
//  Created by Rafal Kwiatkowski on 25.02.2015.
//  Copyright (c) 2015 Snowdog. All rights reserved.
//

extension PFObject {
    func setIfNotNil(value: AnyObject?, key: String) -> Void {
        if (value != nil) {
            self[key] = value
        }
    }
}
