//
//  ViewController.swift
//  PhotoFilters
//
//  Created by Alexandra Norcross on 1/12/15.
//  Copyright (c) 2015 Alexandra Norcross. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ImageSelectedProtocol, UICollectionViewDataSource {
  //MARK: Properties
  
  //Main image view:
  let imageViewMain = UIImageView()
  
  //Alert controller:
  let alertController = UIAlertController(title: "photos", message: "select an option", preferredStyle: UIAlertControllerStyle.Alert)
  
  //Photo button:
  var buttonPhoto: UIButton!
  
  //Image height & width:
  let thumbnailHgt = 100
  let thumbnailWid = 100
  
  //Collection view: to display filtered images
  var filteredImageCollectionView: UICollectionView!
  //Thumbnails of filtered images: to display collection view
  var filteredImageThumbnails = [FilteredThumbnail]()
  //Thumbnail of original image: to be filtered
  var thumbnailToFilter : UIImage?
  //Y-Constraint of filtered images collection view
  var filteredImageCollectionViewYConstraint: NSLayoutConstraint!
  
  //For filtered images: GPU context, image queue
  var contextGPU: CIContext!
  var queueForFilteringImages = NSOperationQueue()
  
  //MARK: ViewController object layout
  
  //Function: Set View Controller - objects, layout, and actions.
  override func loadView() {
    //Subview dictionary: for Visual Format Language
    var dictionarySubview = [String : AnyObject]()
    
    //Root View:
    let rootView = UIView(frame: UIScreen.mainScreen().bounds)
    rootView.backgroundColor = UIColor.whiteColor()
    
    //Layout: add subviews and set constraints
      //Image:
      rootView.addSubview(imageViewMain)
      imageViewMain.setTranslatesAutoresizingMaskIntoConstraints(false)
      dictionarySubview["imageViewMain"] = imageViewMain
      imageViewMain.backgroundColor = UIColor.grayColor()
      //Constraints: stretching horizontally & vertically across screen
      let imageViewMainConstraintWid = NSLayoutConstraint.constraintsWithVisualFormat("H:|-5-[imageViewMain]-5-|", options: nil, metrics: nil, views: dictionarySubview)
      rootView.addConstraints(imageViewMainConstraintWid)
      let imageViewMainConstraintHgt = NSLayoutConstraint.constraintsWithVisualFormat("V:|-65-[imageViewMain]-5-|", options: nil, metrics: nil, views: dictionarySubview)
      rootView.addConstraints(imageViewMainConstraintHgt)
      //Content mode:
      imageViewMain.contentMode = UIViewContentMode.ScaleAspectFill
      imageViewMain.layer.masksToBounds = true
      
      //Photo button:
      buttonPhoto = UIButton()
      rootView.addSubview(buttonPhoto)
      buttonPhoto.setTranslatesAutoresizingMaskIntoConstraints(false)
      dictionarySubview["buttonPhoto"] = buttonPhoto
      //Appearance:
      buttonPhoto.setTitle("photo", forState: .Normal)
      buttonPhoto.setTitleColor(UIColor.whiteColor(), forState: .Normal)
      buttonPhoto.backgroundColor = UIColor.blackColor()
      buttonPhoto.titleLabel?.font = UIFont(name: "Avenir-Black", size: 20)
      buttonPhoto.layer.cornerRadius = 5
      //Constraints: width; bottom center of screen
      let buttonPhotoConstraintWid = NSLayoutConstraint.constraintsWithVisualFormat("H:[buttonPhoto(150)]", options: nil, metrics: nil, views: dictionarySubview)
      buttonPhoto.addConstraints(buttonPhotoConstraintWid)
      let buttonPhotoConstraintBottom = NSLayoutConstraint.constraintsWithVisualFormat("V:[buttonPhoto]-20-|", options: nil, metrics: nil, views: dictionarySubview)
      rootView.addConstraints(buttonPhotoConstraintBottom)
      let buttonPhotoConstraintHoriz = NSLayoutConstraint(item: buttonPhoto, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: rootView, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 1.0)
      rootView.addConstraint(buttonPhotoConstraintHoriz)
    
      //Collection view: for filtered images
      //Collection view layout: with horizontal scroll
      let layoutFlow = UICollectionViewFlowLayout()
      layoutFlow.itemSize = CGSize(width: thumbnailWid, height: thumbnailHgt)
      layoutFlow.scrollDirection = .Horizontal
      //Collection view:
      filteredImageCollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layoutFlow)
      rootView.addSubview(filteredImageCollectionView)
      filteredImageCollectionView.setTranslatesAutoresizingMaskIntoConstraints(false)
      dictionarySubview["filteredImageCollectionView"] = filteredImageCollectionView
      //Appearance:
      filteredImageCollectionView.backgroundColor = UIColor.whiteColor()
      //Constraints: stretching across bottom of screen; initially off screen to show when needed.
      let filteredImagesConstraintWid = NSLayoutConstraint.constraintsWithVisualFormat("H:|-5-[filteredImageCollectionView]-5-|", options: nil, metrics: nil, views: dictionarySubview)
      rootView.addConstraints(filteredImagesConstraintWid)
      let filteredImagesConstraintHgt = NSLayoutConstraint.constraintsWithVisualFormat("V:[filteredImageCollectionView(\(thumbnailHgt + 10))]", options: nil, metrics: nil, views: dictionarySubview)
      filteredImageCollectionView.addConstraints(filteredImagesConstraintHgt)
      let filteredImagesConstraintBottom = NSLayoutConstraint.constraintsWithVisualFormat("V:[filteredImageCollectionView]-(-\(thumbnailHgt + 50))-|", options: nil, metrics: nil, views: dictionarySubview)
      rootView.addConstraints(filteredImagesConstraintBottom)
      //Y-Constraint:
      filteredImageCollectionViewYConstraint = filteredImagesConstraintBottom.first as NSLayoutConstraint
    
      //Set root view.
      self.view = rootView
    
    //Photo button: action
    buttonPhoto.addTarget(self, action: "buttonPhotoPressed", forControlEvents: UIControlEvents.TouchUpInside)
  } //end func
  
  //Function: Setup View Controller after loading the view.
  override func viewDidLoad() {
    //Super:
    super.viewDidLoad()

    //Collection view:
    //Register collection view cell.
    filteredImageCollectionView?.registerClass(GalleryCollectionViewCell.self, forCellWithReuseIdentifier: "CELL_IMAGE")
    //Collection view: data source
    filteredImageCollectionView?.dataSource = self
    
    //MARK: Alert Controller options/actions
    
    //Handle alert controller options/actions; and add option/action to alert controller.
      //Gallery: Show Gallery View Controller
      let actionAlertOptGallery = UIAlertAction(title: "get a photo in my gallery", style: .Default) { (action) -> Void in
        self.alertActionGalleryPressed()
      } //end closure
      alertController.addAction(actionAlertOptGallery)
    
      //Filter: Show collection selected image's filter options; if no photo selected, send user to gallery.
      let actionAlertOptFilter = UIAlertAction(title: "filter my photo", style: .Default) { (action) -> Void in
        if self.imageViewMain.image != nil {
          //Hide photo button.
          self.buttonPhoto.hidden = true
          //Present (with animation) collection view of filtered images.
          self.filteredImageCollectionViewYConstraint.constant = 100
          UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.view.setNeedsLayout()
          }) //end closure
        } //end if
        else {
          self.alertActionGalleryPressed()
        } //end else
      } //end closure
      alertController.addAction(actionAlertOptFilter)
    
    //MARK: Image Filtering setup
    
    //Image filtering: one-time processes
      //Filter names:
      let filterNames = ["CISepiaTone","CIPhotoEffectChrome", "CIPhotoEffectNoir"]
      //GPU context: setup
      let optionsGPU = [kCIContextWorkingColorSpace : NSNull()] //for speed
      let contextEAGL = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
      contextGPU = CIContext(EAGLContext: contextEAGL, options: optionsGPU)
      //Add a thumbnail for each filter.
      for filterName in filterNames {
        filteredImageThumbnails.append(FilteredThumbnail(filterName: filterName, contextGPU: contextGPU, queueImage: queueForFilteringImages))
      } //end for
  } //end func
  
  //MARK: ViewController object actions
  
  //Function: Handle event when Photo button is pressed.
  func buttonPhotoPressed() {
    //Present alert controller.
    self.presentViewController(self.alertController, animated: true, completion: nil)
  } //end func
  
  //MARK: ImageSelectedProtocol
  
  //Function: Handle event when image is selected from Gallery.
  func controllerDidSelectImage(selectedImage: UIImage) {
    //Reset main image view.
    self.imageViewMain.image = selectedImage

    //Generate a thumbnail of the selected image.
    //Context: set size and initialize.
    UIGraphicsBeginImageContext(CGSize(width: thumbnailWid, height: thumbnailHgt))
    //Draw image in context.
    selectedImage.drawInRect(CGRect(x: 0, y: 0, width: thumbnailWid, height: thumbnailHgt))
    //Get image from context.
    thumbnailToFilter = UIGraphicsGetImageFromCurrentImageContext()
    
    //Reload collection view.
    filteredImageCollectionView.reloadData()
  } //end func
  
  //MARK: Alert Controller Gallery Action
  
  //Function: Presents Gallery View Controller.
  func alertActionGalleryPressed() {
    let galleryViewController = GalleryViewController()
    galleryViewController.delegate = self
    self.navigationController?.pushViewController(galleryViewController, animated: true)
  } //end func
  
  //MARK: UICollectionViewDataSource
  
  //Function: Set collection view cell count.
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return filteredImageThumbnails.count
  } //end func
  
  //Function: Set collection view cell content.
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    //Cell:
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CELL_IMAGE", forIndexPath: indexPath) as GalleryCollectionViewCell
    //Current thumbnail: set original and apply filter to image.
    let currentThumbnail = filteredImageThumbnails[indexPath.row]
    if thumbnailToFilter != nil {
      currentThumbnail.originalImage = thumbnailToFilter
      currentThumbnail.applyFilter({ () -> () in
        //Set cell image.
        if currentThumbnail.filteredImage != nil {
          cell.imageView.image = currentThumbnail.filteredImage
        } //end if
      }) //end closure
    } //end if
    //Return cell.
    return cell
  } //end func
}