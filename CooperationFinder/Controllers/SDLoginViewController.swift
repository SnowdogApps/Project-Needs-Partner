//
//  SDLoginViewController.swift
//  CooperationFinder
//
//  Created by Radoslaw Szeja on 25.02.2015.
//  Copyright (c) 2015 Snowdog. All rights reserved.
//

import UIKit

class SDLoginViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var emailField: UITextField?
    @IBOutlet weak var passwordField: UITextField?
    @IBOutlet weak var signInButton: UIButton?
    @IBOutlet weak var _scrollView: UIScrollView?
    var completion: (() -> ())?
    var signUpTapped: (() -> ())?
    
    var _restorationContentOffset: CGPoint?

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
        var color = UIColor(red: 113/255.0, green: 145/255.0, blue: 145/255.0, alpha: 1.0)
        if let placeholder = emailField?.placeholder {
            emailField?.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSForegroundColorAttributeName: color])
        }
        
        if let placeholder = passwordField?.placeholder {
            passwordField?.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSForegroundColorAttributeName: color])
        }
        
        signInButton?.layer.cornerRadius = 5.0
        signInButton?.layer.borderColor = UIColor(red: 6/255.0, green: 39/255.0, blue: 23/255.0, alpha: 1.0).CGColor
        signInButton?.layer.borderWidth = 1.0
    }
    
    @IBAction func signInButtonTapped(sender: UIButton) {
        sender.addActivityIndicatorWithStyle(UIActivityIndicatorViewStyle.White)
        
        let email : String! = emailField?.text
        let password : String! = passwordField?.text
        
        if email != nil && password != nil && !email.isEmpty && !password.isEmpty {
            User.login(email, password: password) { (success, user) -> Void in
                sender.removeActivityIndicator()
                if success == true && user != nil{
                    Defaults["user_id"] = user?.id
                    Defaults.synchronize()
                    self.dismissViewControllerAnimated(true) {
                        if let _completion = self.completion {
                            _completion()
                        }
                    }
                } else {
                    let alert = UIAlertView(title: NSLocalizedString("Oops", comment: ""), message: NSLocalizedString("Failed to log in. Check if user name and password are correct", comment: ""), delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                }
            }
        } else {
            sender.removeActivityIndicator()
            let alert = UIAlertView(title: NSLocalizedString("Oops", comment: ""), message: NSLocalizedString("User name and password cannot be empty", comment: ""), delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
    }
    
    @IBAction func dismissSelf(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func createAccountButtonTapped(sender: AnyObject) {
        if let _signUpTapped = self.signUpTapped {
            _signUpTapped()
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.moveUpForTextfield(textField)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.moveToOriginalPosition()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField?.becomeFirstResponder()
        } else {
            self.view.endEditing(true)
            if let signInButton = self.signInButton {
                self.signInButtonTapped(signInButton)
            }
        }
        return true
    }
}
