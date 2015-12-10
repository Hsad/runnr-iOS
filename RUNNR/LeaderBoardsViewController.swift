//
//  LeaderBoardsViewController.swift
//  RUNNR
//
//  Created by Ian O'Boyle on 11/5/15.
//  Copyright © 2015 Ian O'Boyle. All rights reserved.
//

import UIKit
import MapKit
import CoreData


extension LeaderBoardsViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let polyline         = overlay as! MKPolyline
        let renderer         = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = UIColor.blueColor()
        renderer.lineWidth   = 3
        return renderer
    }
    
}
class LeaderBoardsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var MapView: MKMapView!
    var items: [String] = []
    var names :[String] = []
    var distances : [String] = [ "244", "323", "245", "500"]
    var time : [String] = [ "22.2", "33.3", "44.4", "55.5" ]
    var itemsToRuns: [String : Run] = [String: Run]()
    var fetchedItems = [NSManagedObject]()
    
    var tableData : [ String : [(AnyObject, AnyObject)] ] = [String:[(AnyObject, AnyObject)]]()
    var finaltableData : [ (String, AnyObject, AnyObject) ] = []
    
    override func viewDidLoad() {
        //names = [String]()
        //distances = [String]()
        super.viewDidLoad()
        
        TableView.delegate = self
        TableView.dataSource = self
        MapView.delegate = self
        TableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        // Do any additional setup after loading the view.
        itemsToRuns = [String: Run]()
        fetchedItems = [NSManagedObject]()
        itemsToRuns = [String: Run]()
        
        
        let httpHelper = restHTTPhelper()
        
        httpHelper.makeGetRequest("http://localhost:3000/runs"){
            (result: NSDictionary) in
            do{
                let data = result["answer"]!.dataUsingEncoding(NSUTF8StringEncoding)
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as? [NSDictionary]
                
                for runItem in json!{
                    
                    let userName = runItem["username"]!
                    let runCoordinates = runItem["coordinates"]!
                    let distance = runItem["distance"]!
                    
                    
                    if (self.tableData[String(userName)] != nil) {
                        self.tableData[String(userName)]!.append((distance,runCoordinates))
                    }
                    else{
                        self.tableData[String(userName)] = [(distance, runCoordinates)]
                        self.names.append(String(userName))
                    }
                    
                    for user in self.names{
                        for (distance, coordinates) in self.tableData[user]! {
                            self.finaltableData.append((user, distance, coordinates))
                        }
                    }
                    self.TableView.reloadData()
                    
                }
                
            }catch{
                print("Error retrieving Run data")
            }
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.names.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = TableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        print(indexPath.row)
        cell.textLabel?.text = self.names[indexPath.row]
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
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("You selected cell #\(indexPath.row)!")
        
        
        var runsToDraw = [Run]()
        
        for item in self.tableData[self.names[indexPath.row]]!{
            print("User \(self.names[indexPath.row]) ran: \(item.0) coordinates: \(item.1)\n$$$$$$$$$$$$$$$$$\n")
            

            var coordinatesTraveled = item.1 as! String
            var distance = item.0 as! String
            var doubleDistance = Double(distance)
            
            
            coordinatesTraveled = String(coordinatesTraveled.characters.dropFirst(1))
            coordinatesTraveled = String(coordinatesTraveled.characters.dropLast(1))
            
            var coordList = coordinatesTraveled.componentsSeparatedByString(", ")
            
            
            
            var coordinatePairs : [(Double, Double)] = [(Double, Double)]()
            var prevCoordinate:Double!
            var flag = false
            for coordinate in coordList{
                if prevCoordinate == nil{
                    prevCoordinate = Double(coordinate)
                    continue
                }
                else{
                    if flag == false{
                    coordinatePairs.append((prevCoordinate, Double(coordinate)!))
                        flag = true
                    }
                    else{
                        flag = false
                    }
                }
                prevCoordinate = Double(coordinate)
            }

            var runLocations = [CLLocation]()
            for (lattitude, longitude) in coordinatePairs{
                var newLocation = CLLocation(latitude: lattitude, longitude: longitude)
                print(newLocation)
                runLocations.append(newLocation)
            }
            var newRun = Run(forExistingRun: doubleDistance!, seconds: 0.0, pointsTraveled: runLocations)
            runsToDraw.append(newRun)
        }
        
        
        MapView.removeOverlays(MapView.overlays)
        for selectedRun in runsToDraw{
            MapView.addOverlay(polyline(selectedRun))
            centerMapOnLocation(selectedRun.pointsTraveled.last!)
        }
        
    }
    
    func centerMapOnLocation(location: CLLocation) {
        //Center the MKView on a given Location
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            320, 320)
        MapView.setRegion(coordinateRegion, animated: true)
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
