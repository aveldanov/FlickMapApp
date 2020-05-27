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

class MapViewController: UIViewController {
  
  var locationManager = CLLocationManager()
  let authorizationStatus = CLLocationManager.authorizationStatus()
  let regionRadious: Double = 1000 // in meters
  
  @IBOutlet weak var mapViewOutlet: MKMapView!
  override func viewDidLoad() {
    super.viewDidLoad()
    mapViewOutlet.delegate = self
    locationManager.delegate = self
    configureLocationServices()
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

