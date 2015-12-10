//
//  UserAnalyticsViewController.swift
//  RUNNR
//
//  Created by Ian O'Boyle on 10/26/15.
//  Copyright © 2015 Ian O'Boyle. All rights reserved.
//

import UIKit
import MapKit
import CoreData

extension UserAnalyticsViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let polyline         = overlay as! MKPolyline
        let renderer         = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = UIColor.blueColor()
        renderer.lineWidth   = 3
        return renderer
    }
    
}

class UserAnalyticsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var MapView: MKMapView!
    @IBOutlet weak var TableView: UITableView!
    var items: [String] = []
    var itemsToRuns: [String : Run] = [String: Run]()
    var fetchedItems = [NSManagedObject]()
    var secondFetchedItems = [NSManagedObject]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TableView.delegate = self
        TableView.dataSource = self
        TableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        MapView.delegate = self
        
        itemsToRuns = [String: Run]()
        fetchedItems = [NSManagedObject]()
        itemsToRuns = [String: Run]()
        // Do any additional setup after loading the view.
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        //2
        let fetchRequest = NSFetchRequest(entityName: "RunEntity")
        
        
        
        //3
        var results = [RunEntity]()
        do {
            results = try managedContext.executeFetchRequest(fetchRequest) as! [RunEntity]
            for runItem in results{
                print("run")
                let userName = runItem.user
                let distance = runItem.distance
                let time = runItem.time
                let owns = runItem.owns
                let createAt = runItem.createdAt
                var xCoords = [Double]()
                var yCoords = [Double]()
                
                var locationCoords = [CLLocation]()
                for coordinate in owns{
                    do{
                        var newCoordinate = coordinate as! CoordinateEntity
                        let location = CLLocation(latitude: newCoordinate.latitude, longitude:  newCoordinate.longitude)
                        locationCoords.append(location)
                        
                    }
                }
                
                let newRun = Run(forExistingRun: distance, seconds: time, pointsTraveled: locationCoords)
                
                items.append(createAt)
                itemsToRuns[createAt] = newRun
                
                self.TableView.reloadData()
                
                
                
            }
        }
        catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        catch{
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.itemsToRuns.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = TableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        
        let id_string = items[indexPath.row]
        let currentRun = itemsToRuns[id_string]
        cell.textLabel?.text = id_string + " " + String(round(currentRun!.distance*10)/10)
        cell.textLabel?.text = (cell.textLabel?.text)! + " ft " + String(currentRun!.seconds) + " s "
        cell.textLabel?.textAlignment = .Center
        
        return cell
    }
    func polyline(run: Run) -> MKPolyline {
        var coords = [CLLocationCoordinate2D]()
        
        for location in run.pointsTraveled {
            coords.append(CLLocationCoordinate2D(latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude))
        }
        
        return MKPolyline(coordinates: &coords, count: run.pointsTraveled.count)
    }
    
    func centerMapOnLocation(location: CLLocation) {
        //Center the MKView on a given Location
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            320, 320)
        MapView.setRegion(coordinateRegion, animated: true)
    }

    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        for overlay in MapView.overlays{
            MapView.removeOverlay(overlay)
        }
        print("You selected cell #\(indexPath.row)!")
        let lookUpString = items[indexPath.row]
        let selectedRun = itemsToRuns[lookUpString]
        centerMapOnLocation(selectedRun!.pointsTraveled.last!)
        MapView.addOverlay(polyline(selectedRun!))

        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.ShortStyle
        formatter.timeStyle = .ShortStyle
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
