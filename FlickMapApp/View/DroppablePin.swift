//
//  DroppablePin.swift
//  FlickMapApp
//
//  Created by Veldanov, Anton on 5/28/20.
//  Copyright © 2020 Anton Veldanov. All rights reserved.
//

import UIKit
import MapKit

class DroppablePin: NSObject, MKAnnotation {
  dynamic var coordinate: CLLocationCoordinate2D
  var identifier: String
  init(coordinate: CLLocationCoordinate2D, identifier: String){
    self.coordinate = coordinate
    self.identifier = identifier
//    super.init()
  }
  }
