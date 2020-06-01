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
import Alamofire
import AlamofireImage

class MapViewController: UIViewController, UIGestureRecognizerDelegate {
  
  var locationManager = CLLocationManager()
  let authorizationStatus = CLLocationManager.authorizationStatus()
  let regionRadious: Double = 1000 // in meters
  var spinner: UIActivityIndicatorView?
  var progresLabel: UILabel?
  var screenSize = UIScreen.main.bounds
  var flowLayout = UICollectionViewFlowLayout()
  var collectionView: UICollectionView?
  var imageUrlArray = [String]()
  var imageArray = [UIImage]()
  
  
  
  @IBOutlet weak var mapViewOutlet: MKMapView!
  @IBOutlet weak var pullUpViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var pullUpView: UIView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    mapViewOutlet.delegate = self
    locationManager.delegate = self
    mapViewOutlet.showsUserLocation = true
    configureLocationServices()
    addDoubleTap()
    
    collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
    collectionView?.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: "photoCell")
    collectionView?.delegate = self
    collectionView?.dataSource = self
    collectionView?.backgroundColor = #colorLiteral(red: 0.9746869206, green: 0.9608208537, blue: 0.9301876426, alpha: 1)
    
//    registerForPreviewing(with: self, sourceView: collectionView!)
    let interaction = UIContextMenuInteraction(delegate: self)
    collectionView?.addInteraction(interaction)
    pullUpView?.addSubview(collectionView!)
    
    
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
    
    cancelAllSessions()
  }
  
  func addSpinner(){
    
    spinner = UIActivityIndicatorView(style: .large)
    spinner?.center = CGPoint(x: (screenSize.width/2), y: pullUpViewHeightConstraint.constant/2)
    spinner?.color = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
    spinner?.startAnimating()
    collectionView?.addSubview(spinner!)
    
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
    collectionView?.addSubview(progresLabel!)
  }
  
  func removeProgressLabel(){
    if progresLabel != nil{
      progresLabel?.removeFromSuperview()
    }
    
  }
  
  
  
  @IBAction func centerMapButtonPressed(_ sender: UIButton) {
    
    if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse{
      centerMapOnUserLocation()
      mapViewOutlet.reloadInputViews()
      
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
    cancelAllSessions()
    imageUrlArray = []
    imageArray = []
    collectionView?.reloadData()
    
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
    //    print(flickrUrl(forApiKey: apiKey, withAnnotation: annotation, andNumberOfPhotos: 40))
    
    mapViewOutlet.addAnnotation(annotation)
    let coordinateRegion = MKCoordinateRegion(center: touchCoordinate, latitudinalMeters: regionRadious*2, longitudinalMeters: regionRadious*2)
    mapViewOutlet.setRegion(coordinateRegion, animated: true)
    
    retrieveUrls(forAnnotation: annotation) { (finished) in
//      print(self.imageUrlArray)
      if finished{
        
        self.retrieveImages { (finished) in
          // hide spinner
          self.removeSpinner()
          // hide label
          self.removeProgressLabel()
          
          // reload collection view
          self.collectionView?.reloadData()
          
          
        }
      }
      
    }
  }
  
  func removePin(){
    for annotation in mapViewOutlet.annotations{
      mapViewOutlet.removeAnnotation(annotation)
      
    }
    
  }
  
  
  func retrieveUrls(forAnnotation annotation:DroppablePin, handler: @escaping (_ status:Bool)->() ){
    AF.request(flickrUrl(forApiKey: apiKey, withAnnotation: annotation, andNumberOfPhotos: 40)).responseJSON { (response) in
      
      guard let json = response.value as? Dictionary<String,AnyObject> else {return}
      let photosDict = json["photos"] as! Dictionary<String,AnyObject>
      
      let photosDictArray = photosDict["photo"] as! [Dictionary<String,AnyObject>]
      for photo in photosDictArray{
        //        print(photo)
        let postUrl = "https://farm\(photo["farm"]!).staticflickr.com/\(photo["server"]!)/\(photo["id"]!)_\(photo["secret"]!)_z_d.jpg"
        self.imageUrlArray.append(postUrl)
      }
      handler(true)
    }
    
  }
  
  
  func retrieveImages(handler: @escaping (_ status:Bool)->()){
    for url in imageUrlArray{
      AF.request(url).responseImage { (response) in
        guard let image = response.value else {return}
        self.imageArray.append(image)
        self.progresLabel?.text = "\(self.imageArray.count)/40 IMAGES LOADED"
        if self.imageUrlArray.count == self.imageArray.count{
//          means we are done
          handler(true)
        }
      }
      
    }
    
  }
  
  
  func cancelAllSessions(){
    AF.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
      sessionDataTask.forEach{$0.cancel()}
      downloadData.forEach{$0.cancel()}
    }
    
    print("Sessions are cancelled")
    
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
    return imageArray.count
  }
  
  
  
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    guard let cell = (collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCollectionViewCell) else{return UICollectionViewCell()}
    let imageFromIndex = imageArray[indexPath.row]
    let imageView = UIImageView(image: imageFromIndex)
    cell.addSubview(imageView)
    
    return cell
  }
  
  
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let popVC = storyboard?.instantiateViewController(withIdentifier: "PopUpViewController") as? PopUpViewController else {return}
    
    popVC.initData(forImage: imageArray[indexPath.row])
    present(popVC, animated: true, completion: nil)
  }
  
  
}



extension MapViewController: UIContextMenuInteractionDelegate{
  func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        guard let indexPath = collectionView?.indexPathForItem(at: location), let cell = collectionView?.cellForItem(at: indexPath) else {return nil}
           guard let popVC = storyboard?.instantiateViewController(withIdentifier: "PopUpViewController") as? PopUpViewController else {return nil}
        popVC.initData(forImage: imageArray[indexPath.row])
    present(popVC, animated: true, completion: nil)
    print("3D touch worked")
    print(location)
    return nil
    
  }
  
  
  
 
  
  
  
//  func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
//    guard let indexPath = collectionView?.indexPathForItem(at: location), let cell = collectionView?.cellForItem(at: indexPath) else {return nil}
//       guard let popVC = storyboard?.instantiateViewController(withIdentifier: "PopUpViewController") as? PopUpViewController else {return nil}
//    popVC.initData(forImage: imageArray[indexPath.row])
//    previewingContext.sourceRect = cell.contentView.frame
//    return popVC
//
//  }
//
//  func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
//    show(viewControllerToCommit, sender: self)
//  }
  
  
  
  
  
}
