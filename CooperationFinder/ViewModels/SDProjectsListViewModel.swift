//
//  SDProjectsListViewModel.swift
//  CooperationFinder
//
//  Created by Radoslaw Szeja on 25.02.2015.
//  Copyright (c) 2015 Snowdog. All rights reserved.
//

import UIKit

protocol SDListProtocol {
    func numberOfSectionsAtIndexPath() -> Int
    func numberOfRowsInSection(section: Int) -> Int
    func itemAtIndexpath(indexPath: NSIndexPath) -> Project?
}

protocol SDListViewModelDelegate : class {
    func didReloadData(count: Int)
}

class SDProjectsListViewModel: NSObject, SDListProtocol {
    
    var tags : [String]?
    var status : String?
    var trustedOnly : Bool?
    var commercial : Bool?
    var loggedUser : User?
    
    var itemsArray: [AnyObject] = []
    var searchItemsArray: [AnyObject] = []
    
    private var queryIndex = 0;
    private var searchQueryIndex = 0;
    
    weak private var delegate: SDListViewModelDelegate?
    
    
    override init() {
        self.delegate = nil
        super.init()
    }
    
    init(delegate: SDListViewModelDelegate) {
        self.delegate = delegate
        super.init()
    }
    
    func reloadData(searchQuery: String) {
        self.queryIndex++
        let q = self.queryIndex
        
        let getProjectsBlock : () -> Void = {
            
            Project.getProjects(nil, searchPhrase:searchQuery, tags: self.tags, statuses: self.statuses(), commercial: self.commercial, partner: self.trustedOnly) { (success, projects) -> Void in
                if let projs = projects {
                    self.itemsArray = projs
                } else {
                    self.itemsArray = []
                }
                Async.main {
                    if (q == self.queryIndex) {
                        if let del = self.delegate {
                            del.didReloadData(self.itemsArray.count)
                        }
                    }
                }
            }
        }
        
        if (self.loggedUser != nil) {
            getProjectsBlock()
        } else {
            User.getLoggedUser(completion: { (user) -> () in
                self.loggedUser = user
                getProjectsBlock()
            })
        }
    }
    
    func statuses() -> [String] {
        var statuses : [String] = []
        
        if self.status != nil {
            statuses.append(self.status!)
        } else {
            statuses.append(ProjectStatusOpen)
            if let user = self.loggedUser {
                if (user.role == UserRoleModerator) {
                    statuses.append(ProjectStatusWaitingForApproval)
                }
            }
        }
        
        return statuses
    }
    
    // MARK: SDListProtocol
    func numberOfSectionsAtIndexPath() -> Int {
        return 1
    }
    
    func numberOfRowsInSection(section: Int) -> Int {
        if section == 0 {
            return itemsArray.count
        }
        return 0
    }
    
    func numberOfRowsInSearchSection(section: Int) -> Int {
        if section == 0 {
            return searchItemsArray.count
        }
        return 0
    }
    
    func itemAtIndexpath(indexPath: NSIndexPath) -> Project? {
        return itemsArray[indexPath.row] as? Project
    }
    
    func searchItemAtIndexPath(indexPath:NSIndexPath) -> Project? {
        return searchItemsArray[indexPath.row] as? Project
    }
    
    func searchWithPhrase(phrase: String, completion: (success: Bool) -> ()) {
        self.searchQueryIndex++
        let q = self.searchQueryIndex
        Project.getProjects(nil, searchPhrase:phrase, tags: nil, statuses: self.statuses(), commercial: nil, partner: nil) { (success, projects) -> Void in
            if let projs = projects {
                self.searchItemsArray = projs
            } else {
                self.searchItemsArray = []
            }
            Async.main {
                if (q == self.searchQueryIndex) {
                    completion(success: success)
                }
            }
        }

    }
}
