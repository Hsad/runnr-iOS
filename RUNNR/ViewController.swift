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

class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var MapView: MKMapView!


    let regionRadius: CLLocationDistance = 80
    let locManager = CLLocationManager()
    var isRunning = false
    var currentLocation:CLLocation!
    var displayLabel : UILabel!
    var startButton : UIButton!
    var cornerButton : UIButton!
    var rightCornerButton: UIButton!
    var bottomLeftCornerButton: UIButton!
    var bottomRightCornerButton : UIButton!
    var cornerImage = UIImage(named: "RUNNR_Corner.png")
    var currentRun : Run!
    
    
    func centerMapOnLocation(location: CLLocation) {
        //Center the MKView on a given Location
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        MapView.setRegion(coordinateRegion, animated: true)
    }
    
    func createStartButton(view: UIView, frame: CGRect)->UIButton{
        
        let startButton = UIButton(frame: frame)
        startButton.setTitle("Start Run", forState: UIControlState.Normal)
        startButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        startButton.backgroundColor = UIColor.greenColor()
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
            break
        case 1 :
            cornerButton.addTarget(self, action: "cornerAction0:", forControlEvents: UIControlEvents.TouchUpInside)
            cornerButton.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
            view.addSubview(cornerButton)
            return cornerButton
        case 2 :
            //lower left
            cornerButton.addTarget(self, action: "cornerAction1:", forControlEvents: UIControlEvents.TouchUpInside)
            cornerButton.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
            view.addSubview(cornerButton)
            return cornerButton
        case 3 :
            //lower right
            cornerButton.addTarget(self, action: "cornerAction2:", forControlEvents: UIControlEvents.TouchUpInside)
            cornerButton.transform = CGAffineTransformMakeRotation(2 * CGFloat(-M_PI_2))
            view.addSubview(cornerButton)
            return cornerButton
        default:
            break
        }
        cornerButton.addTarget(self, action: "cornerAction3:", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(cornerButton)
        return cornerButton
    }
    
    func cornerAction0(sender: UIButton!){
        print("corner Action")
    }
    func cornerAction1(sender: UIButton!){
        print("corner Action")
        
    }
    func cornerAction2(sender: UIButton!){
        print("corner Action")
        
    }
    func cornerAction3(sender: UIButton!){
        print("corner Action")
        
    }
    
    func startButtonAction(sender:UIButton!)
    {
        if self.isRunning == false{
            self.isRunning = true
            
            
            self.currentRun = Run()
            self.startButton.setTitle("Stop Run", forState: UIControlState.Normal)
            self.startButton.backgroundColor = UIColor.redColor()
            
        }
        else if self.isRunning == true{
            self.isRunning = false
            self.startButton.setTitle("Start Run", forState: UIControlState.Normal)
            self.startButton.backgroundColor = UIColor.greenColor()
            currentRun.kill()
            
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        let displayLabelFrame = CGRect(x: self.view.frame.size.width/2 - 100, y: self.view.frame.size.height/9, width: 200, height: 44)
        self.displayLabel = UILabel(frame: displayLabelFrame)
        self.displayLabel.text = ""
        displayLabel.textAlignment = .Center
        displayLabel.numberOfLines = 5
        
        self.view.addSubview(displayLabel)
        
        let startButtonFrame = CGRect(x: self.view.frame.size.width/2 - 50, y: 7 * self.view.frame.size.height/8, width: 100, height: 44)
        self.startButton = createStartButton(self.view, frame: startButtonFrame)
        
        let cornerFrame = CGRect(x: 0, y: 0, width: 100, height: 100)
        self.cornerButton = createCornerButton(self.view, frame: cornerFrame, cornerNumber: 0)
        
        
        let rightCornerFrame = CGRect(x: self.view.frame.size.width - 100, y: 0, width: 100, height: 100)
        self.rightCornerButton = createCornerButton(self.view, frame: rightCornerFrame, cornerNumber: 1)
        
        let bottomLeftCornerFrame = CGRect(x: 0, y: self.view.frame.size.height - 100, width: 100, height: 100)
        self.bottomLeftCornerButton = createCornerButton(self.view, frame: bottomLeftCornerFrame, cornerNumber: 2)
        
        let bottomRightCornerFrame = CGRect(x: self.view.frame.size.width - 100, y: self.view.frame.size.height - 100, width: 100, height: 100)
        self.bottomRightCornerButton = createCornerButton(self.view, frame: bottomRightCornerFrame, cornerNumber: 3)
        
        self.MapView.delegate = self
        
        locManager.requestWhenInUseAuthorization()
        
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse){
            locManager.delegate = self
            locManager.desiredAccuracy = kCLLocationAccuracyBest
            locManager.distanceFilter = 1.0
            locManager.activityType = .Fitness
            locManager.startUpdatingLocation()
            self.currentLocation = locManager.location
            centerMapOnLocation(self.currentLocation)
            print("[UPDATE]: User has authorized Core Location Updates")
        }
        else{
            print("[ERROR]: User has not authorized Core Location Updates")
            locManager.requestWhenInUseAuthorization()
        }
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        //pass
    }
    
    func drawRunOnMap(run: Run, mapView: MKMapView){
        var coords = run.getCoordinatesOfRoute()
        let routeLine = MKPolyline(coordinates: &coords, count: coords.count)
        run.giveOverlay(routeLine)
        mapView.addOverlay(routeLine)
        
    }
    
    func removeRunFromMap(run: Run, mapView: MKMapView){
        MapView.removeOverlay(run.overlay)
    }
    
    func updateTextLabel(label: UILabel){
        
        
        let displayDistance = Double(round(1*currentRun.distance)/1)
        let displayTime = Double(round(1*currentRun.seconds/1))

        label.text  = "Distance Ran: \(displayDistance) m \nCurrent Time: \(displayTime) s"
        label.textAlignment = .Center
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
        self.currentLocation = locations.last
        
        
        if isRunning == true{
            centerMapOnLocation(self.currentLocation)
            
            if currentRun.pointsTraveled.count >= 1{
                
                
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
            
        
            currentRun.addLocation(currentLocation)
            
        }
        else{
            //User is moving and we don't care
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

// MARK: - MKMapViewDelegate
extension ViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        
        let polyline = overlay as! MKPolyline
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = UIColor.blueColor()
        renderer.lineWidth = 3
        return renderer
    }
}

