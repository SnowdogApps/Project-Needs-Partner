//
//  User.swift
//  CooperationFinder
//
//  Created by Rafal Kwiatkowski on 25.02.2015.
//  Copyright (c) 2015 Snowdog. All rights reserved.
//

let UserRoleModerator = "moderator"
let UserRoleOrdinary = "orinary"

private let kSalt = "IhYDXu6PTBtQmlPTWfSg5rSaUT7HRx/i1AE7f4QcgU1/oM7jN9k9cUf766bk3JVsxVNFQHPLhzk7aon7cjhje6DtzO1MaYd8UTr5fhPBpPP59j3RBPGqD2A22o6vO9Eec6UlHr05Pv5WiOZulbNHOJ0nC1ZZcBjECrPrfNvcBvc"

class User {
    
    var id : String?
    var email : String?
    var password : String?
    var fullname : String?
    var phone : String?
    var desc : String?
    var company : String?
    var role : String?
    var partner : Bool?
    var tags : [String]?
    
    init() {
    }
    
    class func login(email: String, password: String, completion: (success: Bool, user: User?) -> Void) {
        let query : PFQuery = PFQuery(className: "User")
        query.whereKey("email", equalTo: email)
        query.whereKey("password", equalTo: self.hashPassword(password))
        query.getFirstObjectInBackgroundWithBlock({(object: PFObject!, error: NSError!) -> Void in
            if (object == nil) {
                completion(success: false, user: nil)
            } else {
                let user = self.parseUser(object)
                completion(success: true, user: user)
            }
        })
    }
    
    class func saveUser(user: User, completion: (user: User?, error: NSError?) -> Void) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            
            var pUser : PFObject?
            if (user.id != nil) {
                
                let query : PFQuery = PFQuery(className: "User")
                query.whereKey("objectId", equalTo: user.id)
                pUser = query.getFirstObject()
                
                if (pUser != nil) {
                    self.setParseUserFields(pUser!, fromUser: user)
                    pUser?.saveInBackgroundWithBlock({ (success: Bool, error: NSError!) -> Void in
                        if (success) {
                            completion(user: user, error: nil)
                        } else {
                            completion (user: nil, error: error)
                        }
                    })
                } else {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        let error = NSError(domain: ErrorDomain, code: ErrorCodeOther, userInfo: nil)
                        completion(user: nil, error: error)
                    })
                }
                
            } else {
            
                let query : PFQuery = PFQuery(className: "User")
                query.whereKey("email", equalTo: user.email)
                pUser = query.getFirstObject()
                if (pUser == nil) {
                    pUser = self.serializeUser(user)
                    pUser?.saveInBackgroundWithBlock({ (success: Bool, error: NSError!) -> Void in
                        if (success) {
                            user.id = pUser?.valueForKey("objectId") as? String
                            completion(user: user, error: nil)
                        } else {
                            let error = NSError(domain: ErrorDomain, code: ErrorCodeOther, userInfo: nil)
                            completion(user: user, error: error)
                        }
                    })
                } else {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        let error = NSError(domain: ErrorDomain, code: ErrorCodeAlreadyExists, userInfo: nil)
                        completion (user: nil, error: error)
                    })
                }
                
            }
        })
    }
    
    class func getUserWithID(userID: String?, completion: (user: User?) -> ()) {
        if (userID != nil) {
            let query : PFQuery = PFQuery(className: "User")
            query.whereKey("objectId", equalTo: userID)
            query.getFirstObjectInBackgroundWithBlock({(object: PFObject!, error: NSError!) -> Void in
                if (object == nil) {
                    completion(user: nil)
                } else {
                    let user = User.parseUser(object)
                    completion(user: user)
                }
            })
        } else {
            completion(user: nil)
        }
    }
    
    class func getLoggedUser(#completion: (user: User?) -> ()) {
        if let userID = Defaults["user_id"].string {
            self.getUserWithID(userID, completion: completion)
        } else {
            completion(user: nil)
        }
    }
    
    class func parseUser(parseUser: PFObject) -> User {
        let user = User()
        user.id = parseUser.valueForKey("objectId") as? String
        user.email = parseUser.valueForKey("email") as? String
        user.fullname = parseUser.valueForKey("fullname") as? String
        user.phone = parseUser.valueForKey("phone") as? String
        user.desc = parseUser.valueForKey("desc") as? String
        user.company = parseUser.valueForKey("company") as? String
        user.role = parseUser.valueForKey("role") as? String
        user.partner = parseUser.valueForKey("partner") as? Bool
        user.tags = parseUser.valueForKey("tags") as? [String]
        return user
    }
    
    class func serializeUser(user: User) -> PFObject {
        let pUser = PFObject(className: "User");
        self.setParseUserFields(pUser, fromUser: user)
        return pUser
    }
    
    class func setParseUserFields(pUser: PFObject, fromUser user: User) {
        pUser.setIfNotNil(user.id, key: "objectId")
        pUser.setIfNotNil(user.email, key: "email")
        pUser.setIfNotNil(user.fullname, key: "fullname")
        pUser.setIfNotNil(user.phone, key: "phone")
        pUser.setIfNotNil(user.company, key: "company")
        pUser.setIfNotNil(user.desc, key: "desc")
        pUser.setIfNotNil(user.role, key: "role")
        pUser.setIfNotNil(user.partner, key: "partner")
        pUser.setIfNotNil(user.tags, key: "tags")
        
        if let password = user.password {
            pUser.setIfNotNil(hashPassword(password), key: "password")
        }
    }

    class private func hashPassword(password: String) -> String? {
        let hashString = (password + kSalt) as NSString
        return sha256Hash(hashString)
    }
    
    class private func sha256Hash(string : NSString) -> NSString? {
        let data : NSData! = string.dataUsingEncoding(NSUTF8StringEncoding)
        if (data != nil) {
            let res = NSMutableData(length: Int(CC_SHA256_DIGEST_LENGTH))
            CC_SHA256(data.bytes, CC_LONG(data.length), UnsafeMutablePointer(res!.mutableBytes))
            var i : UInt32 = 0
            
            var result : NSMutableString = ""
            let count = Int(CC_SHA256_DIGEST_LENGTH)
            var array : [UInt8] = [UInt8](count: count, repeatedValue: 0);
            data.getBytes(&array, length: count * sizeof(UInt8))
            for var i = 0; i < count; i++ {
                result.appendFormat("%02x", array[i])
            }
            return result
        }
        
        return nil
    }

    
    func nameAndCompany() -> String {
        var name = ""
        if let fullname = self.fullname {
            name += fullname
        }
        
        if let company = self.company {
            name += (", " + company)
        }
        
        return name
    }
    
    
    
}
