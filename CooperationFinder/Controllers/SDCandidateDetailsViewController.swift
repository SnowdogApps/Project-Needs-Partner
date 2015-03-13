//
//  SDCandidateDetailsViewController.swift
//  CooperationFinder
//
//  Created by Radoslaw Szeja on 26.02.2015.
//  Copyright (c) 2015 Snowdog. All rights reserved.
//

import UIKit

class SDCandidateDetailsViewController: UIViewController {
    @IBOutlet weak var userFullName: UILabel?
    @IBOutlet weak var approveButton: UIButton?
    @IBOutlet weak var denyButton: UIButton?
    @IBOutlet weak var descriptionView: UILabel?
    @IBOutlet var titleTop: NSLayoutConstraint!
    @IBOutlet var tagCloudView : TagCloudView!
    
    var application: Application?
    var canDecide: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var a : UIView?
        
        self.tagCloudView.tags = self.application?.user?.tags
        
        if (self.application?.status == ApplicationStatusApproved || self.application?.status == ApplicationStatusRejected) {
            self.approveButton?.hidden = true
            self.denyButton?.hidden = true
            self.titleTop.constant = 16.0
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        userFullName?.text = application?.user?.nameAndCompany()
        descriptionView?.text = application?.user?.desc
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    @IBAction func approveButtonTapped(sender: UIButton) {
        application?.status = ApplicationStatusApproved
        approveButton?.enabled = false
        denyButton?.enabled = true
        approveButton?.addActivityIndicator()
        Application.saveApplication(application!, completion: { (success: Bool) -> Void in
            if success == true {
                self.performSegueWithIdentifier("UnwindSegue", sender: self)
            } else {
                let alertView = UIAlertView(title: NSLocalizedString("Oops", comment: ""), message: NSLocalizedString("Failed to save the application", comment: ""), delegate: nil, cancelButtonTitle: "OK")
                alertView.show()
            }
            self.approveButton?.removeActivityIndicator()
        })
    }
    
    @IBAction func denyButtonTapped(sender: UIButton) {
        application?.status = ApplicationStatusRejected
        approveButton?.enabled = true
        denyButton?.enabled = false
        denyButton?.addActivityIndicator()
        Application.saveApplication(application!, completion: { (success: Bool) -> Void in
            if (success) {
                self.performSegueWithIdentifier("UnwindSegue", sender: self)
            } else {
                let alertView = UIAlertView(title: NSLocalizedString("Oops", comment: ""), message: NSLocalizedString("Failed to save the application", comment: ""), delegate: nil, cancelButtonTitle: "OK")
                alertView.show()
            }
            self.denyButton?.removeActivityIndicator()
        })
    }
}
