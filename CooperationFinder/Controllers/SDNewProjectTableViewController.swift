//
//  SDNewFileTableViewController.swift
//  CooperationFinder
//
//  Created by Rafal Kwiatkowski on 26.02.2015.
//  Copyright (c) 2015 Snowdog. All rights reserved.
//

import UIKit

class SDNewProjectTableViewController: UITableViewController, UITextFieldDelegate, UITextViewDelegate, SDAddPositionViewControllerDelegate {
    
    var project : Project = Project()
    var onceToken : dispatch_once_t = 0
    var sizingCell : SDPositionCell?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.project.commercial = false
        let user : User = User()
        let userId = Defaults["user_id"].string
        user.id = userId
        self.project.author = user
        self.project.positions = []
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 1
        } else if (section == 1) {
            return 1
        } else if (section == 2) {
            return 1
        } else if (section == 3) {
            var counter = 1
            if let kPos = self.project.positions {
                counter += kPos.count
            }
            return counter
        } else {
            return 0
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell = UITableViewCell()
        if (indexPath.section == 0) {
            let textfieldCell = tableView.dequeueReusableCellWithIdentifier("SDTextFieldCell", forIndexPath: indexPath) as SDTextFieldCell
            textfieldCell.textField?.text = self.project.name
            textfieldCell.textField?.placeholder = "Project name"
            textfieldCell.textField?.addTarget(self, action: "tfValueChanged:", forControlEvents: UIControlEvents.EditingChanged)
            cell = textfieldCell
        } else if (indexPath.section == 1) {
            let textViewCell = tableView.dequeueReusableCellWithIdentifier("SDTextViewCell", forIndexPath: indexPath) as SDTextViewCell
            textViewCell.textView.delegate = self
            textViewCell.textView.text = self.project.desc
            cell = textViewCell
        } else if (indexPath.section == 2) {
            let switchCell = tableView.dequeueReusableCellWithIdentifier("SwitchCell", forIndexPath: indexPath) as SwitchCell
            switchCell.titleLabel.text = "Commercial"
            switchCell.switchView.setOn(self.project.commercial? == true, animated: false)
            switchCell.switchView.addTarget(self, action: "switchDidChange:", forControlEvents: UIControlEvents.ValueChanged)
            cell = switchCell
        } else if (indexPath.section == 3) {
            
            var counter = 1
            if let kPos = self.project.positions {
                counter += kPos.count
            }
            
            if (indexPath.row == (counter - 1)) {
                cell = tableView.dequeueReusableCellWithIdentifier("StandardCell", forIndexPath: indexPath) as UITableViewCell
                cell.textLabel?.text = "Add job offer"
            } else {
                
                let position = self.project.positions![indexPath.row]
                var positionCell = tableView.dequeueReusableCellWithIdentifier("SDPositionCell", forIndexPath: indexPath) as SDPositionCell
                self.configurePositionCell(positionCell, position: position)
                
                cell = positionCell
            }
        }

        return cell
    }

    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 1) {
            return "Description"
        }
        
        return nil
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height : CGFloat = 44.0
        
        var counter = 1
        if let kPos = self.project.positions {
            counter += kPos.count
        }
        
        if (indexPath.section == 1) {
            height = 200.0
        } else if (indexPath.section == 3 && indexPath.row < counter - 1) {
            dispatch_once(&onceToken, { () -> Void in
                self.sizingCell = tableView.dequeueReusableCellWithIdentifier("SDPositionCell") as? SDPositionCell
            })
            
            let position = self.project.positions![indexPath.row]
            self.configurePositionCell(self.sizingCell!, position: position)
            self.sizingCell?.bounds = CGRectMake(0.0, 0.0, tableView.bounds.size.width, 0.0)
            self.sizingCell?.setNeedsLayout()
            self.sizingCell?.layoutIfNeeded()
            self.sizingCell?.titleLabel?.preferredMaxLayoutWidth = self.sizingCell!.titleLabel!.bounds.size.width
            let size = self.sizingCell?.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
            height = size!.height
        }
        
        return CGFloat(height)
    }
    
    func configurePositionCell(cell: SDPositionCell, position: Position) {
        cell.titleLabel?.text = position.name
        if let tags = position.tags {
            cell.tagCloudView?.tags = tags
        }
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        var counter = 1
        if let kPos = self.project.positions {
            counter += kPos.count
        }
        
        if (indexPath.section == 3 && indexPath.row == counter - 1) {
            self.performSegueWithIdentifier("AddPositionSegue", sender: self)
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "AddPositionSegue") {
            var destController = segue.destinationViewController as SDAddPositionViewController
            destController.delegate = self
        }
    }


    func tfValueChanged(sender : UITextField) {
        self.project.name = sender.text
    }
    
    func textViewDidChange(textView: UITextView) {
        self.project.desc = textView.text
    }
    
    func switchDidChange(sender: UISwitch) {
        self.project.commercial = sender.on
    }

    @IBAction func saveButtonTapped(sender: AnyObject) {
        
        let validateResult = self.validateProject()
        
        if (validateResult.error) {
            let alert = UIAlertView(title: NSLocalizedString("Oops", comment:""), message: validateResult.errorText, delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        } else {
            Project.saveProject(self.project, completion: { (success) -> Void in
                if (!success) {
                    let alertView = UIAlertView(title: "Oops", message: "Failed to create a project", delegate: nil, cancelButtonTitle: "OK")
                    alertView.show()
                } else {
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            })
        }
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func unwindToNewProject(segue:UIStoryboardSegue) {
        
    }
    
    // MARK: SDAddPositionViewControllerDelegate
    
    func setPosition(position: Position) {
        self.project.positions?.append(position)
        self.tableView.reloadData()
    }
    
    
    // MARK: Validation
    
    func validateProject() -> (error: Bool, errorText: String?) {
        
        var errorText = ""
        var error = false
        var nameEmpty = NSLocalizedString("Project name cannot be empty", comment: "")
        if let name = self.project.name {
            if (countElements(name) == 0) {
                errorText += (nameEmpty + "\n")
                error = true
            }
        } else {
            errorText += (nameEmpty + "\n")
            error = true
        }
        
        if (project.positions?.count == 0) {
            errorText += NSLocalizedString("Add at least one job offer to the project", comment: "")
            error = true
        }
        
        return (error, errorText)
    }
        
    
}
