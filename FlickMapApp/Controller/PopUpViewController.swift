//
//  PopUpViewController.swift
//  FlickMapApp
//
//  Created by Veldanov, Anton on 6/1/20.
//  Copyright © 2020 Anton Veldanov. All rights reserved.
//

import UIKit

class PopUpViewController: UIViewController {
  var passedImage: UIImage?
  
  
  
  @IBOutlet weak var popUpImageView: UIImageView!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    popUpImageView.image = passedImage
    
  }
  
  
  func initData(forImage image: UIImage){
    
    passedImage = image
    
  }
  
  func addDoubleTap(){
    
    
    
  }
  
  
}
