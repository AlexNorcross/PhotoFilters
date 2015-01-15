//
//  FilteredThumbnail.swift
//  PhotoFilters
//
//  Created by Alexandra Norcross on 1/13/15.
//  Copyright (c) 2015 Alexandra Norcross. All rights reserved.
//

import UIKit

class FilteredThumbnail {
  var filterName: String
  var contextGPU: CIContext
  var queueImage: NSOperationQueue
  var originalImage: UIImage?
  var filteredImage: UIImage?
  
  //Initialize: Setup filter properties.
  init(filterName: String, contextGPU: CIContext, queueImage: NSOperationQueue) {
    self.filterName = filterName
    self.contextGPU = contextGPU
    self.queueImage = queueImage
  } //end init
  
  //Function: Apply filter to original image.
  func applyFilter(completionHandler: () -> ()) {
    queueImage.addOperationWithBlock { () -> Void in
      //Initialize filtered image.
      self.filteredImage = nil
      //Image to filter:
      let imageToFilter = CIImage(image: self.originalImage)
      //Filter: set all inputs to default values; and set image to filter.
      let filter = CIFilter(name: self.filterName)
      filter.setDefaults()
      filter.setValue(imageToFilter, forKey: kCIInputImageKey)
      //Filtered image:
      let imageFiltered = filter.valueForKey(kCIOutputImageKey) as CIImage
      //Filtered image from GPU:
      let imageFilteredRect = imageFiltered.extent()
      let imageFromGPU = self.contextGPU.createCGImage(imageFiltered, fromRect: imageFilteredRect)
      //Set filtered image property.
      self.filteredImage = UIImage(CGImage: imageFromGPU)
      
      //Return to main thread, calling completion handler.
      NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
        completionHandler()
      }) //end closure
    } //end closure
  } //end func
}