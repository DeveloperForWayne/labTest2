//
//  ViewController.swift
//  labTest2
//
//  Created by Wei Xu on 2020-05-28.
//  Copyright © 2020 Georgebrown. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource {
        
    @IBOutlet weak var latitudeTxt: UITextField!
    @IBOutlet weak var longitudeTxt: UITextField!
    @IBOutlet weak var DisMapView: MKMapView!
    @IBOutlet weak var routeTableView: UITableView!
    
    
    var pinName = ["A", "B", "C", "D", "E"]
    var addPinTimes=0
    var positions:[CLLocationCoordinate2D]=[]
    var routeResults:[String]=[]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        DisMapView.delegate = self
        
        routeTableView.dataSource = self
        routeTableView.delegate = self
        self.routeTableView.rowHeight = 215;
        
        mapInit()
        
    }
    
    // Required function to draw the lines on the screen
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        print("Calling map renderer delegate function")
        
        // Test that the function actually received a polyline object
        // If no, then display nothing
        guard let polyline = overlay as? MKPolyline else {
            // An MKOverLayRender is the visual representation of your line
            // returning only MKOverlayRenderer() will display nothing on the screen
            return MKOverlayRenderer()
        }
        
        // If yes, then configure the line
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.lineWidth = 3.0            // thickness of line
        renderer.alpha = 0.5                // line transparency
        renderer.strokeColor = UIColor.red  // line colour
        
        return renderer
    }
    
    @IBAction func addPinPressed(_ sender: Any) {
        if(latitudeTxt.text=="") {
            print("Miss latitude input!")
            return;
        }
        if(longitudeTxt.text=="") {
            print("Miss ongitude input!")
            return;
        }
        
        if(addPinTimes>pinName.count-1) {
            print("No more than 5 pins are allowed!")
            return;
        }
        
        let doubleLatitude = Double(latitudeTxt.text!)
        let doubleLongitude = Double(longitudeTxt.text!)
        
        let pin = MKPointAnnotation()
        let givenPosition = CLLocationCoordinate2D(latitude: doubleLatitude!, longitude: doubleLongitude!)
        pin.coordinate = givenPosition
        pin.title = pinName[addPinTimes]
        addPinTimes += 1
        DisMapView.addAnnotation(pin)
        
        positions.append(givenPosition)
        let polyline = MKPolyline(coordinates: positions, count: positions.count)
        self.DisMapView.addOverlay(polyline)
        
        if(positions.count>1) {
            let oldPosition = positions[positions.count-2]
            let newPosition = positions[positions.count-1]
            
            let startPosition = CLLocationCoordinate2D(latitude: oldPosition.latitude, longitude: oldPosition.longitude)
            let endPosition = CLLocationCoordinate2D(latitude: newPosition.latitude, longitude: newPosition.longitude)
            
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: startPosition))
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: endPosition))
            request.requestsAlternateRoutes = true
            request.transportType = .automobile
            
            let directions = MKDirections(request: request)
            
            // 3. Send the request to Apple's servers and wait for a response
            directions.calculate {
                
                (response, error)
                in
                
                // 4. Check if your request failed
                if (error != nil) {
                    print("An error occured: ")
                    print(error)
                    return
                }
                
                // 5. Check if you got any directions back
                guard let unwrappedResponse = response else {
                    print("No directions found")
                    return
                }
                
                // 6. If the request was successful and you got directions, then output those directions to the screen.
                
                // 7. response.routes lists all the possible routes from point A to point B
                // Loop through the routes and show the steps in each route
                
                var routeResponse = unwrappedResponse.routes[0]
                print("Distance \(routeResponse.distance)")
                print("expectedTravelTime \(routeResponse.expectedTravelTime)")

                var resultT="Driving Directions from \(self.pinName[self.positions.count-2]) to \(self.pinName[self.positions.count-1])"
                resultT=resultT + "\n" + "Estimated time: \(routeResponse.expectedTravelTime)"
                
                for step in routeResponse.steps {
                       resultT = resultT + "\n" + "\(step.instructions)"
                }
                
                self.routeResults.append(resultT)
                
                self.routeTableView.reloadData()
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routeResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "routeCell") as! RouteTableViewCell
        
        if (cell == nil) {
            cell = RouteTableViewCell(style: .default, reuseIdentifier: "routeCell")
        }
        
        cell.routeTextView.text=routeResults[indexPath.row]
        return cell
    }
    
    
    @IBAction func clearMapPressed(_ sender: Any) {
        let allAnnotations = self.DisMapView.annotations
        self.DisMapView.removeAnnotations(allAnnotations)
        
        let allOverlays=self.DisMapView.overlays
        self.DisMapView.removeOverlays(allOverlays)
        
        routeResults=[]
        self.routeTableView.reloadData()
        
        mapInit()
    }
    
    @IBAction func geofencingPressed(_ sender: Any) {
        
    }
    
    func mapInit() {
        let initialLocation = CLLocationCoordinate2D(latitude: 36.112625, longitude: -115.176704)
        let zoom = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        let region = MKCoordinateRegion(center: initialLocation, span: zoom)
        
        DisMapView.setRegion(region, animated: true)
    }
}

