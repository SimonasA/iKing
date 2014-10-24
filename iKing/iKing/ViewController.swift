//
//  ViewController.swift
//  iKing
//
//  Created by Simonas Armonas on 2014-10-24.
//  Copyright (c) 2014 SA. All rights reserved.
//

import UIKit
import CoreImage
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
        previewView?.image = tempImage
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

