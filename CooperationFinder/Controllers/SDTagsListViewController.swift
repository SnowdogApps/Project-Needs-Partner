//
//  SDTagsListViewController.swift
//  CooperationFinder
//
//  Created by Rafal Kwiatkowski on 26.02.2015.
//  Copyright (c) 2015 Snowdog. All rights reserved.
//

import UIKit

protocol SDTagsListViewControllerDelegate : class {
    
    func applyTags(tags: [String]?)
    
}

class SDTagsListViewController: UITableViewController {

    
    private var _selectedTags : [String]?
    private var _tags : [String]?
    
    var selectedTags : [String]? {
        get {
            if _selectedTags == nil {
                _selectedTags = []
            }
            return _selectedTags
        }
        set {
            _selectedTags = newValue
        }
    }
    
    var tags : [String]? {
        get {
            if _tags == nil {
                _tags = []
            }
            return _tags
        }
        set {
            _tags = newValue
        }
    }
    
     weak var delegate : SDTagsListViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var myArray: NSArray?
        let path = NSBundle.mainBundle().pathForResource("TagList", ofType: "plist")
        myArray = NSArray(contentsOfFile: path!)
        
        self.tags = myArray as! [String]?
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.delegate?.applyTags(self.selectedTags)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.tags!.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("StandardCell", forIndexPath: indexPath) as! UITableViewCell
        
        let tag = self.tags![indexPath.row]
        cell.textLabel?.text = tag
        
        if let selTags = self.selectedTags {
            if (contains(selTags, tag)) {
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            } else {
                cell.accessoryType = UITableViewCellAccessoryType.None
            }
        }
        
        return cell
    }

    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let tag = self.tags![indexPath.row]
        if (self.selectedTags == nil) {
            self.selectedTags = [];
        }
        if (contains(self.selectedTags!, tag) == false) {
            self.selectedTags!.append(tag)
        } else {
            var index = 0
            for t in self.selectedTags! {
                if (t == tag) {
                    break;
                }
                index++
            }
            if (index < self.selectedTags?.count) {
                self.selectedTags?.removeAtIndex(index)
            }
            
        }
        self.tableView.reloadData()
    }

}
