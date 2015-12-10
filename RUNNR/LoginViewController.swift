//
//  LoginViewController.swift
//  RUNNR
//
//  Created by Ian O'Boyle on 11/5/15.
//  Copyright © 2015 Ian O'Boyle. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    var userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
    var user: User!
    
    var loginSuccess:Bool! = false
    
    var httpHelp :restHTTPhelper! = restHTTPhelper()
    override func viewWillAppear(animated: Bool) {
        if userDefaults.boolForKey("hasLoggedIn") == true{
            NSOperationQueue.mainQueue().addOperationWithBlock{
                self.view.hidden = true
                self.performSegueWithIdentifier("loginToMain", sender: self)
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func pressedLoginButton(sender: AnyObject) {
        user = User()
        user.userName = userNameField.text
        self.userDefaults.setObject(userNameField.text, forKey: "userName")
        self.userDefaults.setObject(passwordField.text, forKey: "password")
        let urlString = "http://localhost:3000/users/login/:" + user.userName + "/:" + passwordField.text!
        
        httpHelp.makeGetRequest(urlString){
            (result: NSDictionary) in
            let passLogin = 1
            
            let success = result["loginsuccess"] as! Int
            if success == 1 {
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    self.performSegueWithIdentifier("loginToMain", sender: self)
                }
            }
            if passLogin == 1{
                NSOperationQueue.mainQueue().addOperationWithBlock{
                    self.performSegueWithIdentifier("loginToMain", sender: self)
                }
            }
            else if success == 0{
                let alert = UIAlertController(title: "Login Error", message: "Could Not Login: Try again.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
        
    }
    
    @IBOutlet weak var LoginButtonPressed: UIButton!
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
