//
//  UploadViewController.swift
//  Parsetagram
//
//  Created by Alexander Strandberg on 6/20/16.
//  Copyright © 2016 Alexander Strandberg. All rights reserved.
//

import UIKit

class UploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var chooseImageButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var captionField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func chooseImage(sender: AnyObject) {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        vc.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // Get the image captured by the UIImagePickerController
        //let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        
        // Do something with the images (based on your use case)
        
        chooseImageButton.imageView?.image = editedImage
        imageView.image = editedImage
        
        // Dismiss UIImagePickerController to go back to your original view controller
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func uploadPost(sender: AnyObject) {
        if let image = imageView.image {
            Post.postUserImage(image, withCaption: captionField.text, withCompletion: {(success, error) -> Void in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    print("Upload successful")
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            })
        }
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
