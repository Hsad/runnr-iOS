//
//  SettingsViewController.swift
//  RUNNR
//
//  Created by Ian O'Boyle on 11/5/15.
//  Copyright © 2015 Ian O'Boyle. All rights reserved.
//

import UIKit
import CoreData
class SettingsViewController: UIViewController {

    @IBOutlet weak var changeUserNameButton: UIButton!
    @IBOutlet weak var displayRealNameButton: UIButton!
    @IBOutlet weak var autopostTeamButton: UIButton!
    @IBOutlet weak var autoPostRunButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    
    @IBOutlet weak var enterPinButton: UIButton!
    
    var userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    var flag1 = false
    var flag2 = false
    var flag3 = false
    var flag4 = false
    var flag5 = false

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func pressedEnterPinButton(sender: AnyObject) {
        var tField : UITextField!
        var alert = UIAlertController(title: "Enter pin", message: "Enter your team's passcode", preferredStyle: UIAlertControllerStyle.Alert)

        
        func configurationTextField(textField: UITextField!){
            textField.placeholder = "Enter a passcode"
            tField = textField

        }
        func handleOkay(alertView: UIAlertAction!){
            print("Passcode is \(tField.text)")
            let url = NSURL(string: "http://localhost:3000/addtoteam") //change the url
            let name = userDefaults.stringForKey("userName")!
            let parameters = ["team": tField.text!, "username" : name]
            
            //create the session object
            let session = NSURLSession.sharedSession()
            
            //now create the NSMutableRequest object using the url object
            let request = NSMutableURLRequest(URL: url!)
            request.HTTPMethod = "POST" //set http method as POST
            
            do{
                request.HTTPBody =  try NSJSONSerialization.dataWithJSONObject(parameters, options: []) // pass dictionary to nsdata object and set it as request body
                
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                
                //create dataTask using the session object to send data to the server
                let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                    print("Response: \(response)")
                    //var strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    //print("Body: \(strData)")
                    do{
                        let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as? NSDictionary
                        
                        // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
                        
                        // The JSONObjectWithData constructor didn't return an error. But, we should still
                        // check and make sure that json has a value using optional binding.
                        if let parseJSON = json {
                            // Okay, the parsedJSON is here, let's get the value for 'success' out of it
                            let success = parseJSON["success"] as? Int
                            print("Success: \(success)")
                        }
                        else {
                            // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                            let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                            print("Error could not parse JSON: \(jsonStr)")
                        }
                    }catch let err as NSError{
                        print(err.localizedDescription)
                        let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                        print("Error could not parse JSON: '\(jsonStr)'")
                    }
                })
                task.resume()
            }catch let err as NSError{
                print(err)
            }

        }
        
        func handleCancel(alertView: UIAlertAction!){
            //Do nothing
        }

        alert.addAction(UIAlertAction(title: "Enter", style: UIAlertActionStyle.Default, handler: handleOkay))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: handleCancel))
        alert.addTextFieldWithConfigurationHandler(configurationTextField)
        self.presentViewController(alert, animated: true, completion: nil)
    
    }
    @IBAction func staySignedInPress(sender: AnyObject) {
        
        
        if flag1 == false{
        signInButton.setImage(UIImage(named: "Checked.png"), forState: UIControlState.Normal)
            flag1 = true
            let fetchRequest = NSFetchRequest(entityName: "RunEntity")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            let appDelegate =
            UIApplication.sharedApplication().delegate as! AppDelegate
            do {
                try appDelegate.managedObjectContext.executeRequest(deleteRequest)
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    self.userDefaults.setBool(false, forKey: "hasLoggedIn")
                    self.performSegueWithIdentifier("settingsToLogin", sender: self)
                }
            } catch let error as NSError {
                // TODO: handle the error
                print(error)
            }
        }
        else{
        signInButton.setImage(UIImage(named: "Unchecked.png"), forState: UIControlState.Normal)
            flag1 = false
        }
    }

    @IBAction func AutopostPress(sender: AnyObject) {
        if flag2 == false{
            autoPostRunButton.setImage(UIImage(named: "Checked.png"), forState: UIControlState.Normal)
            flag2 = true
        }
        else{
            autoPostRunButton.setImage(UIImage(named: "Unchecked.png"), forState: UIControlState.Normal)
            flag2 = false
        }

    }
    @IBAction func autoPostTeamPress(sender: AnyObject) {
        if flag3 == false{
            autopostTeamButton.setImage(UIImage(named: "Checked.png"), forState: UIControlState.Normal)
            flag3 = true
        }
        else{
            autopostTeamButton.setImage(UIImage(named: "Unchecked.png"), forState: UIControlState.Normal)
            flag3 = false
        }

    }

    @IBAction func displayRealNamePressed(sender: AnyObject) {
        if flag4 == false{
            displayRealNameButton.setImage(UIImage(named: "Checked.png"), forState: UIControlState.Normal)
            flag4 = true
        }
        else{
            displayRealNameButton.setImage(UIImage(named: "Unchecked.png"), forState: UIControlState.Normal)
            flag4 = false
        }
    }
    @IBAction func changeUserNamePressed(sender: AnyObject) {
        if flag5 == false{
            changeUserNameButton.setImage(UIImage(named: "Checked.png"), forState: UIControlState.Normal)
            flag5 = true
        }
        else{
            changeUserNameButton.setImage(UIImage(named: "Unchecked.png"), forState: UIControlState.Normal)
            flag5 = false
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
