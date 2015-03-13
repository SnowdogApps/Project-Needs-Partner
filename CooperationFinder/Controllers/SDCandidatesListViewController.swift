//
//  SDCandidatesListViewController.swift
//  CooperationFinder
//
//  Created by Radoslaw Szeja on 26.02.2015.
//  Copyright (c) 2015 Snowdog. All rights reserved.
//

import UIKit

class SDCandidatesListViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource {
    
    var waitingApplications : [Application] = []
    var approvedApplications : [Application] = []
    private var _applications : [Application] = []
    private var _project : Project!
    
    var applications: [Application] {
        get {
            return _applications
        }
        set {
            _applications = newValue
            
            waitingApplications.removeAll(keepCapacity: true)
            approvedApplications.removeAll(keepCapacity: true)
            for application in _applications {
                if (application.status == nil || application.status!.isEmpty) {
                    waitingApplications.append(application)
                } else if (application.status == ApplicationStatusApproved) {
                    approvedApplications.append(application)
                }
            }
        }
    }
    
    var project: Project! {
        get {
            return _project
        } set {
            _project = newValue
            if (_project.applications != nil) {
                self.applications = _project.applications!
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        Application.getApplicationsOfUser(nil, toProject: self.project) { (success, applications) -> Void in
            self.applications.removeAll(keepCapacity: true)
            if (applications != nil) {
                self.applications = applications!
            }
            self.tableView.reloadData()
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return (self.waitingApplications.count > 0 ? self.waitingApplications.count : 1)
        } else if (section == 1) {
            return (self.approvedApplications.count > 0 ? self.approvedApplications.count : 1)
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell!
        if let application = self.applicationForIndexPath(indexPath) {
            let appCell = tableView.dequeueReusableCellWithIdentifier("CandidateCell") as SDCandidateCell!
            appCell.nameLabel?.text = application.user?.fullname
            appCell.companyLabel?.text = application.user?.company
            cell = appCell
        } else {
            let placeholderCell = tableView.dequeueReusableCellWithIdentifier("PlaceholderCell") as SDPlaceholderCell!
            placeholderCell.titleLabel?.text = NSLocalizedString("There are no applications", comment: "")
            cell = placeholderCell
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {
            return NSLocalizedString("Waiting applications", comment: "")
        } else if (section == 1) {
            return NSLocalizedString("Approved applications", comment: "")
        }
        
        return nil
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "candidatesSegue" {
            if let controller = segue.destinationViewController as? SDCandidateDetailsViewController {
                let indexPathRow = self.tableView.indexPathForSelectedRow()
                if let indexPath = indexPathRow {
                    let application = self.applicationForIndexPath(indexPath)
                    controller.application = application
                }
            }
            
        }
    }
    
    func applicationForIndexPath(indexPath : NSIndexPath) -> Application? {
        var application : Application?
        if (indexPath.section == 0) {
            application = (self.waitingApplications.count > 0 ? self.waitingApplications[indexPath.row] : nil)
        } else {
            application = (self.approvedApplications.count > 0 ? self.approvedApplications[indexPath.row] : nil)
        }
        return application
    }
    
    @IBAction func unwindToCandidatesList(segue: UIStoryboardSegue) {
        
    }
    
}
