//
//  Project.swift
//  CooperationFinder
//
//  Created by Rafal Kwiatkowski on 25.02.2015.
//  Copyright (c) 2015 Snowdog. All rights reserved.
//

let ProjectStatusOpen = "open"
let ProjectStatusRejected = "rejected"
let ProjectStatusArchived = "archived"
let ProjectStatusWaitingForApproval = "waiting_for_approval"

class Project {

    var id : String?
    var name : String?
    var createdAt : NSDate?
    var desc : String?
    var commercial : Bool?
    var author : User?
    var positions : [Position]?
    var applications : [Application]?
    
    var status : String
    
    init() {
        self.status = ProjectStatusOpen
    }
    
    class func saveProject(project: Project, completion: (success: Bool) -> Void) {
        if (project.id != nil) {
            let query : PFQuery = PFQuery(className: "Project")
            query.whereKey("objectId", equalTo: project.id)
            let pProject = query.getFirstObject()
            self.setParseProjectFields(pProject, fromProject:project)
            pProject.saveInBackgroundWithBlock({ (success: Bool, error: NSError!) -> Void in
                completion(success: success)
            })
        } else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                let pProject = self.serializeProject(project)
                pProject.saveInBackgroundWithBlock({ (success: Bool, error: NSError!) -> Void in
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            completion(success: success)
                        })
                })
            })
        }
        
    }
    
    class func getProjects(myProjects: Bool?, searchPhrase: String?, tags: [String]?, statuses: [String]?, commercial: Bool?, partner: Bool?, completion: (success: Bool, projects: [Project]?) -> Void) {
        
        let query : PFQuery = PFQuery(className: "Project")
        
        if (myProjects != nil) {
            var userId = Defaults["user_id"].string
            if (userId != nil) {
                let subquery = PFQuery(className: "User")
                subquery.whereKey("objectId", equalTo: userId)
                query.whereKey("author", matchesQuery: subquery)
            }
            
        }
        
        if (searchPhrase != nil) {
            query.whereKey("name", containsString: searchPhrase)
        }
        
        if (tags != nil) {
            if (tags?.count > 0) {
                let subquery = PFQuery(className: "Position")
                subquery.whereKey("tags", containedIn: tags)
                query.whereKey("positions", matchesQuery: subquery)
            }
        }
        
        if (statuses != nil && statuses?.count > 0) {
            query.whereKey("status", containedIn: statuses)
        }
        
        if (commercial != nil) {
            query.whereKey("commercial", equalTo: commercial)
        }
        
        if (partner != nil && partner == true) {
            let subquery = PFQuery(className: "User")
            subquery.whereKey("partner", equalTo: partner)
            query.whereKey("author", matchesQuery:subquery)
        }
        
        query.findObjectsInBackgroundWithBlock({ (result: [AnyObject]!, error: NSError!) -> Void in
            if (error == nil) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                    var projects : [Project] = []
                    let pResult = result as [PFObject]
                    for pProject: PFObject in pResult {
                        let project = Project.parseProject(pProject)
                        projects.append(project)
                    }
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        completion(success: true, projects: projects)
                    })
                })
            } else {
                completion(success: false, projects: nil)
            }
            
        })
    }
    
    class func deleteProject(project: Project, completion: (success: Bool) -> Void) {
        if (project.id != nil) {
            let query : PFQuery = PFQuery(className: "Project")
            query.whereKey("objectId", equalTo: project.id)
            let pProject = query.getFirstObject()
            
            if (pProject != nil) {
                pProject.deleteInBackgroundWithBlock({ (success: Bool, error: NSError!) -> Void in
                    completion(success: success)
                })
            } else {
                completion(success: false)
            }
        } else {
            completion(success: false)
        }
    }
    
    
    class func parseProject(parseProject: PFObject, parseApplication: Bool = true) -> Project {
        let project = Project()
        project.id = parseProject.valueForKey("objectId") as? String
        project.name = parseProject.valueForKey("name") as? String
        project.createdAt = parseProject.createdAt
        project.desc = parseProject.valueForKey("desc") as? String
        project.commercial = parseProject.valueForKey("commercial") as? Bool
        
        if let status = parseProject.valueForKey("status") as? String {
            project.status =  status as String
        }
        
        let posRelation = parseProject.relationForKey("positions");
        let pPositions = posRelation.query().findObjects() as [PFObject]!
        var positions : [Position] = []
        for pPosition : PFObject in pPositions {
            let position = Position.parsePosition(pPosition)
            positions.append(position);
        }
        project.positions = positions
        
        let authorRelation = parseProject.relationForKey("author");
        let pAuthor = authorRelation.query().getFirstObject()
        let author = User.parseUser(pAuthor)
        project.author = author
        
        if (parseApplication) {
            let query = PFQuery(className: "Application")
            query.whereKey("project", equalTo: parseProject)
            let pApplications = query.findObjects() as [PFObject]
            
            var applications : [Application] = [];
            for pApplication : PFObject in pApplications {
                let application = Application.parseApplication(pApplication)
                application.project = project
                applications.append(application)
            }
            project.applications = applications
        }

        return project
    }
    
    class func serializeProject(project: Project) -> PFObject {
        
        var pProject : PFObject!
        
        if (project.id != nil) {
            let query : PFQuery = PFQuery(className: "Project")
            query.whereKey("objectId", equalTo: project.id)
            pProject = query.getFirstObject()
        }
        
        if (pProject == nil) {
            pProject = PFObject(className: "Project")
        }
        
        pProject.setIfNotNil(project.id, key: "objectId")
        pProject.setIfNotNil(project.name, key: "name")
        pProject.setIfNotNil(project.desc, key: "desc")
        pProject.setIfNotNil(project.status, key: "status")
        pProject.setIfNotNil(project.commercial, key: "commercial")
        
        if let positions = project.positions {
            let posRelation = pProject.relationForKey("positions");
            for pos : Position in positions {
                if (pos.id != nil) {
                    let query : PFQuery = PFQuery(className: "Position")
                    query.whereKey("objectId", equalTo: pos.id)
                    let pPos = query.getFirstObject()
                    if (pPos != nil) {
                        posRelation.addObject(pPos)
                    }
                } else {
                    let pPos = Position.serializePosition(pos)
                    pPos.save()
                    posRelation.addObject(pPos)
                }
            }
        }
        
        if let author = project.author {
            let authorRelation = pProject.relationForKey("author");
            if (author.id != nil) {
                let query : PFQuery = PFQuery(className: "User")
                query.whereKey("objectId", equalTo: author.id)
                let pAuthor = query.getFirstObject()
                if (pAuthor != nil) {
                    authorRelation.addObject(pAuthor)
                }
            } else {
                let pAuthor = User.serializeUser(author)
                pAuthor.save()
                authorRelation.addObject(pAuthor)
            }
        }
        
        return pProject
    }
    
    class func setParseProjectFields(pProject: PFObject, fromProject project: Project) {
        pProject.setIfNotNil(project.id, key: "objectId")
        pProject.setIfNotNil(project.name, key: "name")
        pProject.setIfNotNil(project.desc, key: "desc")
        pProject.setIfNotNil(project.status, key: "status")
        pProject.setIfNotNil(project.commercial, key: "commercial")
    }
}
