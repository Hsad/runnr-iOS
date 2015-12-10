//
//  Run.swift
//  RUNNR
//
//  Created by Ian O'Boyle on 10/26/15.
//  Copyright © 2015 Ian O'Boyle. All rights reserved.
//

import Foundation
import MapKit
import HealthKit



class Run : NSObject {
    //A class to represent a Run object.
    var timer : NSTimer!                                    //A timer to be fired every second of the run
    var distance = 0.0                                      //Total Distance enforced as a Double
    var seconds = 0.0                                       //Total Seconds of the Run enforced as a Double
    var pointsTraveled:[CLLocation] = [CLLocation]()        //An array holding the Location objects of the route
    var overlay: MKOverlay!                                 //The corresponding Overlay associated with the run
    var currentPace: HKQuantity!                            //Current Pace of this run represented as a HealthKit Quantity Object
    
    override init(){
        super.init()
        //Define what selectors this object responds too, 
        //Generate a Timer to keep track of the run
        self.respondsToSelector("eachSecond:")
        timer = NSTimer.scheduledTimerWithTimeInterval(1,
            target: self,
            selector: "eachSecond:",
            userInfo: nil,
            repeats: true)
    }
    convenience init(forExistingRun distance: Double, seconds: Double, pointsTraveled: [CLLocation]){
        self.init()
        self.kill()
        self.distance = distance
        self.seconds = seconds
        self.pointsTraveled = pointsTraveled
    }
    func incrementDistance(value: CLLocationDistance){
        //Increment the Distance by some CLLocationDistance. 
        //This is intended to be used with a nested call to determine 
        // the distance between too CLLocation Objects.
        distance += value
    }
    func kill(){
        //Invalidate the timer of the Run object
        timer.invalidate()
        //TO DO: Any necassary clean up when a Run is completed
    }
    func giveOverlay(overlay: MKOverlay){
        //Assign an overlay to this Run
        self.overlay = overlay
    }
    func addLocation(location : CLLocation){
        //Add a location's coordinates to the points traveled in this Run
        pointsTraveled.append(location)
    }
    func eachSecond(timer: NSTimer) {
        //This function is fired in time with the timer. This updates the Run's distance, time, and pace
        //This function also determines the current pace of this run.
        seconds++
        let paceUnit = HKUnit.secondUnit().unitDividedByUnit(HKUnit.meterUnit())
        let paceQuantity = HKQuantity(unit: paceUnit, doubleValue: seconds / distance)
        currentPace = paceQuantity
    }
    
    func getCoordinatesOfRoute()->[CLLocation]{
        //Return the coordinates of this Run.
        return self.pointsTraveled
    }
    
}