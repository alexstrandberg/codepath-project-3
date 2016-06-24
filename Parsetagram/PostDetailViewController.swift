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
    @IBOutlet weak var likeButton: UIButton!
    
    var parsetagramPost: Post!
    var profilePictureAuthor: PFUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        likeButton.setImage(UIImage(named: "likeButtonSelected"), forState: .Selected)
        
        if parsetagramPost != nil {
            updateView()
        } else if let profilePictureAuthor = profilePictureAuthor {
            // construct PFQuery
            let query = PFQuery(className: "Post")
            query.orderByDescending("createdAt")
            query.whereKey("isProfilePicture", equalTo: true)
            query.whereKey("author", equalTo: profilePictureAuthor)
            query.limit = 1
            
            // fetch data asynchronously
            query.findObjectsInBackgroundWithBlock { (posts: [PFObject]?, error: NSError?) -> Void in
                if let posts = posts where posts.count > 0 {
                    self.parsetagramPost = Post(object: posts[0])
                    self.updateView()
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func likeButton(sender: UIButton) {
        sender.selected = !sender.selected
        sender.transform = CGAffineTransformMakeScale(0.05, 0.05)
        UIView.animateWithDuration(0.5,
                                   delay: 0,
                                   usingSpringWithDamping: 0.2,
                                   initialSpringVelocity: 6.0,
                                   options: UIViewAnimationOptions.AllowUserInteraction,
                                   animations: {
                                    sender.transform = CGAffineTransformIdentity
            }, completion: nil)
        if sender.selected {
            parsetagramPost.likePost(PFUser.currentUser()!)
        } else {
            parsetagramPost.unlikePost(PFUser.currentUser()!)
        }
        
        updateView()
    }

    func updateView() {
        if let post = parsetagramPost {
            if let media = post.media {
                self.photoView.file = media
                self.photoView.loadInBackground()
            }
            
            captionLabel.text = post.caption
            let dateFormat = NSDateFormatter()
            dateFormat.dateFormat = "EEE, MMM d, h:mm a"
            if let createdAt = post.createdAt {
                timestampLabel.text = "Uploaded: " + dateFormat.stringFromDate(createdAt)
            }
            if post.likesCount != 1 {
                likesLabel.text = "\(post.likesCount) Likes"
            } else {
                likesLabel.text = "1 Like"
            }
            
            if post.isLikedByUser(PFUser.currentUser()!) {
                likeButton.selected = true
            }
        }
    }
}
