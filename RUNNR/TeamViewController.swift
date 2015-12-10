//
//  TeamViewController.swift
//  RUNNR
//
//  Created by Ian O'Boyle on 11/5/15.
//  Copyright © 2015 Ian O'Boyle. All rights reserved.
//

import UIKit
import MapKit


class TeamViewController: UIViewController, UITableViewDelegate,UITableViewDataSource, MKMapViewDelegate {
    
    @IBOutlet weak var TableView: UITableView!
    
    @IBOutlet weak var MapView: MKMapView!
    
    var teams = ["red", "green", "blue", "yellow"]
    var redUsers = [String]()
    var blueUsers = [String]()
    var greenUsers = [String]()
    var yellowUsers = [String]()
    var currentDisplay = ""
    var teamCoordinates = [Int : [CLLocationCoordinate2D]]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        TableView.delegate = self
        MapView.delegate = self
        TableView.dataSource = self
        TableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        
        
        // Do any additional setup after loading the view.
    }
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolygon {
            let polygonView = MKPolygonRenderer(overlay: overlay)
            if  currentDisplay == "red"{
                polygonView.strokeColor = UIColor.redColor()
            }
            else if currentDisplay == "green"{
                polygonView.strokeColor = UIColor.greenColor()
            }
            else if currentDisplay == "blue"{
                polygonView.strokeColor = UIColor.blueColor()
            }
            else if currentDisplay == "yellow"{
            polygonView.strokeColor = UIColor.yellowColor()
            }
            else{
            }
            
            return polygonView
        }
        
        return MKPolygonRenderer()
    }
    func centerMapOnLocation(location: CLLocation) {
        //Center the MKView on a given Location
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            1000, 1000)
        MapView.setRegion(coordinateRegion, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func addBoundry(team: Int)
    {
        
        var points=[CLLocationCoordinate2DMake(49.142677,  -123.135139 + Double(team * 10)),CLLocationCoordinate2DMake(49.142730, -123.125794 + Double(team * 10)),CLLocationCoordinate2DMake(49.140874, -123.125805 + Double(team * 10)),CLLocationCoordinate2DMake(49.140885, -123.135214 + Double(team * 10))]
        
        
        var points2 = [CLLocationCoordinate2DMake(49.142677,  -123.135139 + Double(team * 10)),CLLocationCoordinate2DMake(49.142730, -123.125794 + Double(team * 10)),CLLocationCoordinate2DMake(49.140874, -123.125805 + Double(team * 10)),CLLocationCoordinate2DMake(49.140885, -123.135214 + Double(team * 10)) , CLLocationCoordinate2DMake(49.140900, -123.135214 + Double(team * 10))]
        
        if team % 2 == 0 {
            points = points2
            print("using points2")
        }
        let polygon = MKPolygon(coordinates: &points, count: points.count)
        teamCoordinates[team] = points
        
        MapView.addOverlay(polygon)
    }

    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        print("You've selected cell # \(indexPath.row)")
        currentDisplay = teams[indexPath.row]
        addBoundry(indexPath.row)
        centerMapOnLocation(CLLocation(latitude: teamCoordinates[indexPath.row]![0].latitude, longitude: teamCoordinates[indexPath.row]![0].longitude))
        
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teams.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = TableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        cell.textLabel!.text = teams[indexPath.row]
        cell.textLabel!.textAlignment = .Center
        return cell
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
