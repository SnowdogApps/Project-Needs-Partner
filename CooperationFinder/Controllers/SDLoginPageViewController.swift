//
//  SDLoginPageViewController.swift
//  CooperationFinder
//
//  Created by Rafal Kwiatkowski on 04.03.2015.
//  Copyright (c) 2015 Snowdog. All rights reserved.
//

import UIKit

enum SDLoginPageViewControllerMode : Int {
    
    case Login
    case Register
}

class SDLoginPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
   
    var loginController : SDLoginViewController?
    var registerController : SDRegisterViewController?
    var mode : SDLoginPageViewControllerMode = SDLoginPageViewControllerMode.Login
    var completion : (() -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.dataSource = self
        self.setPageViewControllerScrollEnabled(false)
        
        self.loginController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LoginViewController") as? SDLoginViewController
        self.registerController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("RegisterViewController") as? SDRegisterViewController
        
        if self.loginController != nil && self.registerController != nil {
            
            self.loginController?.signUpTapped = {
                self.setViewControllers([self.registerController!], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
            }
            
            self.registerController?.backTapped = {
                self.setViewControllers([self.loginController!], direction: UIPageViewControllerNavigationDirection.Reverse, animated: true, completion: nil)
            }
            
            self.loginController?.completion = self.completion
            self.registerController?.completion = self.completion
            
            if (self.mode == .Login) {
                self.setViewControllers([self.loginController!], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
            } else {
                self.setViewControllers([self.registerController!], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        if (viewController == self.loginController) {
            return self.registerController
        }
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        if (viewController == self.registerController) {
            return self.loginController
        }
        return nil
    }
}

extension UIPageViewController {
    func setPageViewControllerScrollEnabled(enabled : Bool)
    {
        for view : UIView in self.view.subviews as [UIView] {
            if (view.isKindOfClass(UIScrollView.self)) {
                let scroll : UIScrollView = view as UIScrollView
                scroll.scrollEnabled = enabled
                return
            }
        }
    }
}
