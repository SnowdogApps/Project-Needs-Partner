//
//  SDFilterViewController.swift
//  CooperationFinder
//
//  Created by Rafal Kwiatkowski on 26.02.2015.
//  Copyright (c) 2015 Snowdog. All rights reserved.
//

protocol SDFilterViewControllerDelegate : class {
    
    func setTags(tags: [String]?, status: String?, trustedOnly: Bool?, commercial: Bool?)
    
}

class SDFilterViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource, SDTagsListViewControllerDelegate {
    
    var tags : [String]? = []
    var status : String?
    var trustedOnly : Bool?
    var commercial : Bool?
    
    var onceToken : dispatch_once_t = 0
    var sizingCell : SDPositionCell?
    
    weak var delegate : SDFilterViewControllerDelegate?

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Tags"
        case 1:
            return "Status"
        default:
            return ""
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 2
        case 2:
            return 1
        case 3:
            return 2
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height : CGFloat = 44.0
        
        if (indexPath.section == 0) {
            dispatch_once(&onceToken, { () -> Void in
                self.sizingCell = tableView.dequeueReusableCellWithIdentifier("SDPositionCell") as? SDPositionCell
            })
            
            self.configurePositionCell(self.sizingCell!)
            self.sizingCell?.bounds = CGRectMake(0.0, 0.0, tableView.bounds.size.width, 0.0)
            self.sizingCell?.setNeedsLayout()
            self.sizingCell?.layoutIfNeeded()
            self.sizingCell?.titleLabel?.preferredMaxLayoutWidth = self.sizingCell!.titleLabel!.bounds.size.width
            let size = self.sizingCell?.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
            height = size!.height
        }
        
        return height
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("StandardCell") as UITableViewCell
        
        var text : String
        
        if (indexPath.section == 0) {
            var positionCell = tableView.dequeueReusableCellWithIdentifier("SDPositionCell", forIndexPath: indexPath) as SDPositionCell
            self.configurePositionCell(positionCell)
            cell = positionCell
        } else if (indexPath.section == 1) {
            cell.textLabel?.text = indexPath.row == 0 ? "Open" : "Archived"
            if (indexPath.row == 0) {
                cell.accessoryType = (self.status == ProjectStatusOpen ? UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None)
            } else {
                cell.accessoryType = (self.status == ProjectStatusArchived ? UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None)
            }
        } else if (indexPath.section == 2) {
            var switchCell = tableView.dequeueReusableCellWithIdentifier("SwitchCell") as? SwitchCell
            switchCell?.titleLabel.text = "Only trusted"
            switchCell?.switchView.setOn(self.trustedOnly? == true, animated: false)
            switchCell?.switchView.addTarget(self, action: "switchDidChange:", forControlEvents: UIControlEvents.ValueChanged)
            cell = switchCell!
        } else if (indexPath.section == 3) {
            cell.textLabel?.text = indexPath.row == 0 ? "Commercial" : "Non-commercial"
            if (indexPath.row == 0) {
                cell.accessoryType = (self.commercial == true ? UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None)
            } else {
                cell.accessoryType = (self.commercial == false ? UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None)
            }
        } else {
            cell.textLabel?.text = ""
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        return cell;
    }
    
    func configurePositionCell(cell: SDPositionCell) {
        cell.titleLabel?.text = NSLocalizedString("Skills", comment:"")
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        if let tags = self.tags {
            cell.tagCloudView?.tags = tags
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if (indexPath.section == 0) {
            self.performSegueWithIdentifier("TagsSegue", sender: self)
        } else if (indexPath.section == 1) {
            if (indexPath.row == 0 && self.status != ProjectStatusOpen) {
                self.status = ProjectStatusOpen
            } else if (indexPath.row == 1 && self.status != ProjectStatusArchived) {
                self.status = ProjectStatusArchived
            } else {
                self.status = nil
            }
            self.tableView.reloadData()
        } else if (indexPath.section == 3) {
            if (indexPath.row == 0) {
                if (self.commercial == false || self.commercial == nil) {
                    self.commercial = true
                } else {
                    self.commercial = nil
                }
            } else if (indexPath.row == 1) {
                if (self.commercial == true || self.commercial == nil) {
                    self.commercial = false
                } else {
                    self.commercial = nil
                }
            }
            self.tableView.reloadData()
        }
    }
    
    func switchDidChange(sender: UISwitch) {
        self.trustedOnly = sender.on
    }
    
    func setTags(tags: [String]?) {
        self.tags = tags
        self.tableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "UnwindSegue") {
            self.delegate?.setTags(self.tags, status: self.status, trustedOnly: self.trustedOnly, commercial: self.commercial)
        } else if (segue.identifier == "TagsSegue") {
            let destController = segue.destinationViewController as SDTagsListViewController
            destController.selectedTags = self.tags
            destController.delegate = self
        }
    }
    
    @IBAction func unwindToFilter(segue:UIStoryboardSegue) {
        
    }
}


