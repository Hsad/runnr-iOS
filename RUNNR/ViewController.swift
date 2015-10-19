//
//  ViewController.swift
//  RUNNR
//
//  Created by Ian O'Boyle on 10/19/15.
//  Copyright © 2015 Ian O'Boyle. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var MapView: MKMapView!
    
    
    
    
    
    let regionRadius: CLLocationDistance = 10
    let locManager = CLLocationManager()
    var isRunning = false
    var currentLocation:CLLocation!
    var startButton : UIButton!
    
    var pointsTraveled:[CLLocation] = [CLLocation]()
    
    
    lazy var timer = NSTimer()
    
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        MapView.setRegion(coordinateRegion, animated: true)
    }
    
    
    
    func createStartButton(view: UIView)->UIButton{
        let startButton = UIButton(frame: CGRect(x: self.view.frame.size.width/2 - 50, y: 7 * self.view.frame.size.height/8, width: 100, height: 44))
        
        startButton.setTitle("Start Run", forState: UIControlState.Normal)
        startButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        startButton.backgroundColor = UIColor.greenColor()
        startButton.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(startButton)
        
        
        return startButton

        
    }
    
    func buttonAction(sender:UIButton!)
    {
        if self.isRunning == false{
            self.isRunning = true
            self.startButton.setTitle("Stop Run", forState: UIControlState.Normal)
            self.startButton.backgroundColor = UIColor.redColor()

        }
        else if self.isRunning == true{
            self.isRunning = false
            self.startButton.setTitle("Start Run", forState: UIControlState.Normal)
            self.startButton.backgroundColor = UIColor.greenColor()
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        self.startButton = createStartButton(self.view)
        
        self.MapView.delegate = self
        
        locManager.requestWhenInUseAuthorization()
        
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse){
            
            locManager.delegate = self
            locManager.desiredAccuracy = kCLLocationAccuracyBest
            locManager.startUpdatingLocation()
            self.currentLocation = locManager.location
            
            print("[UPDATE]: User has authorized Core Location Updates")
            
        }
        else{
            print("[ERROR]: User has not authorized Core Location Updates")
        }
        
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
        self.currentLocation = locations.last
        centerMapOnLocation(self.currentLocation)
        
        if isRunning == true{
            print("Running... Tracking Location")
            
            
            if pointsTraveled.count >= 1{
                var coords = [CLLocationCoordinate2D]()
                coords.append(self.pointsTraveled.last!.coordinate)
                coords.append(self.currentLocation.coordinate)
                
                print("Here")
                
                MapView.addOverlay(MKPolyline(coordinates: &coords, count: coords.count))

            }
            
            
            
            
            pointsTraveled.append(self.currentLocation)

        }
        else{
            print("Running... Not Tracking")
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

