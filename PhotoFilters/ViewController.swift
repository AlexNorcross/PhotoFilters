//
//  ViewController.swift
//  PhotoFilters
//
//  Created by Alexandra Norcross on 1/12/15.
//  Copyright (c) 2015 Alexandra Norcross. All rights reserved.
//

import UIKit
import Social

class ViewController: UIViewController, ImageSelectedProtocol, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  //MARK: Properties
  
  //Main image view:
  let imageViewMain = UIImageView()
  //Main image view constraints: reset to resize image when filtered photos collection view appears.
  var imageViewMainConstraintBottom: NSLayoutConstraint!
  //Main image view margin: bottom
  var imageViewMainMargin = CGFloat(5)
  
  //Navigation bar buttons:
  var buttonNavBarDone: UIBarButtonItem!
  var buttonNavBarShare: UIBarButtonItem!
  
  //Alert controller:
  let alertController = UIAlertController(title: "photos", message: "select an option", preferredStyle: UIAlertControllerStyle.ActionSheet)
  
  //Photo button:
  var buttonPhoto: UIButton!

  //Animation duration:
  let animationDuration = NSTimeInterval(0.4)
  
  //Image width & height:
  let thumbnailWid = 100
  let thumbnailHgt = 100
  //Y-Constraint to hide filtered images collection view
  let filteredImageCollectionViewYConstraintToHide = CGFloat(-150)
  
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
  
  //Filtered image thumbnail selected:
  var filteredImageSelected: UIImage?
  var filteredImageSelectedFilterName: String?
  
  //MARK: ViewController object layout
  
  //Function: Set View Controller - objects, layout, and actions.
  override func loadView() {
    //Subview dictionary: for Visual Format Language
    var dictionarySubview = [String : AnyObject]()
    
    //Root View:
    let rootView = UIView(frame: UIScreen.mainScreen().bounds)
    rootView.backgroundColor = UIColor.whiteColor()
    
    //Layout: add subviews and set constraints
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
      let buttonPhotoConstraintBottom = NSLayoutConstraint.constraintsWithVisualFormat("V:[buttonPhoto]-10-|", options: nil, metrics: nil, views: dictionarySubview)
      rootView.addConstraints(buttonPhotoConstraintBottom)
      let buttonPhotoConstraintHoriz = NSLayoutConstraint(item: buttonPhoto, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: rootView, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 1.0)
      rootView.addConstraint(buttonPhotoConstraintHoriz)
    
      //Image:
      rootView.addSubview(imageViewMain)
      imageViewMain.setTranslatesAutoresizingMaskIntoConstraints(false)
      dictionarySubview["imageViewMain"] = imageViewMain
      imageViewMain.backgroundColor = UIColor.grayColor()
      //Constraints: stretching horizontally & vertically across screen
      let imageViewMainConstraintWid = NSLayoutConstraint.constraintsWithVisualFormat("H:|-5-[imageViewMain]-5-|", options: nil, metrics: nil, views: dictionarySubview)
      rootView.addConstraints(imageViewMainConstraintWid)
      let imageViewMainConstraintHgt = NSLayoutConstraint.constraintsWithVisualFormat("V:|-\(imageViewMainMargin)-[imageViewMain]-5-[buttonPhoto]", options: nil, metrics: nil, views: dictionarySubview)
      rootView.addConstraints(imageViewMainConstraintHgt)
      //Bottom constraint:
      imageViewMainConstraintBottom = imageViewMainConstraintHgt[1] as NSLayoutConstraint
      //Content mode:
      imageViewMain.contentMode = UIViewContentMode.ScaleAspectFill
      imageViewMain.layer.masksToBounds = true

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
      let filteredImagesConstraintBottom = NSLayoutConstraint.constraintsWithVisualFormat("V:[filteredImageCollectionView]-(\(filteredImageCollectionViewYConstraintToHide))-|", options: nil, metrics: nil, views: dictionarySubview)
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
    //Collection view: data source & delegate
    filteredImageCollectionView?.dataSource = self
    filteredImageCollectionView?.delegate = self
    
    //Setup navigatoin bar.
    setupNavigationBar()
    
    //Setup alert controller.
    setupAlertController()
    
    //MARK: Image Filtering setup
    
    //Image filtering: one-time processes
      //Filter names:
      let filterNames = ["CISepiaTone","CIPhotoEffectChrome", "CIPhotoEffectNoir", "CIPhotoEffectInstant"]
      //GPU context: setup
      let optionsGPU = [kCIContextWorkingColorSpace : NSNull()] //for speed
      let contextEAGL = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
      contextGPU = CIContext(EAGLContext: contextEAGL, options: optionsGPU)
      //Add a thumbnail for each filter.
      for filterName in filterNames {
        filteredImageThumbnails.append(FilteredThumbnail(filterName: filterName, contextGPU: contextGPU, queueImage: queueForFilteringImages))
      } //end for
  } //end func
  
  //MARK: NavigationBar setup
  
  //Function: Sets up navigation bar.
  func setupNavigationBar() {
    buttonNavBarDone = UIBarButtonItem(title: "done", style: UIBarButtonItemStyle.Done, target: self, action: "buttonNavBarDonePressed")
    buttonNavBarShare = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "buttonNavBarSharePressed")
  } //end func
  
  //MARK: AlertController setup
  
  //Function: Sets up alert controller.
  func setupAlertController() {
    
    //Gallery: Show Gallery View Controller
    let actionAlertOptGallery = UIAlertAction(title: "gallery", style: .Default) { (action) -> Void in
      self.alertActionGalleryPressed()
    } //end closure
    alertController.addAction(actionAlertOptGallery)
    
    //Camera: Show camera, if available.
    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
      let actionAlertOptCamera = UIAlertAction(title: "camera", style: .Default) { (action) -> Void in
        //Set image picker view controller: set delegate and source to camera.
        let cameraViewController = UIImagePickerController()
        cameraViewController.delegate = self
        cameraViewController.sourceType = UIImagePickerControllerSourceType.Camera
        //Allow editing.
        cameraViewController.allowsEditing = true
        //Present camera view controller.
        self.presentViewController(cameraViewController, animated: true, completion: nil)
      } //end closure
      alertController.addAction(actionAlertOptCamera)
    } //end if
    
    //Photos: Show user's photos.
    let actionAlertOptPhotos = UIAlertAction(title: "my photos", style: .Default) { (action) -> Void in
      //Photos view controller: initialize.
      let photosViewController = PhotosViewController()
      photosViewController.delegate = self
      photosViewController.destinationImageSize = self.imageViewMain.frame.size
      //Present photos view controller.
      self.navigationController?.pushViewController(photosViewController, animated: true)
    } //end closure
    alertController.addAction(actionAlertOptPhotos)

    //Filter: Show collection selected image's filter options; if no photo selected, send user to gallery.
    let actionAlertOptFilter = UIAlertAction(title: "filter my photo", style: .Default) { (action) -> Void in
      self.alertActionFilterPressed()
    } //end closure
    alertController.addAction(actionAlertOptFilter)
    
    //Dismiss:
    let actionAlertOptDismiss = UIAlertAction(title: "dismiss", style: UIAlertActionStyle.Cancel, handler: nil)
    alertController.addAction(actionAlertOptDismiss)
  } //end func
  
  //MARK: Selectors
  
  //Function: Handle event when navigation bar Done button is pressed - set main image to selected filtered image.
  func buttonNavBarDonePressed() {
    //Hide collection view of filtered images.
    self.filteredImageCollectionViewYConstraint.constant = filteredImageCollectionViewYConstraintToHide
    UIView.animateWithDuration(animationDuration, animations: { () -> Void in
      self.filteredImageCollectionView.layoutIfNeeded()
    }) //end closure
    
    //If filtered image thumbnail was selected, set main image to filtered image selected.
    if filteredImageSelected != nil {
      //Filter main image.
      //Image to filter:
      let imageToFilter = CIImage(image: self.imageViewMain.image)
      //Filter: set all inputs to default values; and set image to filter.
      let filter = CIFilter(name: filteredImageSelectedFilterName)
      filter.setDefaults()
      filter.setValue(imageToFilter, forKey: kCIInputImageKey)
      //Filtered image:
      let filteredImage = filter.valueForKey(kCIOutputImageKey) as CIImage
      //Filtered image from GPU:
      let imageFilteredRect = filteredImage.extent()
      let imageFromGPU = contextGPU.createCGImage(filteredImage, fromRect: imageFilteredRect)
      self.imageViewMain.image = UIImage(CGImage: imageFromGPU)
      
      //Set navigation Done button to Share button.
      self.navigationItem.rightBarButtonItem = buttonNavBarShare
    } //end if
    else {
      //Dismiss navigation Done button.
      self.navigationItem.rightBarButtonItem = nil
    } //end if
    
    //Resize main image view size to orginial size.
    imageViewMainConstraintBottom.constant = imageViewMainMargin
    UIView.animateWithDuration(animationDuration, animations: { () -> Void in
      self.imageViewMain.layoutIfNeeded()
    }) //end closure
    
    //Show Photo button.
    buttonPhoto.hidden = false
  } //end func
  
  //Function: Handle event when navigation bar Share button is pressed - allow user to post image to Twitter.
  func buttonNavBarSharePressed() {
    //Show Twitter Social View Controller, if available, with filtered image thumbnail selected; if not, give user alert.
    if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
      let twitterViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
      twitterViewController.addImage(filteredImageSelected)
      self.presentViewController(twitterViewController, animated: true, completion: nil)
    } //end if
    else {
      //Alert controller:
      let alertNoTwitter = UIAlertController(title: "warning", message: "you must be signed into Twitter", preferredStyle: UIAlertControllerStyle.Alert)
      //Dismiss option:
      let optionDismiss = UIAlertAction(title: "dismiss", style: UIAlertActionStyle.Cancel, handler: nil)
      alertNoTwitter.addAction(optionDismiss)
      //Present alert controller.
      self.presentViewController(alertNoTwitter, animated: true, completion: nil)
    } //end else
  } //end func
  
  //Function: Handle event when Photo button is pressed - allow user to select a photo option.
  func buttonPhotoPressed() {
    //Present alert controller.
    self.presentViewController(self.alertController, animated: true, completion: nil)
  } //end func
  
  //MARK: ImageSelectedProtocol
  
  //Function: Handle event when image is selected to be filtered - set main image to selected image.
  func controllerDidSelectImage(selectedImage: UIImage) {
    //Reset main image view.
    self.imageViewMain.image = selectedImage

    //Initialize filtered image thumbnail selected.
    filteredImageSelected = nil
    filteredImageSelectedFilterName = nil

    //Generate a thumbnail of the selected image.
    //Begin context: set size.
    UIGraphicsBeginImageContext(CGSize(width: thumbnailWid, height: thumbnailHgt))
    //Draw image in context.
    selectedImage.drawInRect(CGRect(x: 0, y: 0, width: thumbnailWid, height: thumbnailHgt))
    //Get image from context.
    thumbnailToFilter = UIGraphicsGetImageFromCurrentImageContext()
    //End context.
    UIGraphicsEndImageContext()
    
    //Reload collection view (=> filters images in collection view).
    filteredImageCollectionView.reloadData()
  } //end func
  
  //MARK: AlertController action handlers
  
  //Function: Presents Gallery View Controller.
  func alertActionGalleryPressed() {
    let galleryViewController = GalleryViewController()
    galleryViewController.delegate = self
    self.navigationController?.pushViewController(galleryViewController, animated: true)
  } //end func

  //Function: Presents filter options.
  func alertActionFilterPressed() {
    if self.imageViewMain.image != nil {
      //Hide photo button.
      buttonPhoto.hidden = true
      
      //New Y-constraint for filtered images collection view:
      let newY = 10
      
      //Resize (with animation) main image to make room for filtered images collection view.
      imageViewMainConstraintBottom.constant = CGFloat(newY + thumbnailHgt + 5) //100
      UIView.animateWithDuration(animationDuration, animations: { () -> Void in
        self.imageViewMain.reloadInputViews()
      }) //end closure
      
      //Present (with animation) collection view of filtered images.
      filteredImageCollectionViewYConstraint.constant = CGFloat(newY)
      UIView.animateWithDuration(animationDuration, animations: { () -> Void in
        self.view.layoutIfNeeded()
      }) //end closure
      
      //Show navigation bar Done button.
      self.navigationItem.rightBarButtonItem = self.buttonNavBarDone
    } //end if
    else {
      alertActionGalleryPressed()
    } //end else
  } //end func
  
  //MARK: ImagePickerController
  
  //Function: Handle event when camera image is selected - set main image to selected image.
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
    //Set main image to selected image.
    controllerDidSelectImage(info[UIImagePickerControllerEditedImage] as UIImage)
    //Dismiss camera view controller.
    picker.dismissViewControllerAnimated(true, completion: nil)
  } //end func
  
  //Function: Handle event when camera is cancelled.
  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    //Dismiss camera view controller.
    picker.dismissViewControllerAnimated(true, completion: nil)
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
  
  //MARK: UICollectionViewDelegate

  //Function: Highlight filtered image selected; and set selected image as main image.
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    //Highlight filtered image thumbnail selected:
    let cell = collectionView.cellForItemAtIndexPath(indexPath) as GalleryCollectionViewCell
    cell.imageView.layer.borderWidth = 3.0
    cell.imageView.layer.borderColor = UIColor.blueColor().CGColor
    //Set filtered image thumbnail selected.
    let thumbnail = filteredImageThumbnails[indexPath.row]
    filteredImageSelected = thumbnail.filteredImage
    filteredImageSelectedFilterName = thumbnail.filterName
  } //end func
  
  //Function: Unhighlight filtered image previously selected.
  func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
    //Unhighlight filtered image previously selected.
    let cell = collectionView.cellForItemAtIndexPath(indexPath) as GalleryCollectionViewCell
    cell.imageView.layer.borderWidth = 0.0
    cell.imageView.layer.borderColor = nil
  } //end func
}