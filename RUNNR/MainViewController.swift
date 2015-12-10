//
//  ViewController.swift
//  RUNNR
//
//  Created by Ian O'Boyle on 10/19/15.
//  Copyright © 2015 Ian O'Boyle. All rights reserved.
//

import UIKit
import MapKit
import HealthKit
import CoreData



extension ViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let polyline         = overlay as! MKPolyline
        let renderer         = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = UIColor.blueColor()
        renderer.lineWidth   = 3
        return renderer
    }
    
}
class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var MapView: MKMapView!
    
    let regionRadius: CLLocationDistance = 80
    let locManager = CLLocationManager()
    var isRunning = false
    var userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
    var currentLocation         :CLLocation!
    
    var displayLabel            : UILabel!
    var startButton             : UIButton!
    var cornerButton            : UIButton!
    var rightCornerButton       : UIButton!
    var bottomLeftCornerButton  : UIButton!
    var bottomRightCornerButton : UIButton!
    var cornerImage = UIImage(named: "RUNNR_Corner.png")
    
    var userRuns = [NSManagedObject]()
    var currentRun : Run!
    var currentUser: User!
    
    var startButtonFrame:CGRect!
    var pentagonButtonFrame:CGRect!
    func createStartButton(view: UIView, frame: CGRect)->UIButton{
        
        let startButton = UIButton(frame: frame)
        startButton.setTitle("Start Run", forState: UIControlState.Normal)
        startButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        if isRunning == false{
            startButton.setBackgroundImage(UIImage(named: "pentagon.png"), forState: UIControlState.Normal)
        }
        else{
            startButton.backgroundColor = UIColor.redColor()
            startButton.setTitle("Stop Run", forState: UIControlState.Normal)
        }
        startButton.addTarget(self, action: "startButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(startButton)
        
        return startButton
    }
    func createCornerButton(view: UIView, frame: CGRect, cornerNumber: Int)->UIButton{
        let cornerButton = UIButton(frame: frame)
        cornerButton.setBackgroundImage(cornerImage, forState: UIControlState.Normal)
        switch cornerNumber{
        case 0 :
            //upper left
            cornerButton.addTarget(self, action: "upperLeftButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
            cornerButton.setImage(UIImage(named: "LeaderBoard.png"), forState: UIControlState.Normal)
            break
        case 1 :
            cornerButton.addTarget(self, action: "upperRightButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
            cornerButton.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
            cornerButton.setImage(UIImage(named: "StatsStopWatchWithBackGround.png"), forState: UIControlState.Normal)
            cornerButton.imageView!.transform = CGAffineTransformMakeRotation(CGFloat(-(M_PI_2)))
            
            view.addSubview(cornerButton)
            return cornerButton
        case 2 :
            //lower left
            cornerButton.addTarget(self, action: "lowerLeftButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
            cornerButton.setImage(UIImage(named: "SettingsHAL.png"), forState: UIControlState.Normal)
            cornerButton.imageView!.transform = CGAffineTransformMakeRotation(CGFloat(-(M_PI_2)))
            cornerButton.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
            view.addSubview(cornerButton)
            return cornerButton
        case 3 :
            //lower right
            cornerButton.addTarget(self, action: "lowerRightButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
            cornerButton.setImage(UIImage(named: "OtherTeamThing.png"), forState: UIControlState.Normal)
            cornerButton.imageView!.transform = CGAffineTransformMakeRotation(CGFloat(-(M_PI_2)))
            cornerButton.transform = CGAffineTransformMakeRotation(2 * CGFloat(-M_PI_2))
            view.addSubview(cornerButton)
            return cornerButton
        default:
            break
        }
        cornerButton.addTarget(self, action: "upperLeftButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(cornerButton)
        return cornerButton
    }
    func createDisplayLabel(view: UIView, frame: CGRect)->UILabel{
        let label = UILabel(frame: frame)
        label.text = ""
        label.textAlignment = .Center
        label.numberOfLines = 5
        view.addSubview(label)
        return label
    }
    func upperLeftButtonAction(sender: UIButton!){
        print("upper left button Action")
        self.performSegueWithIdentifier("toLeaderboards", sender: self)
    }
    func upperRightButtonAction(sender: UIButton!){
        print("upper right button Action")
        self.performSegueWithIdentifier("toUserAnalytics", sender: self)
    }
    func lowerLeftButtonAction(sender: UIButton!){
        print("lower left button Action")
        self.performSegueWithIdentifier("toSettings", sender: self)
        
    }
    func lowerRightButtonAction(sender: UIButton!){
        print("lower right button Action")
        self.performSegueWithIdentifier("toTeamView", sender: self)
    }
    func startButtonAction(sender:UIButton!){
        if isRunning == false{
            //If the user isn't running
            isRunning  = true
            currentRun = Run()
            startButton.removeFromSuperview()
            startButton = createStartButton(self.view, frame: startButtonFrame)
            startButton.setTitle("Stop Run", forState: UIControlState.Normal)
        }
        else if isRunning == true{
            //If the user is running
            isRunning = false
            startButton.setTitle("Start Run", forState: UIControlState.Normal)
            startButton.removeFromSuperview()
            startButton = createStartButton(self.view, frame: pentagonButtonFrame)
            currentRun.kill()
            //create the url with NSURL
            saveRun("test", userRun: currentRun)
            //Add currentRun to currentUser's set of runs.
            currentUser.appendRun(currentRun)
            var coordinate_array = [Double]()
            for coordinates in currentRun.pointsTraveled{
                coordinate_array.append(coordinates.coordinate.latitude)
                coordinate_array.append(coordinates.coordinate.longitude)
            }
            
            
            //Make request to server to add Run data
            let url = NSURL(string: "http://localhost:3000/finishRun") //change the url
            print(currentRun.seconds)
            let parameters = ["userName": userDefaults.stringForKey("userName")!, "runtime" : String(currentRun.seconds) ,"coordinates": String(coordinate_array), "distance": String(currentRun.distance)] as Dictionary<String, String>
            
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
                    let strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    print("Body: \(strData)")
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
    }
    
    func saveRun(userName: String, userRun: Run){
        
        //Save run in Coredata for user
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        let coordinatesOfRoute = userRun.getCoordinatesOfRoute()
        
        
        let entity =  NSEntityDescription.entityForName("RunEntity",
            inManagedObjectContext:managedContext)
        
        let newRunEntry = RunEntity(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        var order = 0
        for coordinates in coordinatesOfRoute{
            let coordinateEntity = NSEntityDescription.entityForName("Coordinate", inManagedObjectContext: managedContext)
            let newCoordinateEntry = CoordinateEntity(entity: coordinateEntity!, insertIntoManagedObjectContext: managedContext)
            newCoordinateEntry.latitude = Double(coordinates.coordinate.latitude)
            newCoordinateEntry.longitude = Double(coordinates.coordinate.longitude)
            newCoordinateEntry.order = order
            newCoordinateEntry.isOwnedBy = newRunEntry
            order++
        }
        
        //Create a timestampe of today, right now
        
        let todaysDate:NSDate = NSDate()
        let dateFormatter:NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        let DateInFormat:String = dateFormatter.stringFromDate(todaysDate)
        
        //Set values for CoreData Entity
        newRunEntry.setValue(userName, forKey: "user")
        newRunEntry.setValue(userRun.distance, forKeyPath: "distance")
        newRunEntry.setValue(userRun.seconds, forKeyPath: "time")
        newRunEntry.setValue(DateInFormat, forKeyPath: "createdAt")
        do {
            try managedContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    func centerMapOnLocation(location: CLLocation) {
        //Center the MKView on a given Location
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        MapView.setRegion(coordinateRegion, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        MapView.delegate = self
        //Create the frames for all subviews of this controller.
        //Call all instatiation methods for those subviews.
        //Create the current User
        currentUser = User()
        currentUser.userName = self.userDefaults.stringForKey("userName")
        
        //Create frames for UI elements
        let displayLabelFrame = CGRect(x: self.view.frame.size.width/2 - 100,
            y: self.view.frame.size.height/11,
            width: 200,
            height: 44)
        startButtonFrame = CGRect(x: self.view.frame.size.width/2 - 50,
            y: 7 * self.view.frame.size.height/8,
            width: 100,
            height: 44)
        pentagonButtonFrame = CGRect(x: self.view.frame.size.width/2 - 140,
            y: self.view.frame.size.height/2 - 150,
            width: 300,
            height:300)
        let cornerFrame = CGRect(x: 0,
            y: 0,
            width: 100,
            height: 100)
        let rightCornerFrame = CGRect(x: self.view.frame.size.width - 100,
            y: 0,
            width: 100,
            height: 100)
        let bottomLeftCornerFrame = CGRect(x: 0,
            y: self.view.frame.size.height - 100,
            width: 100,
            height: 100)
        let bottomRightCornerFrame = CGRect(x: self.view.frame.size.width - 100,
            y: self.view.frame.size.height - 100,
            width: 100,
            height: 100)
        
        //Call creation functions for UI elements
        displayLabel            = createDisplayLabel(self.view, frame: displayLabelFrame)
        startButton             = createStartButton(self.view, frame: pentagonButtonFrame)
        cornerButton            = createCornerButton(self.view, frame: cornerFrame, cornerNumber: 0)
        rightCornerButton       = createCornerButton(self.view, frame: rightCornerFrame, cornerNumber: 1)
        bottomLeftCornerButton  = createCornerButton(self.view, frame: bottomLeftCornerFrame, cornerNumber: 2)
        bottomRightCornerButton = createCornerButton(self.view, frame: bottomRightCornerFrame, cornerNumber: 3)
        
        //Request location authorization from user
        locManager.requestWhenInUseAuthorization()
        //Start tracking user location if we have permission
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse){
            locManager.delegate        = self
            locManager.desiredAccuracy = kCLLocationAccuracyBest
            locManager.distanceFilter  = 1.0
            locManager.activityType    = .Fitness
            
            locManager.startUpdatingLocation()
            self.currentLocation       = locManager.location
            // centerMapOnLocation(self.currentLocation)
        }
        else{ //Ask for permission again if the user said no before.
            locManager.requestWhenInUseAuthorization()
        }
        print(userRuns.count)
    }
    
    override func viewWillDisappear(animated: Bool) {
        //pass
    }
    
    func drawRunOnMap(currentRun: Run, mapView: MKMapView){
        //Create Overlay to draw on the MKMapView
        
        var coords = [CLLocationCoordinate2D]()
        
        for location in currentRun.pointsTraveled{
            let lastLocation = currentRun.pointsTraveled.last!
            let thisLocation = location
            coords.append(lastLocation.coordinate)
            coords.append(thisLocation.coordinate)
            MapView.addOverlay(MKPolyline(coordinates: &coords, count: coords.count))
        }
        
        updateTextLabel(displayLabel)
        let routeLine = MKPolyline(coordinates: &coords, count: coords.count)
        currentRun.giveOverlay(routeLine)
        
    }
    
    func removeRunFromMap(run: Run, mapView: MKMapView){
        //Remove overlay from map
        MapView.removeOverlay(run.overlay)
    }
    
    func updateTextLabel(label: UILabel){
        //Update the Text Label displaying the current time and distance
        
        
        let displayDistance = Double(round(1*currentRun.distance)/1)
        let displayTime = Double(round(1*currentRun.seconds/1))
        
        label.text  = "Distance Ran: \(displayDistance) m \nCurrent Time: \(displayTime) s"
        label.textAlignment = .Center
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //Location manager function that records location
        self.currentLocation = locations.last
        if self.currentLocation.horizontalAccuracy < 20 {
            if isRunning == true{
                //Center map on the current location
                centerMapOnLocation(self.currentLocation)
                if currentRun.pointsTraveled.count >= 1{
                    //If we have at least two points to draw a line between, draw that line
                    
                    var coords = [CLLocationCoordinate2D]()
                    let lastLocation = currentRun.pointsTraveled.last!
                    let thisLocation = currentLocation
                    
                    coords.append(lastLocation.coordinate)
                    coords.append(thisLocation.coordinate)
                    MapView.addOverlay(MKPolyline(coordinates: &coords, count: coords.count))
                    currentRun.addLocation(currentLocation)
                    currentRun.distance += lastLocation.distanceFromLocation(thisLocation)
                    currentRun.incrementDistance(lastLocation.distanceFromLocation(thisLocation))
                    updateTextLabel(displayLabel)
                }
                else{
                    //We only took one step, wait for more.
                    currentRun.addLocation(currentLocation)
                }
            }
            else{
                //User is moving and we don't care
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


