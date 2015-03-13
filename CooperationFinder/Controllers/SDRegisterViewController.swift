//
//  SDRegisterViewController.swift
//  CooperationFinder
//
//  Created by Radoslaw Szeja on 25.02.2015.
//  Copyright (c) 2015 Snowdog. All rights reserved.
//

import UIKit

@IBDesignable
class SDRegisterViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var emailField: UITextField?
    @IBOutlet weak var passwordField: UITextField?
    @IBOutlet weak var fullNameField: UITextField?
    @IBOutlet weak var serviceNameField: UITextField?
    @IBOutlet weak var phoneNumberField: UITextField?
    @IBOutlet weak var registerButton: UIButton?
    @IBOutlet weak var _scrollView: UIScrollView?
    var _restorationContentOffset: CGPoint?
    var backTapped : (() -> ())?
    var completion: (() -> ())?

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
        
        if let placeholder = fullNameField?.placeholder {
            fullNameField?.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSForegroundColorAttributeName: color])
        }
        
        if let placeholder = serviceNameField?.placeholder {
            serviceNameField?.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSForegroundColorAttributeName: color])
        }
        
        if let placeholder = phoneNumberField?.placeholder {
            phoneNumberField?.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSForegroundColorAttributeName: color])
        }
        
        registerButton?.layer.cornerRadius = 5.0
        registerButton?.layer.borderColor = UIColor(red: 6/255.0, green: 39/255.0, blue: 23/255.0, alpha: 1.0).CGColor
        registerButton?.layer.borderWidth = 1.0
    }
    
    @IBAction func registerButtonTapped(sender: UIButton) {
        
        if !self.allFieldsNotEmpty() {
            let alert = UIAlertView(title: NSLocalizedString("Oops", comment:""), message: NSLocalizedString("All fields cannot be empty", comment:""), delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            return
        }
        
        sender.addActivityIndicatorWithStyle(UIActivityIndicatorViewStyle.White)
        
        var user: User = User()
        user.email = emailField?.text
        user.company = serviceNameField?.text
        user.fullname = fullNameField?.text
        user.password = passwordField?.text
        user.phone = phoneNumberField?.text
        
        User.saveUser(user, completion: { (user, error) -> Void in
            sender.removeActivityIndicator()
            if user != nil {
                println("user id is: \(user?.id)")
                Defaults["user_id"] = user?.id
                Defaults.synchronize()
                self.dismissViewControllerAnimated(true) {
                    if let _completion = self.completion {
                        _completion()
                    }
                }
            } else {
                println("register error: \(error)")
            }
        })
    }
    
    @IBAction func dismissSelf(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        if let _backTapped = self.backTapped {
            _backTapped()
        }
    }
    
    func allFieldsNotEmpty() -> Bool {
        if let emailText = emailField?.text {
            if let passwordText = passwordField?.text {
                if let fullNameText = fullNameField?.text {
                    if let serviceNameText = serviceNameField?.text {
                        if let phoneNumberText = phoneNumberField?.text {
                            return !(emailText.isEmpty ||
                                passwordText.isEmpty ||
                                fullNameText.isEmpty ||
                                serviceNameText.isEmpty ||
                                phoneNumberText.isEmpty
                            )
                        }
                    }
                }
            }
        }
        
        return false
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.moveUpForTextfield(textField)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.moveToOriginalPosition()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == emailField {
            fullNameField?.becomeFirstResponder()
        } else if textField == fullNameField {
            phoneNumberField?.becomeFirstResponder()
        } else if textField == phoneNumberField {
            serviceNameField?.becomeFirstResponder()
        } else if textField == serviceNameField {
            passwordField?.becomeFirstResponder()
        } else if textField == passwordField {
            self.view.endEditing(true)
            if let registerButton = self.registerButton {
                self.registerButtonTapped(registerButton)
            }
        }
        
        return true
    }
    
}
