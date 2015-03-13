//
//  SDProfileViewController.swift
//  CooperationFinder
//
//  Created by Radoslaw Szeja on 26.02.2015.
//  Copyright (c) 2015 Snowdog. All rights reserved.
//

import UIKit

class SDProfileViewController: UITableViewController, UITextViewDelegate, SDTagsListViewControllerDelegate {
    var loggedUser: User?
    
    @IBOutlet weak var emailField: UITextField?
    @IBOutlet weak var fullNameField: UITextField?
    @IBOutlet weak var serviceNameField: UITextField?
    @IBOutlet weak var phoneNumberField: UITextField?
    @IBOutlet weak var descriptionTextView: UITextView?
    
    var simpleDataSection = 0
    var descriptionSection = 1
    var tagsSection = 2
    
    let emailTag = 0
    let nameTag = 1
    let phoneTag = 2
    let companyTag = 3
    
    var once_token: dispatch_once_t = 0
    var sizingCell : SDTagsCell!
    var refreshFlag = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if (self.refreshFlag) {
            User.getLoggedUser(completion: { (user) -> () in
                self.loggedUser = user
                self.tableView.reloadData()
            })
        } else {
            self.refreshFlag = true
        }
    }
    
    @IBAction func saveButtonTapped(sender: UIBarButtonItem) {
        if let user = loggedUser {
            User.saveUser(user, completion: { (user, error) -> Void in
                if user != nil {
                    UIAlertView(title: "Success", message: "Your profile is updated", delegate: nil, cancelButtonTitle: "OK").show()
                } else {
                    UIAlertView(title: "Error", message: error?.description, delegate: nil, cancelButtonTitle: "OK").show()
                }                
            })
        }
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if (self.loggedUser != nil) {
            return 3
        }
        
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.loggedUser != nil) {
            if (section == self.simpleDataSection) {
                return 4
            } else if (section == self.descriptionSection) {
                return 1
            } else if (section == self.tagsSection) {
                return 1
            } else {
                return 0
            }
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell = UITableViewCell()
        
        if (indexPath.section == self.simpleDataSection) {
            cell = self.cellForSimpleDataSection(indexPath: indexPath)
        } else if (indexPath.section == self.descriptionSection) {
            let textViewCell = tableView.dequeueReusableCellWithIdentifier("SDTextViewCell", forIndexPath: indexPath) as SDTextViewCell
            textViewCell.textView.delegate = self
            textViewCell.textView.text = self.loggedUser?.desc
            textViewCell.textView.delegate = self
            cell = textViewCell
        } else if (indexPath.section == self.tagsSection) {
            let tagsCell = tableView.dequeueReusableCellWithIdentifier("SDTagsCell", forIndexPath: indexPath) as SDTagsCell
            tagsCell.titleLabel.text = NSLocalizedString("Skills", comment:"")
            tagsCell.tagCloudView.tags = self.loggedUser?.tags
            tagsCell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            cell = tagsCell
        } else {
            cell = UITableViewCell()
        }
        
        return cell
    }
    
    func cellForSimpleDataSection(#indexPath: NSIndexPath) -> UITableViewCell {
        let textfieldCell = tableView.dequeueReusableCellWithIdentifier("SDTextFieldCell", forIndexPath: indexPath) as SDTextFieldCell
        
        var title : String?
        var value : String?
        var tag : Int = -1
        
        switch indexPath.row {
        case 0:
            title = NSLocalizedString("Email", comment: "")
            value = self.loggedUser?.email
            tag = emailTag
        case 1:
            title = NSLocalizedString("Full name", comment: "")
            value = self.loggedUser?.fullname
            tag = nameTag
        case 2:
            title = NSLocalizedString("Phone", comment: "")
            value = self.loggedUser?.phone
            tag = phoneTag
        case 3:
            title = NSLocalizedString("Company", comment: "")
            value = self.loggedUser?.company
            tag = companyTag
        default:
            println()
        }
        
        textfieldCell.titleLabel?.text = title
        textfieldCell.textField?.text = value
        textfieldCell.textField?.tag = tag
        textfieldCell.textField?.addTarget(self, action: "tfValueChanged:", forControlEvents: UIControlEvents.EditingChanged)
        
        return textfieldCell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (self.loggedUser != nil) {
            if (section == self.simpleDataSection) {
                return NSLocalizedString("Your profile data", comment:"")
            } else if (section == self.descriptionSection) {
                return NSLocalizedString("Description", comment:"")
            }
            return nil
        }
        
        return NSLocalizedString("Please log in to view your profile", comment:"")
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height : CGFloat = 44.0
        
        if (indexPath.section == self.descriptionSection) {
            height = 120.0
        } else if (indexPath.section == self.tagsSection) {
            dispatch_once(&once_token, { () -> Void in
                self.sizingCell = self.tableView.dequeueReusableCellWithIdentifier("SDTagsCell") as SDTagsCell
            })
            self.sizingCell.tagCloudView.tags = self.loggedUser?.tags
            let size = self.sizingCell.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
            height = size.height
        }
        
        return CGFloat(height)
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if (indexPath.section == self.tagsSection) {
            self.performSegueWithIdentifier("TagsSegue", sender: nil)
        }
    }
    
    
    func tfValueChanged(sender : UITextField) {
        switch sender.tag {
        case emailTag:
            self.loggedUser?.email = sender.text
        case nameTag:
            self.loggedUser?.fullname = sender.text
        case phoneTag:
            self.loggedUser?.phone = sender.text
        case companyTag:
            self.loggedUser?.company = sender.text
        default:
            return
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        self.loggedUser?.desc = textView.text
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "TagsSegue") {
            var controller = segue.destinationViewController as SDTagsListViewController
            controller.selectedTags = self.loggedUser?.tags
            controller.delegate = self
        }
    }
    
    @IBAction func dismissSelf(sender: AnyObject?) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: SDTagsListViewControllerDelegate
    
    func setTags(tags: [String]?) {
        self.loggedUser?.tags = tags
        self.refreshFlag = false
        self.tableView.reloadData()
    }
    
}
