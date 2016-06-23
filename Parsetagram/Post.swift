//
//  Post.swift
//  Parsetagram
//
//  Created by Alexander Strandberg on 6/20/16.
//  Copyright © 2016 Alexander Strandberg. All rights reserved.
//

import Foundation
import Parse

class Post {
    /**
     Method to add a user post to Parse (uploading image file)
     
     - parameter image: Image that the user wants upload to parse
     - parameter caption: Caption text input by the user
     - parameter completion: Block to be executed after save operation is complete
     */
    
    private var post: PFObject
    
    var createdAt: NSDate? {
        get {
            if let createdAt = post.createdAt {
                return createdAt
            } else {
                return nil
            }
        }
    }
    
    var media: PFFile? {
        get {
            if let media = post["media"] as? PFFile {
                return media
            } else {
                return nil
            }
        }
    }
    
    var author: PFUser? {
        get {
            if let author = post["author"] as? PFUser {
                return author
            } else {
                return nil
            }
        }
    }
    
    var caption: String {
        get {
            if let caption = post["caption"] as? String {
                return caption
            } else {
                return ""
            }
        }
    }
    
    var likesCount: Int {
        get {
            if let likesCount = post["likesCount"] as? Int {
                return likesCount
            } else {
                return 0
            }
        }
    }
    
    var commentsCount: Int {
        get {
            if let commentsCount = post["commentsCount"] as? Int {
                return commentsCount
            } else {
                return 0
            }
        }
    }
    
    var isProfilePicture: Bool {
        get {
            if let isProfilePicture = post["isProfilePicture"] as? Bool {
                return isProfilePicture
            } else {
                return false
            }
        }
    }
    
    init (object: PFObject) {
        post = object
    }
    
    func likePost() {
        post["likesCount"] = likesCount + 1
        post.saveInBackground()
    }
    
    func unlikePost() {
        post["likesCount"] = likesCount - 1
        post.saveInBackground()
    }
    
    class func initializeArray(objects: [PFObject]) -> [Post] {
        var array: [Post] = []
        for currentObject in objects {
            array.append(Post(object: currentObject))
        }
        return array
    }
    
    class func postUserImage(image: UIImage?, withCaption caption: String?, asProfilePicture: Bool, withCompletion completion: PFBooleanResultBlock?) {
        // Create Parse object PFObject
        let post = PFObject(className: "Post")
        
        // Add relevant fields to the object
        post["media"] = getPFFileFromImage(image) // PFFile column type
        post["author"] = PFUser.currentUser() // Pointer column type that points to PFUser
        post["caption"] = caption
        post["likesCount"] = 0
        post["commentsCount"] = 0
        post["isProfilePicture"] = asProfilePicture
        
        // Save object (following function will save the object in Parse asynchronously)
        post.saveInBackgroundWithBlock(completion)
    }
    
    /**
     Method to convert UIImage to PFFile
     
     - parameter image: Image that the user wants to upload to parse
     
     - returns: PFFile for the the data in the image
     */
    class func getPFFileFromImage(image: UIImage?) -> PFFile? {
        // check if image is not nil
        if let image = image {
            // get image data and check if that is not nil
            if let imageData = UIImagePNGRepresentation(image) {
                return PFFile(name: "image.png", data: imageData)
            }
        }
        return nil
    }
    
    class func resize(image: UIImage, newSize: CGSize) -> UIImage {
        let resizeImageView = UIImageView(frame: CGRectMake(0, 0, newSize.width, newSize.height))
        resizeImageView.contentMode = UIViewContentMode.ScaleAspectFill
        resizeImageView.image = image
        
        UIGraphicsBeginImageContext(resizeImageView.frame.size)
        resizeImageView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}