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
  var spinner: UIActivityIndicatorView?
  var progresLabel: UILabel?
  var screenSize = UIScreen.main.bounds
  
  var flowLayout = UICollectionViewFlowLayout()
  var collectionView: UICollectionView?
  
  
  
  @IBOutlet weak var mapViewOutlet: MKMapView!
  @IBOutlet weak var pullUpViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var pullUpView: UIView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    mapViewOutlet.delegate = self
    locationManager.delegate = self
    configureLocationServices()
    addDoubleTap()
    
    collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
    collectionView?.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: "photoCell")
    collectionView?.delegate = self
    collectionView?.dataSource = self
  }
  
  
  //MARK: - Methods
  
  func addDoubleTap(){
    let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
    
    doubleTap.numberOfTapsRequired = 2
    doubleTap.delegate = self
    mapViewOutlet.addGestureRecognizer(doubleTap)
    
  }
  
  
  func animateViewUp(){
    pullUpViewHeightConstraint.constant = 300
    UIView.animate(withDuration: 0.3) {
      self.view.layoutIfNeeded()
    }
  }
  
  func addSwipe(){
    
    let swipe = UISwipeGestureRecognizer(target: self, action: #selector(animateViewDown))
    swipe.direction = .down
    pullUpView.addGestureRecognizer(swipe)
  }
  
  @objc func animateViewDown(){
    pullUpViewHeightConstraint.constant = 0
    UIView.animate(withDuration: 0.3) {
      self.view.layoutIfNeeded()
    }
  }
  
  func addSpinner(){
    
    spinner = UIActivityIndicatorView(style: .large)
    spinner?.center = CGPoint(x: (screenSize.width/2), y: pullUpViewHeightConstraint.constant/2)
    spinner?.color = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
    spinner?.startAnimating()
    pullUpView.addSubview(spinner!)
    
  }
  
  func removeSpinner(){
    if spinner != nil{
      spinner?.removeFromSuperview()
    }
    
  }
  
  
  func addProgressLabel(){
    
    progresLabel = UILabel()
    progresLabel?.frame = CGRect(x: (screenSize.width/2) - 120, y: 175, width: 240, height: 40)
    progresLabel?.font = UIFont(name: "Avenir Next", size: 18)
    progresLabel?.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
    progresLabel?.textAlignment = .center
    //    progresLabel?.text = "Hello World"
    pullUpView.addSubview(progresLabel!)
  }
  
  func removeProgressLabel(){
    if progresLabel != nil{
      progresLabel?.removeFromSuperview()
    }
    
  }
  
  
  
  @IBAction func centerMapButtonPressed(_ sender: UIButton) {
    
    if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse{
      centerMapOnUserLocation()
      
      
    }
  }
  
}

//MARK: - MKMapViewDelegate

extension MapViewController: MKMapViewDelegate{
  
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    if annotation is MKUserLocation{
      return nil
    }
    let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
    pinAnnotation.pinTintColor = #colorLiteral(red: 1, green: 0.6390113235, blue: 0, alpha: 1)
    pinAnnotation.animatesDrop = true
    return pinAnnotation
  }
  
  
  
  
  func centerMapOnUserLocation(){
    guard let coordinate = locationManager.location?.coordinate else { return }
    
    let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionRadious*2, longitudinalMeters: regionRadious*2)
    
    mapViewOutlet.setRegion(coordinateRegion, animated: true)
  }
  
  @objc func dropPin(sender: UITapGestureRecognizer){
    removePin()
    removeSpinner()
    removeProgressLabel()
    
    animateViewUp()
    addSwipe()
    addSpinner()
    addProgressLabel()
    
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
  
  func removePin(){
    for annotation in mapViewOutlet.annotations{
      mapViewOutlet.removeAnnotation(annotation)
      
    }
    
  }
  
}



//MARK: - CLLocationManagerDelegate


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


extension MapViewController: UICollectionViewDelegate, UICollectionViewDataSource{
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 4
  }
  

  
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    return UICollectionViewCell()
  }
  
  
  
  
  
  
}
