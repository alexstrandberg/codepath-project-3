//
//  FeedViewController.swift
//  Parsetagram
//
//  Created by Alexander Strandberg on 6/20/16.
//  Copyright © 2016 Alexander Strandberg. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var loadingMoreView:InfiniteScrollActivityView?
    
    let queryChunk = 20
    var queryLimit = 20
    var isMoreDataLoading = false
    
    var posts: [Post] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    let refreshControl = UIRefreshControl()
    
    var feedType = "home"
    var showingUser:PFUser?
    
    let CellIdentifier = "FeedCell", HeaderViewIdentifier = "FeedHeaderView"
    let tableCellHeaderHeight: CGFloat = 80

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Initialize a UIRefreshControl
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        //tableView.insertSubview(networkErrorView, atIndex: 0)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.hidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets
    }
    
    override func viewDidAppear(animated: Bool) {
        // check if user is logged in.
        if PFUser.currentUser() == nil {
            // if there is no logged in user then load the login view controller
            performSegueWithIdentifier("showLoginSegue", sender: nil)
        } else {
            refreshControlAction(refreshControl)
            if feedType == "user" {
                if showingUser != nil {
                    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "My Profile", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(FeedViewController.myProfilePressed))
                    navigationItem.title = "User Profile"
                } else {
                    navigationItem.leftBarButtonItem = nil
                    navigationItem.title = "My Profile"
                }
            }
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        showingUser = nil
        navigationItem.leftBarButtonItem = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func performLogoutAction(sender: AnyObject) {
        PFUser.logOutInBackgroundWithBlock { (error: NSError?) in
            // PFUser.currentUser() will now be nil
        }
        posts = []
        performSegueWithIdentifier("showLoginSegue", sender: nil)
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        
        // construct PFQuery
        let query = PFQuery(className: "Post")
        query.orderByDescending("createdAt")
        query.whereKey("isProfilePicture", equalTo: false)
        query.includeKey("author")
        if feedType == "user" {
            if showingUser != nil {
                query.whereKey("author", equalTo: showingUser!)
            } else {
                query.whereKey("author", equalTo: PFUser.currentUser()!)
            }
        }
        query.limit = queryLimit
        
        // fetch data asynchronously
        query.findObjectsInBackgroundWithBlock { (posts: [PFObject]?, error: NSError?) -> Void in
            if let posts = posts {
                // do something with the data fetched
                self.posts = Post.initializeArray(posts)
           } else {
                // handle error
                print(error?.localizedDescription)
            }
            
            self.isMoreDataLoading = false
            
            // Stop the loading indicator
            self.loadingMoreView!.stopAnimating()
            refreshControl.endRefreshing()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if posts.count > 0 {
            return 1
        }
        return 0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCellWithIdentifier(HeaderViewIdentifier) as! FeedHeaderView
        
        let post = posts[section]
        
        if let user = post.author {
            header.usernameLabel.text = user.username!
            // construct PFQuery
            let query = PFQuery(className: "Post")
            query.orderByDescending("createdAt")
            query.whereKey("isProfilePicture", equalTo: true)
            query.whereKey("author", equalTo: user)
            query.limit = 1
            
            // fetch data asynchronously
            query.findObjectsInBackgroundWithBlock { (posts: [PFObject]?, error: NSError?) -> Void in
                if let posts = posts where posts.count > 0 {
                    let tempImage = PFImageView()
                    tempImage.file = Post(object: posts[0]).media
                    tempImage.loadInBackground({(image, error) in
                        if let image = image {
                            if !self.isMoreDataLoading {
                                header.profileButton.setImage(image, forState: UIControlState.Normal)
                            }
                        }
                    })
                }
                header.profileButton.tag = section
                header.profileButton.addTarget(self, action: #selector(FeedViewController.showUserProfile), forControlEvents: UIControlEvents.TouchUpInside)
            }
        }
        
        let dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "EEE, MMM d, h:mm a"
        if let createdAt = post.createdAt {
            header.timestampLabel.text = "" + dateFormat.stringFromDate(createdAt)
        }
        
        return header
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableCellHeaderHeight
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier) as! FeedCell
        
        cell.parsetagramPost = posts[indexPath.section]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.dragging) {
                isMoreDataLoading = true
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                // ... Code to load more results ...
                queryLimit += queryChunk
                refreshControlAction(refreshControl)
            }
        }
    }
    
    func showUserProfile(sender: UIButton) {
        let profileNavigationController = tabBarController?.viewControllers![2] as! UINavigationController
        let profileViewController = profileNavigationController.topViewController as! FeedViewController
        profileViewController.feedType = "user"
        let author = posts[sender.tag].author
        profileViewController.showingUser = PFUser.currentUser()!.username != author?.username ? author : nil
        tabBarController?.selectedIndex = 2
    }
    
    func myProfilePressed() {
        showingUser = nil
        navigationItem.leftBarButtonItem = nil
        navigationItem.title = "My Profile"
        refreshControlAction(refreshControl)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier != "showLoginSegue" {
            let vc = segue.destinationViewController as! PostDetailViewController
            let cell = sender as! FeedCell
            let indexPath = tableView.indexPathForCell(cell)
            vc.parsetagramPost = posts[indexPath!.section]
        }
    }

}
