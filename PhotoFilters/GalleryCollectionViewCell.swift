//
//  GalleryCollectionViewCell.swift
//  PhotoFilters
//
//  Created by Alexandra Norcross on 1/12/15.
//  Copyright (c) 2015 Alexandra Norcross. All rights reserved.
//

import UIKit

class GalleryCollectionViewCell: UICollectionViewCell {
  //Image:
  var imageView = UIImageView()
  
  //Initialize: Set cell.
  override init(frame: CGRect) {
    //Super:
    super.init(frame: frame)
    
    //Layout: add subviews and set constraints
    //Image:
    self.addSubview(imageView)
    imageView.frame = self.bounds
    //Content mode:
    imageView.contentMode = UIViewContentMode.ScaleAspectFill
    imageView.layer.masksToBounds = true
  } //end init
  
  //Initialize.
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  } //end init
}
