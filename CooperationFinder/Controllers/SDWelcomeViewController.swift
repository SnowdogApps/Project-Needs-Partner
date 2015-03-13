//
//  SDWelcomeViewController.swift
//  CooperationFinder
//
//  Created by Radoslaw Szeja on 25.02.2015.
//  Copyright (c) 2015 Snowdog. All rights reserved.
//

import UIKit

class SDWelcomeViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var searchField: UITextField?
    @IBOutlet weak var _scrollView: UIScrollView?
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var browseAllButton: UIButton!

    var _restorationContentOffset: CGPoint?
    var showAddNewProject : Bool = false

    override var scrollView: UIScrollView! {
        get { return _scrollView! }
        set { }
    }
    
    override var restorationContentOffset: CGPoint {
        get {
            if let offset = _restorationContentOffset {
                return offset
            }
            return CGPointZero
        }
        set { _restorationContentOffset = newValue }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let placeholder = searchField?.placeholder {
            var color = UIColor(red: 113/255.0, green: 145/255.0, blue: 145/255.0, alpha: 1.0)
            searchField?.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSForegroundColorAttributeName: color])
        }   
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.refreshSignInButton()
    }
    
    func refreshSignInButton() {
        if let userID = Defaults["user_id"].string {
            self.signInButton.setTitle(NSLocalizedString("Sign out", comment:""), forState:UIControlState.Normal)
        } else {
            self.signInButton.setTitle(NSLocalizedString("Sign in", comment:""), forState:UIControlState.Normal)
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.moveUpForTextfield(textField)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.moveToOriginalPosition()
    }

    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.text.isEmpty == false {
            self.performSegueWithIdentifier("projectsSegue", sender: self)
            return true
        }
        return false
    }
    
    @IBAction func browseAllButtonTapped(sender: UIButton) {
        searchField?.text = nil
        self.performSegueWithIdentifier("projectsSegue", sender: self)
    }
    
    @IBAction func addNewOneTapped(sender: UIButton) {
        if let userID = Defaults["user_id"].string {
            self.performSegueWithIdentifier("addNewProjectSegue", sender: self)
        } else {
            self.showAddNewProject = true
            self.performSegueWithIdentifier("loginSegue", sender: self)
        }
    }
    
    @IBAction func signInButtonTapped(sender: AnyObject) {
        if let userID = Defaults["user_id"].string {
            Defaults["user_id"] = nil
            self.refreshSignInButton()
        } else {
            self.showAddNewProject = false
            self.performSegueWithIdentifier("loginSegue", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "projectsSegue" {
            if let tabBarVC = segue.destinationViewController as? UITabBarController {
                if let navVC = tabBarVC.viewControllers?.first as? UINavigationController {
                    if let controller = navVC.viewControllers.first as? SDProjectsListViewController {
                        controller.searchPhrase = searchField?.text
                    }
                }
            }
        } else if segue.identifier == "loginSegue" {
            if let controller = segue.destinationViewController as? SDLoginPageViewController {
                
                if self.showAddNewProject {
                    controller.completion = {
                        self.performSegueWithIdentifier("addNewProjectSegue", sender: self)
                    }
                }
            }
        }
    }
}
