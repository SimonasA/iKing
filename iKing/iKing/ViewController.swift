//
//  ViewController.swift
//  iKing
//
//  Created by Simonas Armonas on 2014-10-24.
//  Copyright (c) 2014 SA. All rights reserved.
//

import UIKit
import QuartzCore

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var previewView: UIImageView?
    
    let imagePicker = UIImagePickerController()
    
    @IBAction func addImage() {
        imagePicker.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        imagePicker.delegate = self
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingMediaWithInfo info:NSDictionary!) {
        let tempImage = info[UIImagePickerControllerOriginalImage] as UIImage
        previewView?.image = kingWithAddedCrown(tempImage)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func kingWithAddedCrown(kingsPicture: UIImage) -> UIImage {
        let crownImage: UIImage = UIImage(named: "crown")!
        let crownImageView: UIImageView = UIImageView(image: crownImage)
        let mouthPosition: CGPoint = mouthPositionForImage(kingsPicture)
        let x: CGFloat = mouthPosition.x - (crownImageView.frame.size.width / 2.0)
        let y: CGFloat = mouthPosition.y - crownImageView.frame.size.height
        let faceTop = CGPointMake(x, y)
        crownImageView.frame.origin = faceTop
        
        if let view = previewView {
            view.addSubview(crownImageView)
        }

        return kingsPicture
    }
    
    func mouthPositionForImage(image: UIImage) -> CGPoint {
        var foundedMouthPoint = CGPointZero
        
        if let view = previewView {
            foundedMouthPoint = CGPointMake(view.frame.size.width / 2.0, view.frame.size.height / 2.0)
        }

        let orientation: Int = image.imageOrientation.rawValue
        let options = [CIDetectorAccuracy: CIDetectorAccuracyLow, CIDetectorImageOrientation: orientation]
        let kingsCIImage: CIImage = CIImage(CGImage: image.CGImage, options: options)
        let detector: CIDetector = CIDetector(ofType:CIDetectorTypeFace, context:nil, options:options);
        let results: NSArray = detector.featuresInImage(kingsCIImage, options: NSDictionary());
        for r in results {
            let face:CIFaceFeature = r as CIFaceFeature;
            if face.hasMouthPosition {
                foundedMouthPoint = face.mouthPosition
            }
        }
        return foundedMouthPoint
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

