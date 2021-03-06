//
//  UploadViewController.swift
//  Parsetagram
//
//  Created by Alexander Strandberg on 6/20/16.
//  Copyright © 2016 Alexander Strandberg. All rights reserved.
//

import UIKit
import MBProgressHUD

struct Platform {
    static var isSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0 // Use this line in Xcode 7 or newer
    }
}

class UploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var captionField: UITextField!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var setProfilePictureButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        uploadButton.enabled = false
        setProfilePictureButton.enabled = false
        
        captionField.delegate = self
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.chooseImage))
        singleTap.numberOfTapsRequired = 1
        imageView.userInteractionEnabled = true
        imageView.addGestureRecognizer(singleTap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func chooseImage() {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        
        // Check to see if running on simulator - can't choose camera, so no alert is displayed
        if Platform.isSimulator {
            vc.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.presentViewController(vc, animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title: "Image Source", message: "Pick an image or capture a new one?", preferredStyle: .Alert)
            
            let libraryAction = UIAlertAction(title: "Photo Library", style: .Default) { (action) in
                vc.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                self.presentViewController(vc, animated: true, completion: nil)
            }
            alertController.addAction(libraryAction)
            
            let cameraAction = UIAlertAction(title: "Take Photo", style: .Default) { (action) in
                vc.sourceType = UIImagePickerControllerSourceType.Camera
                self.presentViewController(vc, animated: true, completion: nil)
            }
            alertController.addAction(cameraAction)
            
            self.presentViewController(alertController, animated: true) {
                // optional code for what happens after the alert controller has finished presenting
            }
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // Get the image captured by the UIImagePickerController
        //let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        
        // Do something with the images (based on your use case)
        imageView.image = editedImage
        
        uploadButton.enabled = true
        setProfilePictureButton.enabled = true
        
        // Dismiss UIImagePickerController to go back to your original view controller
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func upload(asProfilePicture asProfilePicture: Bool) {
        if let image = imageView.image {
            self.uploadButton.enabled = false
            self.setProfilePictureButton.enabled = false
            // Display HUD right before the request is made
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            let resizedImage = Post.resize(image, newSize: imageView.frame.size)
            Post.postUserImage(resizedImage, withCaption: captionField.text, asProfilePicture: asProfilePicture, withCompletion: {(success, error) -> Void in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    self.imageView.image = UIImage(named: "imagePlaceholder")
                    self.captionField.text = ""
                    
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
                // Hide HUD once the network request comes back (must be done on main UI thread)
                MBProgressHUD.hideHUDForView(self.view, animated: true)
            })
        }
    }
    
    @IBAction func uploadPost(sender: AnyObject) {
        upload(asProfilePicture: false)
    }
    @IBAction func uploadProfilePicture(sender: AnyObject) {
        upload(asProfilePicture: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
