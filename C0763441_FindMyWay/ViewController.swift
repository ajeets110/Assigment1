//
//  ViewController.swift
//  C0763441_FindMyWay
//
//  Created by MacStudent on 2020-01-14.
//  Copyright © 2020 MacStudent. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var zoomStppr: UIStepper!
    var locationManager = CLLocationManager()
    var mode = MKDirectionsTransportType()
    var location = CLLocationCoordinate2D()
    var coordinate = CLLocationCoordinate2D()
    @IBOutlet weak var navigateButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
                
        let userLocation: CLLocation = locations[0]
        
        // getting latitude and longitude
        let lat = userLocation.coordinate.latitude
        let long = userLocation.coordinate.longitude
        
        // getting deltas for span
        let latDelta : CLLocationDegrees = 0.05
        let longDelta : CLLocationDegrees = 0.05
               
        // setting span and location
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
        location = CLLocationCoordinate2D(latitude: lat, longitude: long)
               
        // setting region
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        
        // add double tap gesture
        let uidtgr = UITapGestureRecognizer(target: self, action: #selector(doubuleTap))
        uidtgr.numberOfTapsRequired = 2
        mapView.addGestureRecognizer(uidtgr)
        
        
    }
    
   
    
    @objc func doubuleTap(gestureRecognizer: UIGestureRecognizer){
        
        let touchPoint = gestureRecognizer.location(in: mapView)
        coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        let annotation = MKPointAnnotation()
        annotation.title = "Destination"
        annotation.coordinate = coordinate
        if mapView.annotations.count == 1 {
        
            mapView.addAnnotation(annotation)
            
        } else {
            
            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotation(annotation)
        }
        
    }
    
    
    @IBAction func navigateBtn(_ sender: Any) {
        
        self.mapView.removeOverlays(mapView.overlays)
        directions(mode: mode)
        
    }
    
    
    @objc func directions(mode : MKDirectionsTransportType){
        
        let sourcePlacemark = MKPlacemark(coordinate: location)
        let destPlacemark = MKPlacemark(coordinate: coordinate)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = MKMapItem(placemark: sourcePlacemark)
        directionRequest.destination = MKMapItem(placemark: destPlacemark)
        
        
        let direction = MKDirections(request: directionRequest)
        direction.calculate{ (response, error) in
            guard let directionResponse = response else {
                if let error = error {
                    print("Unable to find navigation")
                }
                return
            }
            // adding route
            let route = directionResponse.routes[0]
            self.mapView.addOverlay(route.polyline, level: .aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }
        self.mapView.delegate = self
        }
    
        @IBAction func zoomStepper(_ sender: UIStepper) {
            
               sender.maximumValue = 5
               sender.minimumValue = -5
               
               if sender.value < 0{
                   let region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: -0.1, longitudeDelta: -0.1))
                   self.mapView.setRegion(region, animated: true)
                
                   
               } else if sender.value > 0{
                   let region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: +0.1, longitudeDelta: +0.1))
                   self.mapView.setRegion(region, animated: true)
               
           }
            
    }
    @IBAction func mode(_ sender: UISegmentedControl) {
        
        if sender.isEnabledForSegment(at: 0){
            mode = .walking
        }
        else {
            mode = .automobile        }
        
    }
    
}
    
extension ViewController: MKMapViewDelegate
{
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.fillColor = UIColor.black
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 3
        return renderer
}
    

}
