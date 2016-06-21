//
//  ProfileViewController.swift
//  Parsetagram
//
//  Created by Alexander Strandberg on 6/20/16.
//  Copyright © 2016 Alexander Strandberg. All rights reserved.
//

import UIKit
import Parse

class ProfileViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func performLogout(sender: AnyObject) {
        PFUser.logOutInBackgroundWithBlock { (error: NSError?) in
            // PFUser.currentUser() will now be nil
        }
        self.performSegueWithIdentifier("profileLogOutSegue", sender: nil)
    }
}
