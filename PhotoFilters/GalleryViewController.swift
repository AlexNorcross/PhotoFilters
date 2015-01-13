//
//  GalleryViewController.swift
//  PhotoFilters
//
//  Created by Alexandra Norcross on 1/12/15.
//  Copyright (c) 2015 Alexandra Norcross. All rights reserved.
//

import UIKit

class GalleryViewController: UIViewController, UICollectionViewDataSource {
  //Collection View: to display images from gallery.
  var galleryCollectionView: UICollectionView!

  //Images: to display in collection view.
  var galleryImages = [UIImage]()
  
  //Function: Set View Controller - objects, layout, and actions.
  override func loadView() {
    //Subview dictionary: for Visual Format Language
    var dictionarySubview = [String : AnyObject]()
    
    //Root View:
    let rootView = UIView(frame: UIScreen.mainScreen().bounds)
    rootView.backgroundColor = UIColor.whiteColor()
    
    //MARK: ViewController views & subviews
    
    //Layout: add subviews and set constraints
      //Collection view layout:
      let layoutFlow = UICollectionViewFlowLayout()
      layoutFlow.itemSize = CGSize(width: 100, height: 100)
      //Collection view:
      galleryCollectionView = UICollectionView(frame: rootView.frame, collectionViewLayout: layoutFlow)
      rootView.addSubview(galleryCollectionView)
      galleryCollectionView.setTranslatesAutoresizingMaskIntoConstraints(false)
      dictionarySubview["galleryCollectionView"] = galleryCollectionView
      //Constraints: stretching horizontally & vertically across screen
      let galleryConstraintWid = NSLayoutConstraint.constraintsWithVisualFormat("H:|-5-[galleryCollectionView]-5-|", options: nil, metrics: nil, views: dictionarySubview)
      rootView.addConstraints(galleryConstraintWid)
      let galleryConstraintHgt = NSLayoutConstraint.constraintsWithVisualFormat("V:|-5-[galleryCollectionView]-5-|", options: nil, metrics: nil, views: dictionarySubview)
      rootView.addConstraints(galleryConstraintHgt)
      galleryCollectionView.backgroundColor = UIColor.whiteColor()
    
    //Set root view.
    self.view = rootView
  } //end func
  
  //Function: Setup View Controller after loading the view.
  override func viewDidLoad() {
    //Super:
    super.viewDidLoad()
    
    //Add images to gallery images array.
    galleryImages.append(UIImage(named: "bridge.jpeg")!)
    galleryImages.append(UIImage(named: "cityatnight.jpeg")!)
    galleryImages.append(UIImage(named: "parkbench.jpeg")!)
    galleryImages.append(UIImage(named: "street.jpeg")!)
    galleryImages.append(UIImage(named: "train.jpeg")!)
    galleryImages.append(UIImage(named: "vespa.jpeg")!)
    
    //Register collection view cell.
    galleryCollectionView.registerClass(GalleryCollectionViewCell.self, forCellWithReuseIdentifier: "CELL_GALLERY")
    
    //Collection view: data source
    galleryCollectionView.dataSource = self
  } //end func
  
  //Function: Set collection view cell count.
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return galleryImages.count
  } //end func
  
  //Function: Set collection view cell contents.
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    //Cell:
    var cell = collectionView.dequeueReusableCellWithReuseIdentifier("CELL_GALLERY", forIndexPath: indexPath) as GalleryCollectionViewCell
    
    //Set cell image.
    cell.imageView.image = galleryImages[indexPath.row]
    
    //Return cell.
    return cell
  } //end func
}
