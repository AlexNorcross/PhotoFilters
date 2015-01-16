//
//  PhotosViewController.swift
//  PhotoFilters
//
//  Created by Alexandra Norcross on 1/14/15.
//  Copyright (c) 2015 Alexandra Norcross. All rights reserved.
//

import UIKit
import Photos

class PhotosViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
  //MARK: Properties
  
  //NOTE: required to be set before View Controller is presented
  //Delegate: points to back to View Controller
  var delegate: ImageSelectedProtocol?
  //View Controller image size:
  var destinationImageSize: CGSize!
  
  //Collection View: to display images from photos
  var photosCollectionView: UICollectionView!

  //Image manager, collection & results:
  var imageManager: PHCachingImageManager!
  var photoCollection: PHCollection!
  var photoFetchResults: PHFetchResult!
 
  //Image width & height:
  let cellWid = 100
  let cellHgt = 100
  
  //Pinch gesture:
  var pinchGesture: PinchGestureOnCollectionView!
  
  //MARK: ViewController object layout
  
  //Function: Set View Controller - objects, layout, and actions.
  override func loadView() {
    //Subview dictionary: for Visual Format Language
    var dictionarySubview = [String : AnyObject]()
    
    //Root View:
    let rootView = UIView(frame: UIScreen.mainScreen().bounds)
    rootView.backgroundColor = UIColor.whiteColor()
    
    //Layout: add subviews and set constraints
      //Collection view layout:
      let layoutFlow = UICollectionViewFlowLayout()
      layoutFlow.itemSize = CGSize(width: cellWid, height: cellHgt)
      //Collection view:
      photosCollectionView = UICollectionView(frame: rootView.frame, collectionViewLayout: layoutFlow)
      rootView.addSubview(photosCollectionView)
      photosCollectionView.setTranslatesAutoresizingMaskIntoConstraints(false)
      dictionarySubview["photosCollectionView"] = photosCollectionView
      //Constraints: stretching horizontally & vertically across screen
      let photosContrainstWid = NSLayoutConstraint.constraintsWithVisualFormat("H:|-5-[photosCollectionView]-5-|", options: nil, metrics: nil, views: dictionarySubview)
      rootView.addConstraints(photosContrainstWid)
      let photosConstraintHgt = NSLayoutConstraint.constraintsWithVisualFormat("V:|-5-[photosCollectionView]-5-|", options: nil, metrics: nil, views: dictionarySubview)
      rootView.addConstraints(photosConstraintHgt)
      //Appearance:
      photosCollectionView.backgroundColor = UIColor.whiteColor()
    
    //Set root view.
    self.view = rootView
  } //end func
  
  //Function: Setup View Controller after loading the view.
  override func viewDidLoad() {
    //Super:
    super.viewDidLoad()
    
    //Photo/Assets:
    imageManager = PHCachingImageManager()
    photoFetchResults = PHAsset.fetchAssetsWithOptions(nil) //all
    
    //Collection view:
    //Register collection view cell.
    photosCollectionView.registerClass(GalleryCollectionViewCell.self, forCellWithReuseIdentifier: "CELL_PHOTO")
    //Collection view: data source & delegate
    photosCollectionView.dataSource = self
    photosCollectionView.delegate = self
    
    //Initialize pinch gesture.
    self.pinchGesture = PinchGestureOnCollectionView(collectionView: photosCollectionView)
  } //end func
  
  //MARK: UICollectionViewDataSource
  
  //Function: Set collection view cell count.
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return photoFetchResults.count
  } //end func
  
  //Function: Set collection view cell content.
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    //Cell:
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CELL_PHOTO", forIndexPath: indexPath) as GalleryCollectionViewCell
    //Cell contents:
    let asset = photoFetchResults[indexPath.row] as PHAsset
    imageManager.requestImageForAsset(asset, targetSize: CGSize(width: cellWid, height: cellHgt), contentMode: PHImageContentMode.AspectFill, options: nil) { (currentImage, info) -> Void in
      cell.imageView.image = currentImage
    } //end closure
    //Return cell.
    return cell
  } //end func
  
  //MARK: UICollectionViewDelegate
  
  //Function: Set selected image controller and pop View Controller.
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    //Set selected image.
    let asset = photoFetchResults[indexPath.row] as PHAsset
    imageManager.requestImageForAsset(asset, targetSize: self.destinationImageSize, contentMode: PHImageContentMode.AspectFill, options: nil) { (currentImage, info) -> Void in
      //Set selected image.
      self.delegate?.controllerDidSelectImage(currentImage)
      //Go back to view controller.
      self.navigationController?.popViewControllerAnimated(true)
    } //end closure
  } //end func
}
