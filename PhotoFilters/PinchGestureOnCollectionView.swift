//
//  PinchGestureOnCollectionView.swift
//  PhotoFilters
//
//  Created by Alexandra Norcross on 1/15/15.
//  Copyright (c) 2015 Alexandra Norcross. All rights reserved.
//

import UIKit

class PinchGestureOnCollectionView: NSObject {
  //MARK: Properties
  
  var gesturePinch: UIGestureRecognizer!
  var collectionView: UICollectionView!
  
  //MARK: Initialize
  
  //Initialize: Set class properties.
  init(collectionView: UICollectionView) {
    //Set class properties.
    super.init()
    self.collectionView = collectionView
    self.gesturePinch = UIPinchGestureRecognizer(target: self, action: "collectionViewPinched:")
    
    //Add gesture to collection view.
    self.collectionView.addGestureRecognizer(gesturePinch)
  } //end init
    
  //MARK: Selectors
  
  //Function: Handle pinch event - resize collection view.
  func collectionViewPinched(sender: UIPinchGestureRecognizer) {
    if sender.state == .Changed {
      collectionView.performBatchUpdates({ () -> Void in
        if sender.velocity != 0 {
          let currentFlowLayout = self.collectionView.collectionViewLayout as UICollectionViewFlowLayout
          let currentSize = currentFlowLayout.itemSize
          var newSize: CGSize!
          if sender.velocity > 0 {
            newSize = CGSize(width: currentSize.width * 1.025, height: currentSize.height * 1.025)
          } else if sender.velocity < 0 {
            newSize = CGSize(width: currentSize.width * 0.95, height: currentSize.height * 0.95)
          } //end if
          currentFlowLayout.itemSize = newSize
        } //end if
      }, completion: { (finished) -> Void in

      }) //end closure
    } //end if
  } //end func
}