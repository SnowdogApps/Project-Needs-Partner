//
//  SDProjectsListViewController.swift
//  CooperationFinder
//
//  Created by Radoslaw Szeja on 25.02.2015.
//  Copyright (c) 2015 Snowdog. All rights reserved.
//

import UIKit

class SDProjectsListViewController: UIViewController, UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate, SDListViewModelDelegate, SDFilterViewControllerDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar?
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchPhraseLabel: UILabel!
    @IBOutlet weak var navBarExtension: UIView!
    @IBOutlet weak var navBarExtensionHeight: NSLayoutConstraint!
    
    var onceToken : dispatch_once_t = 0
    var sizingCell : SDProjectCell?
    
    
    var viewModel: SDProjectsListViewModel?
    var searchPhrase: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = SDProjectsListViewModel(delegate: self)
        self.tableView.rowHeight = UITableViewAutomaticDimension

        if self.searchPhrase?.isEmpty == false {
            self.searchPhraseLabel.text = NSLocalizedString("search results for", comment: "") + ": \(searchPhrase!)"
        } else {
            self.navBarExtension.hidden = true
            self.navBarExtensionHeight.constant = 0.0
        }
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if let _searchPhrase = searchPhrase {
            viewModel?.reloadData(_searchPhrase)
        } else {
            viewModel?.reloadData("")
        }
    }
    
    func didReloadData(count: Int) {
        self.tableView.reloadData()
    }
    
    // MARK: UITableView stuff
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let _viewModel = viewModel {
            return _viewModel.numberOfSectionsAtIndexPath()
        }
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let _viewModel = viewModel {
            if tableView == self.tableView {
                return _viewModel.numberOfRowsInSection(section)
            } else {
                return _viewModel.numberOfRowsInSearchSection(section)
            }
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: SDProjectCell = self.tableView.dequeueReusableCellWithIdentifier("ProjectCell") as SDProjectCell
        let project: Project? = self.projectAtIndexPath(indexPath, tableView: tableView)
        self.configureCell(cell, forProject: project);
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height : CGFloat = 131.0
        if let project = self.projectAtIndexPath(indexPath, tableView:tableView) {
            dispatch_once(&onceToken, { () -> Void in
                self.sizingCell = tableView.dequeueReusableCellWithIdentifier("ProjectCell") as? SDProjectCell
            })
            self.configureCell(self.sizingCell!, forProject: project)
            self.sizingCell?.bounds = CGRectMake(0.0, 0.0, tableView.bounds.size.width, 0.0)
            self.sizingCell?.setNeedsLayout()
            self.sizingCell?.layoutIfNeeded()
            self.sizingCell?.projectNameLabel?.preferredMaxLayoutWidth = self.sizingCell!.projectNameLabel!.bounds.size.width
            let size = self.sizingCell?.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
            height = ceil(size!.height)
        }
        
        return height
    }
    
    func configureCell(cell: SDProjectCell, forProject project: Project?) {
        var fullName: String! = project?.author?.fullname!
        var company: String! = project?.author?.company!
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.ShortStyle
        formatter.timeStyle = NSDateFormatterStyle.NoStyle
        
        cell.nameLabel?.text = fullName + ", " + company
        cell.projectNameLabel?.text = project?.name
        
        if let date = project?.createdAt {
            cell.dateLabel?.text = formatter.stringFromDate(date)
        }
        
        if project?.status == ProjectStatusWaitingForApproval {
            cell.statusLabel?.text = NSLocalizedString("waiting for approval", comment: "")
            cell.statusLabel?.hidden = false
            cell.statusIcon?.hidden = false
        } else {
            cell.statusLabel?.text = nil
            cell.statusLabel?.hidden = true
            cell.statusIcon?.hidden = true
        }
        
        cell.commercial = project?.commercial
        cell.trusted = project?.author?.partner
    }
    
    func projectAtIndexPath(indexPath: NSIndexPath, tableView: UITableView) -> Project? {
        var project: Project?
        if tableView == self.tableView {
            project = viewModel?.itemAtIndexpath(indexPath)
        } else {
            project = viewModel?.searchItemAtIndexPath(indexPath)
        }
        return project
    }
        
    // MARK: Searching
    
    func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchString searchString: String!) -> Bool {
        self.viewModel?.searchWithPhrase(searchString, completion: { (success) -> () in
            if let sTableView: UITableView = self.searchDisplayController?.searchResultsTableView {
                sTableView.reloadData()
            }
        })
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ProjectDetailsSegue" {
            var indexPath: NSIndexPath?
            if searchDisplayController?.active == true {
                indexPath = self.searchDisplayController?.searchResultsTableView.indexPathForSelectedRow()
            } else {
                indexPath = self.tableView.indexPathForSelectedRow()
            }
            
            if let controller = segue.destinationViewController as? SDProjectDetailsViewController {
                if searchDisplayController?.active == true {
                    controller.project = viewModel?.searchItemAtIndexPath(indexPath!)
                } else {
                    controller.project = viewModel?.itemAtIndexpath(indexPath!)
                }
                
            }
        } else if (segue.identifier == "FilterSegue") {
            let destinationController = segue.destinationViewController as UINavigationController
            let filterController = destinationController.viewControllers.first as? SDFilterViewController
            filterController?.tags = self.viewModel?.tags
            filterController?.status = self.viewModel?.status
            filterController?.trustedOnly = self.viewModel?.trustedOnly
            filterController?.commercial = self.viewModel?.commercial
            filterController?.delegate = self
        }
    }
    
    @IBAction func unwindToProjectsList(segue:UIStoryboardSegue) {
        
    }
    
    @IBAction func dismissSelf(sender: AnyObject?) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: SDFilterViewControllerDelegate
    
    func setTags(tags: [String]?, status: String?, trustedOnly: Bool?, commercial: Bool?) {
        self.viewModel?.tags = tags
        self.viewModel?.status = status
        self.viewModel?.trustedOnly = trustedOnly
        self.viewModel?.commercial = commercial
    }
}
