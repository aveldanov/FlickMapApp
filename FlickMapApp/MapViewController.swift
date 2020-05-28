//
//  MapViewController.swift
//  FlickMapApp
//
//  Created by Veldanov, Anton on 5/24/20.
//  Copyright © 2020 Anton Veldanov. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, UIGestureRecognizerDelegate {
  
  var locationManager = CLLocationManager()
  let authorizationStatus = CLLocationManager.authorizationStatus()
  let regionRadious: Double = 1000 // in meters
  
  @IBOutlet weak var mapViewOutlet: MKMapView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    mapViewOutlet.delegate = self
    locationManager.delegate = self
    configureLocationServices()
    addDoubleTap()
  }
  
  func addDoubleTap(){
    let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
    
    doubleTap.numberOfTapsRequired = 2
    doubleTap.delegate = self
    mapViewOutlet.addGestureRecognizer(doubleTap)
    
  }
  
  
  

  @IBAction func centerMapButtonPressed(_ sender: UIButton) {
    
    if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse{
      centerMapOnUserLocation()

      
    }
  }
  
}


extension MapViewController: MKMapViewDelegate{
  
  func centerMapOnUserLocation(){
    guard let coordinate = locationManager.location?.coordinate else { return }
    
    let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionRadious*2, longitudinalMeters: regionRadious*2)
    
    mapViewOutlet.setRegion(coordinateRegion, animated: true)
  }
  
  @objc func dropPin(sender: UITapGestureRecognizer){
//    print("Pin was dropped")
    
    let touchPoint = sender.location(in: mapViewOutlet)
    // convert to map coordinate (lat/lon)
//    print("point:", touchPoint)
    let touchCoordinate = mapViewOutlet.convert(touchPoint, toCoordinateFrom: mapViewOutlet)
    
//    print("coord:", touchCoordinate)
    
    let annotation = DroppablePin(coordinate: touchCoordinate, identifier: "droppablePin")
    mapViewOutlet.addAnnotation(annotation)
    let coordinateRegion = MKCoordinateRegion(center: touchCoordinate, latitudinalMeters: regionRadious*2, longitudinalMeters: regionRadious*2)
    mapViewOutlet.setRegion(coordinateRegion, animated: true)
  }
  
  
}


extension MapViewController: CLLocationManagerDelegate{
  func configureLocationServices(){
    if authorizationStatus == .notDetermined{
      locationManager.requestAlwaysAuthorization()
    }else{
      // if we approved no need to do anything therefore - return
      return
    }
    
  }
  
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    centerMapOnUserLocation()
  }
  
  
}

