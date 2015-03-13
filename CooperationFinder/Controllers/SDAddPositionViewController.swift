//
//  SDAddPositionViewController.swift
//  CooperationFinder
//
//  Created by Rafal Kwiatkowski on 26.02.2015.
//  Copyright (c) 2015 Snowdog. All rights reserved.
//

import UIKit

protocol SDAddPositionViewControllerDelegate : class {
    
    func setPosition(position: Position)
}

class SDAddPositionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    weak var delegate : SDAddPositionViewControllerDelegate?
    
    var position : Position = Position()
    var tags : [String] = []
    var selectedTags : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var myArray: NSArray?
        let path = NSBundle.mainBundle().pathForResource("TagList", ofType: "plist")
        myArray = NSArray(contentsOfFile: path!)
        
        self.tags = myArray as [String]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tags.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("StandardCell", forIndexPath: indexPath) as UITableViewCell
        
        let tag = self.tags[indexPath.row]
        cell.textLabel?.text = tag
        
        if (contains(self.selectedTags, tag)) {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let tag = self.tags[indexPath.row]

        if (contains(self.selectedTags, tag) == false) {
            self.selectedTags.append(tag)
        } else {
            var index = 0
            for t in self.selectedTags {
                if (t == tag) {
                    break;
                }
                index++
            }
            if (index < self.selectedTags.count) {
                self.selectedTags.removeAtIndex(index)
            }
            
        }
        self.tableView.reloadData()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @IBAction func addButtonTapped(sender: AnyObject) {
        self.position.name = self.textField.text
        self.position.tags = self.selectedTags
        
        let validateResult = self.validatePosition()
        
        if (validateResult.error) {
            let alert = UIAlertView(title: NSLocalizedString("Oops", comment:""), message: validateResult.errorText, delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        } else {
            self.delegate?.setPosition(self.position)
            self.performSegueWithIdentifier("UnwindToNewProjectSegue", sender: self)
        }
    }
    
    func validatePosition() -> (error: Bool, errorText: String?) {
        
        var errorText = ""
        var error = false
        var nameEmpty = NSLocalizedString("Position name cannot be empty", comment: "")
        if let name = self.position.name {
            if (countElements(name) == 0) {
                errorText += (nameEmpty + "\n")
                error = true
            }
        } else {
            errorText += (nameEmpty + "\n")
            error = true
        }
        
        if (self.position.tags?.count == 0) {
            errorText += NSLocalizedString("Add at least one tag", comment: "")
            error = true
        }
        
        return (error, errorText)
    }
}
