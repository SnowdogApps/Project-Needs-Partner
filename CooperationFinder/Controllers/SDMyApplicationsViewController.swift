//
//  SDMyApplicationsViewController.swift
//  CooperationFinder
//
//  Created by Rafal Kwiatkowski on 10.03.2015.
//  Copyright (c) 2015 Snowdog. All rights reserved.
//

import UIKit

class SDMyApplicationsViewController: UITableViewController {

    var myApplications : [Application] = []
    var applicationsToMyProjects : [Application] = []
    var loggedUserId : String?
    var onceToken : dispatch_once_t = 0
    var sizingCell : SDApplicationCell?
    
    var applications: [Application] {
        get {
            return self.myApplications + self.applicationsToMyProjects
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if let userId = Defaults["user_id"].string {
            self.loggedUserId = userId
            
            Application.getMyApplications() {(success, applications) -> Void in
                self.myApplications.removeAll(keepCapacity: true)
                if let apps = applications {
                    self.myApplications += apps
                }
                
                Application.getApplicationsToMyProjects() { (success, applications) -> Void in
                    self.applicationsToMyProjects.removeAll(keepCapacity: true)
                    if let apps = applications {
                        self.applicationsToMyProjects += apps
                    }
                    self.tableView.reloadData()
                }
            }
            
        } else {
            self.loggedUserId = nil
            self.myApplications.removeAll(keepCapacity: true)
            self.applicationsToMyProjects.removeAll(keepCapacity: true)
            self.tableView.reloadData()
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return (self.myApplications.count > 0 ? self.myApplications.count : 1)
        } else if (section == 1) {
            return (self.applicationsToMyProjects.count > 0 ? self.applicationsToMyProjects.count : 1)
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height : CGFloat = 80.0
        if let application = self.applicationForIndexPath(indexPath) {
            dispatch_once(&onceToken, { () -> Void in
                self.sizingCell = tableView.dequeueReusableCellWithIdentifier("ApplicationCell") as? SDApplicationCell
            })
            self.configureApplicationCell(self.sizingCell!, application: application)
            self.sizingCell?.bounds = CGRectMake(0.0, 0.0, tableView.bounds.size.width, 0.0)
            self.sizingCell?.setNeedsLayout()
            self.sizingCell?.layoutIfNeeded()
            self.sizingCell?.projectLabel?.preferredMaxLayoutWidth = self.sizingCell!.projectLabel!.bounds.size.width
            let size = self.sizingCell?.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
            height = size!.height
        }
        return height
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell!
        if let application = self.applicationForIndexPath(indexPath) {
            let appCell = tableView.dequeueReusableCellWithIdentifier("ApplicationCell") as SDApplicationCell!
            self.configureApplicationCell(appCell, application: application)
            cell = appCell
        } else {
            let placeholderCell = tableView.dequeueReusableCellWithIdentifier("PlaceholderCell") as SDPlaceholderCell!
            placeholderCell.titleLabel?.text = NSLocalizedString("There are no applications", comment: "")
            cell = placeholderCell
        }
        
        return cell
    }
    
    func configureApplicationCell(cell: SDApplicationCell, application:Application) {
        let username = application.user?.id == self.loggedUserId ? "My" : application.user?.fullname
        if (username == nil) {
            username == ""
        }
        
        cell.nameLabel?.text = username! + " " + NSLocalizedString("application for", comment:"")
        cell.projectLabel.text = application.project?.name
        cell.statusLabel.text = application.humanReadableStatus()
        cell.statusImageView.image = UIImage(named:application.statusIconName())
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {
            return NSLocalizedString("My applications", comment: "")
        } else if (section == 1) {
            return NSLocalizedString("Applications to my projects", comment: "")
        }
        
        return nil
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if (indexPath.section == 0) {
            let application = self.applicationForIndexPath(indexPath)
            if (application?.project != nil) {
                self.performSegueWithIdentifier("ProjectDetailsSegue", sender: nil)
            } else {
                let alert = UIAlertView(title: NSLocalizedString("Oops", comment:""), message: NSLocalizedString("Project does not exist", comment:""), delegate: nil, cancelButtonTitle: "OK")
                alert.show()
            }
        } else {
            self.performSegueWithIdentifier("CandidateSegue", sender: nil)
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let indexPathRow = self.tableView.indexPathForSelectedRow()
        if let indexPath = indexPathRow {
            let application = self.applicationForIndexPath(indexPath)
            if segue.identifier == "CandidateSegue" {
                if let controller = segue.destinationViewController as? SDCandidateDetailsViewController {
                    controller.application = application
                }
            } else if segue.identifier == "ProjectDetailsSegue" {
                if let controller = segue.destinationViewController as? SDProjectDetailsViewController {
                    controller.project = application?.project
                }
            }
        }
        
    }
    
    func applicationForIndexPath(indexPath : NSIndexPath) -> Application? {
        var application : Application?
        if (indexPath.section == 0) {
            application = (self.myApplications.count > 0 ? self.myApplications[indexPath.row] : nil)
        } else {
            application = (self.applicationsToMyProjects.count > 0 ? self.applicationsToMyProjects[indexPath.row] : nil)
        }
        return application
    }
    
    @IBAction func unwindToCandidatesList(segue: UIStoryboardSegue) {
        
    }

}
