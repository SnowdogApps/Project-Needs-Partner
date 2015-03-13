//
//  SDProjectDetailsViewController.swift
//  CooperationFinder
//
//  Created by Radoslaw Szeja on 26.02.2015.
//  Copyright (c) 2015 Snowdog. All rights reserved.
//

import UIKit

class SDProjectDetailsViewController : UIViewController{
    
    @IBOutlet weak var dateLabel : UILabel?
    @IBOutlet weak var commercialLabel: SDBadgeLabel!
    @IBOutlet weak var trustedLabel: SDBadgeLabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var positionsLabel: UILabel!
    @IBOutlet weak var tagCloudView : TagCloudView!
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var approveButton: UIButton!
    @IBOutlet weak var denyButton: UIButton!
    @IBOutlet weak var applyButton: UIButton!
    @IBOutlet weak var candidatesButton: UIButton!
    @IBOutlet weak var archiveButton: UIButton!

    
    var project: Project?
    var loggedUser: User?
    var myApplications: [Application] = []
    var candidatesSection: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.trustedLabel.fillColor = UIColor(red: 243/255.0, green: 143/255.0, blue: 39/255.0, alpha: 1.0)
        self.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

    }
    
     override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.refreshDataWithCompletion { () -> () in
            self.reloadData()
        }
    }
    
    func refreshDataWithCompletion(completion : () -> ()) {
        User.getLoggedUser { (user) -> () in
            self.loggedUser = user
            if (self.loggedUser != nil) {
                Application.getApplicationsOfUser(self.loggedUser!, toProject: self.project!, completion: { (success, applications) -> Void in
                    if let apps = applications {
                        self.myApplications = apps
                    }
                    completion()
                })
            } else {
                completion()
            }
        }
    }
    
    func reloadData() {
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.ShortStyle
        formatter.timeStyle = NSDateFormatterStyle.NoStyle
        
        if let date = self.project?.createdAt {
            self.dateLabel?.text = formatter.stringFromDate(date)
        }
        
        if (self.project?.author?.partner == true) {
            self.trustedLabel.hidden = false;
        } else {
            self.trustedLabel.hidden = true;
        }
        
        if (self.project?.commercial == true) {
            self.commercialLabel.hidden = false;
        } else {
            self.commercialLabel.hidden = true;
        }
        
        self.authorLabel?.text = project?.author?.nameAndCompany()
        self.titleLabel.text = project?.name
        self.descLabel.text = project?.desc
        
        var tags : [String] = []
        var positionStr : String = "Job positions:"
        if let positions = self.project?.positions {
            for position : Position in positions {
                
                if let t = position.tags {
                    for tag in t {
                        tags.append(tag)
                    }
                }
                
                if let name = position.name {
                    positionStr += ("\n- \(name)")
                }
            }
        }
        
        self.tagCloudView.tags = tags
        self.positionsLabel.text = positionStr
        self.deleteButton?.hidden = true
        self.archiveButton?.hidden = true
        self.approveButton?.hidden = true
        self.denyButton?.hidden = true
        self.applyButton?.hidden = true
        self.candidatesButton?.hidden = true
        
        if project?.author?.id == Defaults["user_id"].string {
            self.candidatesButton?.hidden = false
            self.deleteButton?.hidden = false
            self.archiveButton?.hidden = false
            
            if (project?.status != ProjectStatusArchived) {
                self.archiveButton?.setTitle(NSLocalizedString("archive", comment: ""), forState: UIControlState.Normal)
            } else {
                self.archiveButton?.setTitle(NSLocalizedString("open", comment: ""), forState: UIControlState.Normal)
            }
            
        } else if (self.loggedUser != nil) {
            
            let role = self.loggedUser?.role
            if (role == nil || role!.isEmpty || role == UserRoleOrdinary) {
                
                if (self.myApplications.count == 0) {
                    self.applyButton.hidden = false
                }
                
            } else if (role == UserRoleModerator) {
                
                self.approveButton.hidden = false
                self.denyButton.hidden = false
            }
        }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "CandidatesSegue" {
            if let controller = segue.destinationViewController as? SDCandidatesListViewController {
                if let applications = self.project?.applications {
                    controller.project = self.project
                }
            }
        }
    }
    
    func showApplyButton() {
        
    }
    
    func saveProject(completion: ((success : Bool)->())) {
        if let project = self.project {
            Project.saveProject(project, completion: { (success) -> Void in
                completion(success: success)
            })
        } else {
            completion(success: false)
        }
    }
    
    func deleteProject(completion: ((success : Bool)->())) {
        if let project = self.project {
            Project.deleteProject(project, completion: { (success) -> Void in
                completion(success: success)
            })
        } else {
            completion(success: false)
        }
    }
    
    func applyToProject(completion: ((success : Bool)->())) {
        
        let application = Application()
        application.user = self.loggedUser
        application.project = self.project
        Application.saveApplication(application, completion: { (success) -> Void in
            completion(success: success)
        })
    }
    
    @IBAction func approveButtonTapped(sender: AnyObject) {
        self.project?.status = ProjectStatusOpen
        self.approveButton.addActivityIndicator()
        self.saveProject { (success : Bool) -> () in
            if (!success) {
                let alertView = UIAlertView(title: NSLocalizedString("Oops", comment: ""), message: NSLocalizedString("Failed to save a project", comment: ""), delegate: nil, cancelButtonTitle: "OK")
                alertView.show()
                self.approveButton.removeActivityIndicator()
            } else {
                self.performSegueWithIdentifier("UnwindSegue", sender: self.deleteButton)
            }
        }
    }
    
    @IBAction func denyButtonTapped(sender: AnyObject) {
        self.project?.status = ProjectStatusRejected
        self.denyButton.addActivityIndicator()
        self.saveProject { (success : Bool) -> () in
            if (!success) {
                let alertView = UIAlertView(title: NSLocalizedString("Oops", comment: ""), message: NSLocalizedString("Failed to save a project", comment: ""), delegate: nil, cancelButtonTitle: "OK")
                alertView.show()
                self.denyButton.removeActivityIndicator()
            } else {
                self.performSegueWithIdentifier("UnwindSegue", sender: self.deleteButton)
            }
        }
    }
    
    @IBAction func deleteButtonTapped(sender: AnyObject) {
        self.deleteButton.addActivityIndicator()
        self.deleteProject({(success : Bool) -> () in
            if (!success) {
                let alertView = UIAlertView(title: NSLocalizedString("Oops", comment: ""), message: NSLocalizedString("Failed to delete a project", comment: ""), delegate: nil, cancelButtonTitle: "OK")
                alertView.show()
            } else {
                self.performSegueWithIdentifier("UnwindSegue", sender: self.deleteButton)
            }
            self.deleteButton.removeActivityIndicator()
        })
    }
    
    @IBAction func applyButtonTapped(sender: AnyObject) {
        self.applyButton.addActivityIndicator()
        self.applyToProject({(success : Bool) -> () in
            
            if (success) {
                self.refreshDataWithCompletion({ () -> () in
                    self.reloadData()
                    self.applyButton.removeActivityIndicator()
                })
            } else {
                let alertView = UIAlertView(title: NSLocalizedString("Oops", comment: ""), message: NSLocalizedString("Failed to apply to the project", comment: ""), delegate: nil, cancelButtonTitle: "OK")
                alertView.show()
                self.applyButton.removeActivityIndicator()
            }
        })
    }
    
    
    @IBAction func archiveButtonTapped(sender: AnyObject) {
        
        if (project?.status != ProjectStatusArchived) {
            self.project?.status = ProjectStatusArchived
        } else {
            self.project?.status = ProjectStatusOpen
        }
        
        self.archiveButton.addActivityIndicator()
        self.saveProject { (success : Bool) -> () in
            if (!success) {
                let alertView = UIAlertView(title: NSLocalizedString("Oops", comment: ""), message: NSLocalizedString("Failed to save a project", comment: ""), delegate: nil, cancelButtonTitle: "OK")
                alertView.show()
                self.archiveButton.removeActivityIndicator()
            } else {
                self.performSegueWithIdentifier("UnwindSegue", sender: self.deleteButton)
            }
        }
    }

}
