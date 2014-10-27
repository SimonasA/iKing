//
//  ViewController.swift
//  iKing
//
//  Created by Simonas Armonas on 2014-10-24.
//  Copyright (c) 2014 SA. All rights reserved.
//

import UIKit
import QuartzCore

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate {
    
    @IBOutlet weak var previewView: UIImageView!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    let imagePicker = UIImagePickerController()
    
// MARK: Actions
    
    @IBAction func captureButtonTapped() {
        openActionSheet()
    }
    
    @IBAction func shareButtonTapped() {
        shareImage()
    }
    
// MARK: View loading methods
    
    override func viewDidLoad() {
        let colorValue: CGFloat = 102.0/255.0
        captureButton.layer.cornerRadius = 15.0
        captureButton.layer.borderWidth = 1.0
        captureButton.layer.borderColor = UIColor(red: colorValue, green: colorValue, blue: colorValue, alpha: 1.0).CGColor
        shareButton.layer.cornerRadius = 15.0
        shareButton.layer.borderWidth = 1.0
        shareButton.layer.borderColor = UIColor(red: colorValue, green: colorValue, blue: colorValue, alpha: 1.0).CGColor
        super.viewDidLoad()
    }
    
// MARK: Image processing
    
    func faceBoundsForImage(image: UIImage) -> CGRect {
        var faceBounds = CGRectZero
        let orientationForCIImage = exifOrientation(image.imageOrientation)
        let options: NSDictionary = [CIDetectorImageOrientation: orientationForCIImage]
        let kingsCIImage: CIImage = CIImage(CGImage: image.CGImage)
        let detector: CIDetector = CIDetector(ofType:CIDetectorTypeFace, context:nil, options:nil);
        let results: NSArray = detector.featuresInImage(kingsCIImage, options:options);
        
        if results.count > 0 {
            let face:CIFaceFeature = results[0] as CIFaceFeature // There can only be one king!
            faceBounds = face.bounds
        }
        
        return faceBounds
    }
    
    func kingImageWithCrown(kingImage: UIImage, crownFrame: CGRect) -> UIImage {
        let crownImage: UIImage = UIImage(named: "crown")!
        UIGraphicsBeginImageContext(kingImage.size)
        kingImage.drawAtPoint(CGPointMake(0, 0))
        let adjustedCrownFrame = rectForImage(kingImage, faceDetectedRect: crownFrame)
        let y: CGFloat = adjustedCrownFrame.origin.y - (crownFrame.size.height * 0.7) // Just to move crown a bit higher than kings face
        let movedRect: CGRect = CGRectMake(adjustedCrownFrame.origin.x, y, crownFrame.size.width, crownFrame.size.height)
        crownImage.drawInRect(movedRect)
        let result: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return result
    }
    
    func rectForImage(image: UIImage, faceDetectedRect: CGRect) -> CGRect {
        
        var rectForImage = CGRectZero
        let imageWidth = image.size.width
        let imageHeight = image.size.height
        
        switch (image.imageOrientation) {
            case UIImageOrientation.Up:
                rectForImage.origin.x = faceDetectedRect.origin.x
                rectForImage.origin.y = faceDetectedRect.origin.y
            case UIImageOrientation.Down:
                rectForImage.origin.x = imageWidth - faceDetectedRect.origin.x - faceDetectedRect.size.width
                rectForImage.origin.y = faceDetectedRect.origin.y
            case UIImageOrientation.Left:
                rectForImage.origin.x = faceDetectedRect.origin.y
                rectForImage.origin.y = faceDetectedRect.origin.x
            case UIImageOrientation.Right:
                rectForImage.origin.x = faceDetectedRect.origin.y
                rectForImage.origin.y = faceDetectedRect.origin.x
            case UIImageOrientation.UpMirrored:
                rectForImage.origin.x = imageWidth - faceDetectedRect.origin.x
                rectForImage.origin.y = imageHeight - faceDetectedRect.origin.y
            case UIImageOrientation.DownMirrored:
                rectForImage.origin.x = faceDetectedRect.origin.x
                rectForImage.origin.y = faceDetectedRect.origin.y
            case UIImageOrientation.LeftMirrored:
                rectForImage.origin.x = imageWidth - faceDetectedRect.origin.y
                rectForImage.origin.y = faceDetectedRect.origin.x
            case UIImageOrientation.RightMirrored:
                rectForImage.origin.x = faceDetectedRect.origin.y
                rectForImage.origin.y = imageHeight - faceDetectedRect.origin.x
            default:
                break
        }
        
        return rectForImage
    }

    func exifOrientation(uiImageOrientation: UIImageOrientation) -> Int {
        
        var imageOrientationForCIImage: Int = 1
        
        switch (uiImageOrientation) {
            case UIImageOrientation.Up:
                imageOrientationForCIImage = 1
            case UIImageOrientation.Down:
                imageOrientationForCIImage = 3
            case UIImageOrientation.Left:
                imageOrientationForCIImage = 8
            case UIImageOrientation.Right:
                imageOrientationForCIImage = 6
            case UIImageOrientation.UpMirrored:
                imageOrientationForCIImage = 2
            case UIImageOrientation.DownMirrored:
                imageOrientationForCIImage = 4
            case UIImageOrientation.LeftMirrored:
                imageOrientationForCIImage = 5
            case UIImageOrientation.RightMirrored:
                imageOrientationForCIImage = 7
            default:
                break
        }
        
        return imageOrientationForCIImage
    }

// MARK: UIImagePickerControllerDelegate functions

    func imagePickerController(picker: UIImagePickerController!, didFinishPickingMediaWithInfo info:NSDictionary!) {
        let kingImage = info[UIImagePickerControllerOriginalImage] as UIImage
        let crownBounds: CGRect = faceBoundsForImage(kingImage)
        previewView?.image = kingImageWithCrown(kingImage, crownFrame: crownBounds)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
// MARK: Presentation methods
    
    func openActionSheet () {
        let actionSheet: UIActionSheet = UIActionSheet(title: "Choose source", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil)
        actionSheet.addButtonWithTitle("Camera")
        actionSheet.addButtonWithTitle("Gallery")
        actionSheet.showFromRect(captureButton.frame, inView: previewView, animated: true)
    }
    
    func openPickerWithCamera(shouldOpenCamera: Bool) {
        imagePicker.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
        imagePicker.delegate = self
        
        if shouldOpenCamera {
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
            imagePicker.cameraDevice = UIImagePickerControllerCameraDevice.Front
        } else {
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        }
        
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        let ButtonIndexCamera = 1
        let ButtonIndexGallery = 2
        
        switch buttonIndex {
            case ButtonIndexCamera:
                openPickerWithCamera(true)
            case ButtonIndexGallery:
                openPickerWithCamera(false)
            default:
                break
        }
    }
    
    func shareImage () {
        if let image = self.previewView.image {
            let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)

            if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                activityController.popoverPresentationController?.sourceView = shareButton
            }

            presentViewController(activityController, animated: true, completion: nil)
        }
    }
    
}