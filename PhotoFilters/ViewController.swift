//
//  ViewController.swift
//  PhotoFilters
//
//  Created by Alexandra Norcross on 1/12/15.
//  Copyright (c) 2015 Alexandra Norcross. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  //Alert controller:
  let alertController = UIAlertController(title: "My Photos", message: "Where are my photos?", preferredStyle: UIAlertControllerStyle.Alert)
  
  //Function: Set View Controller - objects, layout, and actions.
  override func loadView() {
    //Subview dictionary: for Visual Format Language
    var dictionarySubview = [String : AnyObject]()
    
    //Root View:
    let rootView = UIView(frame: UIScreen.mainScreen().bounds)
    rootView.backgroundColor = UIColor.whiteColor()
    
    //MARK: ViewController views & subviews
    
    //Layout: add subviews and set constraints
      //Image:
      let imageMain = UIImageView()
      rootView.addSubview(imageMain)
      imageMain.setTranslatesAutoresizingMaskIntoConstraints(false)
      dictionarySubview["imageMain"] = imageMain
      imageMain.image = UIImage(named: "vespa.jpeg")
      //Constraints: stretching horizontally & vertically across screen
      let imageMainConstraintWid = NSLayoutConstraint.constraintsWithVisualFormat("H:|-5-[imageMain]-5-|", options: nil, metrics: nil, views: dictionarySubview)
      rootView.addConstraints(imageMainConstraintWid)
      let imageMainConstraintHgt = NSLayoutConstraint.constraintsWithVisualFormat("V:|-65-[imageMain]-5-|", options: nil, metrics: nil, views: dictionarySubview)
      rootView.addConstraints(imageMainConstraintHgt)
      
      //Photo button:
      let buttonPhoto = UIButton()
      rootView.addSubview(buttonPhoto)
      buttonPhoto.setTranslatesAutoresizingMaskIntoConstraints(false)
      dictionarySubview["buttonPhoto"] = buttonPhoto
      //Appearance:
      buttonPhoto.setTitle("Photo", forState: .Normal)
      buttonPhoto.setTitleColor(UIColor.whiteColor(), forState: .Normal)
      buttonPhoto.titleLabel?.font = UIFont(name: "Avenir-Black", size: 17)
      //Constraints: bottom center of screen
      let buttonPhotoConstraintBottom = NSLayoutConstraint.constraintsWithVisualFormat("V:[buttonPhoto]-10-|", options: nil, metrics: nil, views: dictionarySubview)
      rootView.addConstraints(buttonPhotoConstraintBottom)
      let buttonPhotoConstraintHoriz = NSLayoutConstraint(item: buttonPhoto, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: rootView, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 1.0)
      rootView.addConstraint(buttonPhotoConstraintHoriz)
      
      //Set root view.
      self.view = rootView
    
    //Photo button: action
    buttonPhoto.addTarget(self, action: "buttonPhotoPressed", forControlEvents: UIControlEvents.TouchUpInside)
  } //end func
  
  //Function: Setup View Controller after loading the view.
  override func viewDidLoad() {
    //Super:
    super.viewDidLoad()
    
    //MARK: Alert Controller options/actions
    
    //Handle alert controller options/actions; and add option/action to alert controller.
      //Gallery:
      let actionAlertOptGallery = UIAlertAction(title: "Gallery", style: .Default) { (actionGallery) -> Void in
        //Present Gallery View Controller.
        let galleryViewController = GalleryViewController()
        self.navigationController?.pushViewController(galleryViewController, animated: true)
      } //end closure
      alertController.addAction(actionAlertOptGallery)
  } //end func
  
  //Function: Handle event when Photo button is pressed.
  func buttonPhotoPressed() {
    //Present alert controller.
    self.presentViewController(self.alertController, animated: true, completion: nil)
  } //end func
}

