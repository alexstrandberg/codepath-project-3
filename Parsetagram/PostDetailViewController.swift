//
//  PostDetailViewController.swift
//  Parsetagram
//
//  Created by Alexander Strandberg on 6/20/16.
//  Copyright © 2016 Alexander Strandberg. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class PostDetailViewController: UIViewController {
    @IBOutlet weak var photoView: PFImageView!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    
    var parsetagramPost: PFObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if let post = parsetagramPost {
            self.photoView.file = post["media"] as? PFFile
            self.photoView.loadInBackground()
            captionLabel.text = post["caption"] as? String
            let dateFormat = NSDateFormatter()
            dateFormat.dateFormat = "EEE, MMM d, h:mm a"
            timestampLabel.text = "Uploaded: " + dateFormat.stringFromDate(post.createdAt!)
            likesLabel.text = "\(post["likesCount"]) Likes"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func likeButton(sender: AnyObject) {
        let likes = parsetagramPost["likesCount"] as! Int
        parsetagramPost["likesCount"] = likes + 1
        likesLabel.text = "\(parsetagramPost["likesCount"]) Likes"
        parsetagramPost.saveInBackground()
    }
}
