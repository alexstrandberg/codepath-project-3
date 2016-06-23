//
//  LoginViewController.swift
//  Parsetagram
//
//  Created by Alexander Strandberg on 6/20/16.
//  Copyright © 2016 Alexander Strandberg. All rights reserved.
//

import UIKit
import Parse
import MBProgressHUD

class LoginViewController: UIViewController {
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        toggleButtons(false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func validateFields() {
        if let email = emailField.text, let password = passwordField.text {
            if email != "" && password != "" {
                toggleButtons(true)
            } else {
                toggleButtons(false)
            }
        }
    }
    
    func toggleButtons(enabled: Bool) {
        signInButton.enabled = enabled
        signUpButton.enabled = enabled
        if enabled {
            UIView.animateWithDuration(0.5, delay:0, options:UIViewAnimationOptions.TransitionFlipFromTop, animations: {
                self.signInButton.alpha = 1
                self.signUpButton.alpha = 1
                }, completion: { finished in
            })
        } else {
            UIView.animateWithDuration(0.5, delay:0, options:UIViewAnimationOptions.TransitionFlipFromTop, animations: {
                self.signInButton.alpha = 0.5
                self.signUpButton.alpha = 0.5
                }, completion: { finished in
            })
        }
    }
    
    @IBAction func emailChanged(sender: UITextField) {
        validateFields()
    }
    
    @IBAction func passwordChanged(sender: UITextField) {
        validateFields()
    }
    
    @IBAction func onSignIn(sender: AnyObject) {
        toggleButtons(false)
        
        // Display HUD right before the request is made
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        let email = emailField.text ?? ""
        let password = passwordField.text ?? ""
        
        PFUser.logInWithUsernameInBackground(email, password: password) { (user:PFUser?, error:NSError?) -> Void in
            if let error = error {
                print(error.localizedDescription)
                let alertController = UIAlertController(title: "Error Logging In", message: error.localizedDescription, preferredStyle: .Alert)
                
                // create an OK action
                let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                    // handle response here.
                }
                // add the OK action to the alert controller
                alertController.addAction(OKAction)
                
                self.presentViewController(alertController, animated: true) {
                    // optional code for what happens after the alert controller has finished presenting
                }
            } else {
                // go to feed view controller
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            
            // Hide HUD once the network request comes back (must be done on main UI thread)
            MBProgressHUD.hideHUDForView(self.view, animated: true)
        }
    }
    
    @IBAction func onSignUp(sender: AnyObject) {
        toggleButtons(false)
        
        // Display HUD right before the request is made
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        // Initialize user object
        let newUser = PFUser()
        
        // Set user properties
        newUser.username = emailField.text
        newUser.password = passwordField.text
        
        // Call sign up function on the object
        newUser.signUpInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if let error = error {
                print(error.localizedDescription)
                let alertController = UIAlertController(title: "Error Signing Up", message: error.localizedDescription, preferredStyle: .Alert)
                
                // create an OK action
                let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                    // handle response here.
                }
                // add the OK action to the alert controller
                alertController.addAction(OKAction)
                
                self.presentViewController(alertController, animated: true) {
                    // optional code for what happens after the alert controller has finished presenting
                }
            } else {
                // manually segue to logged in view
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            // Hide HUD once the network request comes back (must be done on main UI thread)
            MBProgressHUD.hideHUDForView(self.view, animated: true)
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
