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
    var overlay : MKOverlay!
    
    
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
                
                for coordinate in owns{
                    do{
                        var newCoordinate = coordinate as! CoordinateEntity
                        xCoords.append(newCoordinate.latitude)
                        yCoords.append(newCoordinate.longitude)
                        
                    }
                }
                
                
                var locationCoords = [CLLocation]()
                if xCoords.count == yCoords.count {
                    for lat in xCoords {
                        for lon in yCoords{
                            let location = CLLocation(latitude: lat, longitude: lon)
                            print("\(lat) \(location.coordinate.latitude), \(lon) \(location.coordinate.longitude)")
                            locationCoords.append(location)
                        }
                    }
                }
                
                
                var newRun = Run(forExistingRun: distance, seconds: time, pointsTraveled: locationCoords)
                
                print(createAt)
                items.append(createAt)
                itemsToRuns[createAt] = newRun
                
                
                
                
                
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
        return self.items.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = TableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        
        
        var id_string = items[indexPath.row]
        var currentRun = itemsToRuns[id_string]
        cell.textLabel?.text = id_string + " " + String(round(currentRun!.distance*10)/10)
        cell.textLabel?.text = (cell.textLabel?.text)! + " ft " + String(currentRun!.seconds) + " s "
        cell.textLabel?.textAlignment = .Center
        
        return cell
    }
    
    func centerMapOnLocation(location: CLLocation) {
        //Center the MKView on a given Location
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            80.0, 80.0)
        MapView.setRegion(coordinateRegion, animated: true)
    }
    func drawRunOnMap(currentRun: Run, mapView: MKMapView){
        var coords = [CLLocationCoordinate2D]()
        for point in currentRun.pointsTraveled{
            coords.append(point.coordinate)
        }
        MapView.addOverlay(MKPolyline(coordinates: &coords, count: coords.count))
            }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("You selected cell #\(indexPath.row)!")
        if overlay != nil{
            MapView.removeOverlay(overlay)
        }
        var lookUpString = items[indexPath.row]
        var selectedRun = itemsToRuns[lookUpString]
        
        print(selectedRun!.pointsTraveled)
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.ShortStyle
        formatter.timeStyle = .ShortStyle
        
        
        centerMapOnLocation(selectedRun!.pointsTraveled.last!)
        drawRunOnMap(selectedRun!, mapView: self.MapView)
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
