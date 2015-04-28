//
//  Application.swift
//  CooperationFinder
//
//  Created by Rafal Kwiatkowski on 26.02.2015.
//  Copyright (c) 2015 Snowdog. All rights reserved.
//

let ApplicationStatusApproved = "approved"
let ApplicationStatusRejected = "rejected"

class Application {

    var id: String?
    var user: User?
    var project: Project?
    var status: String?
    
    init() {
    }
    
    
    class func getApplicationsOfUser(user: User!, toProject project: Project!, completion: (success: Bool, applications: [Application]?) -> Void) {
        if (user != nil || project != nil) {
            let query : PFQuery = PFQuery(className: "Application")
            
            if (project != nil) {
                let subquery : PFQuery = PFQuery(className: "Project")
                subquery.whereKey("objectId", equalTo: project.id)
                query.whereKey("project", matchesQuery: subquery)
            }
            
            if (user != nil) {
                let subquery2 : PFQuery = PFQuery(className: "User")
                subquery2.whereKey("objectId", equalTo: user.id)
                query.whereKey("user", matchesQuery: subquery2)
            }
            
            query.findObjectsInBackgroundWithBlock({ (result: [AnyObject]!, error: NSError!) -> Void in
                self.processApplicationsResult(result, error: error, completion: completion)
            })
        } else {
            completion(success: false, applications: nil)
        }
    }
    
    class func getApplicationsToMyProjects(completion: (success: Bool, applications: [Application]?) -> Void) {
        var userId = Defaults["user_id"].string
        if (userId != nil) {
            let query : PFQuery = PFQuery(className: "Application")
            let subquery : PFQuery = PFQuery(className: "Project")
            let subquery2 : PFQuery = PFQuery(className: "User")
            subquery2.whereKey("objectId", equalTo: userId)
            subquery.whereKey("author", matchesQuery: subquery2)
            query.whereKey("project", matchesQuery: subquery)
            
            query.findObjectsInBackgroundWithBlock({ (result: [AnyObject]!, error: NSError!) -> Void in
                self.processApplicationsResult(result, error: error, completion: completion)
            })
        } else {
            completion(success: false, applications: nil)
        }
    }
    
    class func getMyApplications(completion: (success: Bool, applications: [Application]?) -> Void) {
        var userId = Defaults["user_id"].string
        if (userId != nil) {
            let query : PFQuery = PFQuery(className: "Application")
            let subquery : PFQuery = PFQuery(className: "User")
            subquery.whereKey("objectId", equalTo: userId)
            query.whereKey("user", matchesQuery: subquery)
            
            query.findObjectsInBackgroundWithBlock({ (result: [AnyObject]!, error: NSError!) -> Void in
                self.processApplicationsResult(result, error: error, completion: completion)
            })
        } else {
            completion(success: false, applications: nil)
        }
    }
    
    class func processApplicationsResult(result: [AnyObject]!, error: NSError!, completion:  (success: Bool, applications: [Application]?) -> Void) {
        if (error == nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                var applications : [Application] = []
                let pResult = result as! [PFObject]
                for pApplication: PFObject in pResult {
                    let application = Application.parseApplication(pApplication, includeProject: true)
                    applications.append(application)
                }
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completion(success: true, applications: applications)
                })
            })
        } else {
            completion(success: false, applications: nil)
        }
    }
    
    class func saveApplication(application: Application, completion: (success: Bool) -> Void) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            let pApplciation = self.serializeApplication(application)
            pApplciation.saveInBackgroundWithBlock({ (success: Bool, error: NSError!) -> Void in
                if (success) {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        completion(success: true)
                    })
                    
                } else {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        let error = NSError(domain: ErrorDomain, code: ErrorCodeOther, userInfo: nil)
                        completion(success: false)
                    })
                }
            })
        })
    }
    
    class func parseApplication(parseApplication: PFObject, includeProject: Bool = false) -> Application {
        let application = Application()
        application.id = parseApplication.valueForKey("objectId") as? String
        application.status = parseApplication.valueForKey("status") as? String
        
        let userRelation = parseApplication.relationForKey("user");
        let pUser = userRelation.query().getFirstObject()
        if (pUser != nil) {
            let user = User.parseUser(pUser)
            application.user = user
        }
        
        if (includeProject == true) {
            let projectRelation = parseApplication.relationForKey("project")
            let pProject = projectRelation.query().getFirstObject()
            if (pProject != nil) {
                let project = Project.parseProject(pProject, parseApplication: false)
                application.project = project;
            }
        }
        
        return application;
    }
    
    class func serializeApplication(application: Application) -> PFObject {
        
        var pApplication : PFObject!
        
        if (application.id != nil) {
            let query : PFQuery = PFQuery(className: "Application")
            query.whereKey("objectId", equalTo: application.id)
            pApplication = query.getFirstObject()
        }
        
        if (pApplication == nil) {
            pApplication = PFObject(className: "Application")
        }
        
        pApplication.setIfNotNil(application.status, key: "status")
        
        if let user = application.user {
            if (user.id != nil) {
                let query = PFQuery(className: "User")
                query.whereKey("objectId", equalTo: user.id)
                let pUser = query.getFirstObject()
                if pUser != nil {
                    let userRelation = pApplication.relationForKey("user");
                    userRelation.addObject(pUser)
                }
            }
        }
        
        if let project = application.project {
            if (project.id != nil) {
                let query = PFQuery(className: "Project")
                query.whereKey("objectId", equalTo: project.id)
                let pProject = query.getFirstObject()
                if pProject != nil {
                    let projectRelation = pApplication.relationForKey("project");
                    projectRelation.addObject(pProject)
                }
            }
        }
        
        return pApplication
    }
    
    func humanReadableStatus() -> String {
        if (self.status == nil || self.status!.isEmpty) {
            let userId = Defaults["user_id"].string
            if userId != nil && userId == self.user?.id {
                return NSLocalizedString("Waiting for approval", comment:"")
            } else {
                return NSLocalizedString("Waiting for my approval", comment:"")
            }
        } else if (self.status == ApplicationStatusApproved) {
            return NSLocalizedString("approved, e-mail sent", comment:"")
        } else if (self.status == ApplicationStatusRejected) {
            return NSLocalizedString("rejected", comment:"")
        }
        
        return ""
    }
    
    func statusIconName() -> String {
        if (self.status == ApplicationStatusApproved) {
            return "approved-ico"
        } else if (self.status == ApplicationStatusRejected) {
            return "rejected-ico"
        }
        return "pending-ico"
    }
}
