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
  
  //Initialize: Set class properties.
  override init(frame: CGRect) {
    //Super:
    super.init(frame: frame)
    
    //Subview dictionary: for Visual Format Language
    var dictionarySubview = [String : AnyObject]()
    
    //Layout: add subviews and set constraints
    //Image:
    self.addSubview(imageView)
    imageView.frame = self.bounds
    imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
    dictionarySubview["imageView"] = imageView
    //Constraints: stretch horizontally & vertically across collection view cell
    let imageViewContraintHoriz = NSLayoutConstraint.constraintsWithVisualFormat("H:|[imageView]|", options: nil, metrics: nil, views: dictionarySubview)
    self.addConstraints(imageViewContraintHoriz)
    let imageViewConstraintVert = NSLayoutConstraint.constraintsWithVisualFormat("V:|[imageView]|", options: nil, metrics: nil, views: dictionarySubview)
    self.addConstraints(imageViewConstraintVert)
    //Content mode:
    imageView.contentMode = UIViewContentMode.ScaleAspectFill
    imageView.layer.masksToBounds = true
  } //end init
  
  //Initialize.
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  } //end init
}
