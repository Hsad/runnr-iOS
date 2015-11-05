//
//  SettingsViewController.swift
//  RUNNR
//
//  Created by Ian O'Boyle on 11/5/15.
//  Copyright © 2015 Ian O'Boyle. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var changeUserNameButton: UIButton!
    @IBOutlet weak var displayRealNameButton: UIButton!
    @IBOutlet weak var autopostTeamButton: UIButton!
    @IBOutlet weak var autoPostRunButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    
    
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
    
    @IBAction func staySignedInPress(sender: AnyObject) {
        
        
        if flag1 == false{
        signInButton.setImage(UIImage(named: "Checked.png"), forState: UIControlState.Normal)
            flag1 = true
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
