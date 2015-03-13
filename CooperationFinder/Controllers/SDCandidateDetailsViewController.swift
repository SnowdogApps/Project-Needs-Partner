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
    @IBOutlet weak var contactButton: UIButton?
    @IBOutlet weak var descriptionView: UILabel?
    @IBOutlet var titleTop: NSLayoutConstraint!
    @IBOutlet var tagCloudView : TagCloudView!
    
    var application: Application?
    var canDecide: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    func reloadData() {
        userFullName?.text = application?.user?.nameAndCompany()
        descriptionView?.text = application?.user?.desc
        self.tagCloudView.tags = self.application?.user?.tags
        
        if (self.application?.status == ApplicationStatusRejected) {
            self.approveButton?.hidden = true
            self.denyButton?.hidden = true
            self.contactButton?.hidden = true
            self.titleTop.constant = 16.0
        } else if (self.application?.status == ApplicationStatusApproved) {
            self.approveButton?.hidden = true
            self.denyButton?.hidden = true
            self.contactButton?.hidden = false
            self.titleTop.constant = 56.0
        } else {
            self.approveButton?.hidden = false
            self.denyButton?.hidden = false
            self.contactButton?.hidden = true
            self.titleTop.constant = 56.0
        }
    }
    
    @IBAction func approveButtonTapped(sender: UIButton) {
        application?.status = ApplicationStatusApproved
        approveButton?.enabled = false
        denyButton?.enabled = true
        approveButton?.addActivityIndicator()
        Application.saveApplication(application!, completion: { (success: Bool) -> Void in
            if success == true {
                self.reloadData()
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
                self.reloadData()
            } else {
                let alertView = UIAlertView(title: NSLocalizedString("Oops", comment: ""), message: NSLocalizedString("Failed to save the application", comment: ""), delegate: nil, cancelButtonTitle: "OK")
                alertView.show()
            }
            self.denyButton?.removeActivityIndicator()
        })
    }
    
    @IBAction func contactButtonTapped(sender: AnyObject) {
        
        if let email = self.application?.user?.email {
            var urlString = "mailto:\(email)"
            if let url = NSURL(string: urlString) {
                UIApplication.sharedApplication().openURL(url)
            }

        }
    }
    
}
