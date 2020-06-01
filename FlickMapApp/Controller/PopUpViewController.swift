//
//  PopUpViewController.swift
//  FlickMapApp
//
//  Created by Veldanov, Anton on 6/1/20.
//  Copyright © 2020 Anton Veldanov. All rights reserved.
//

import UIKit

class PopUpViewController: UIViewController, UIGestureRecognizerDelegate {
  var passedImage: UIImage?
  
  
  
  @IBOutlet weak var popUpImageView: UIImageView!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    popUpImageView.image = passedImage
    addDoubleTap()
  }
  
  
  func initData(forImage image: UIImage){
    
    passedImage = image
    
  }
  
  func addDoubleTap(){
    
    let doubleTap = UITapGestureRecognizer(target: self, action: #selector(screenWasDoubleTapped))
    doubleTap.numberOfTapsRequired = 2
    
    doubleTap.delegate = self
    view.addGestureRecognizer(doubleTap)
  }
  
  @objc func screenWasDoubleTapped(){
    dismiss(animated: true, completion: nil)
  }
  
  
}
