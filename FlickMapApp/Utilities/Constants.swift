//
//  Constants.swift
//  FlickMapApp
//
//  Created by Veldanov, Anton on 5/30/20.
//  Copyright © 2020 Anton Veldanov. All rights reserved.
//

import Foundation


func flickrUrl(forApiKey key:String, with annotation: DroppablePin, andNumberOfPhotos  number:Int)->String{
  

  let url = "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(key)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&radius_units=mi&per_page=\(number)&format=json&nojsoncallback=1"
  
  
  print(url)
  return url
}
