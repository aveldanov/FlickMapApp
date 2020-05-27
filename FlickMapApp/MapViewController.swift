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

  @IBOutlet weak var mapViewOutlet: MKMapView!
  override func viewDidLoad() {
    super.viewDidLoad()
    mapViewOutlet.delegate = self
  }

  @IBAction func centerMapButtonPressed(_ sender: UIButton) {
  }
  
}


extension MapViewController: MKMapViewDelegate{
  
  
  
  
}

