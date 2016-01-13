//
//  EditViewController.swift
//  Lists
//
//  Created by Adrià Carro on 12/01/16.
//  Copyright © 2016 DigitalYou. All rights reserved.
//

import UIKit
import CloudKit

class EditViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // IBOutlets
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var addressTextField: UITextField!
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var selectImageButton: UIButton!
    
    var record: CKRecord?
    var photoURL: NSURL?
    
    let defaultContainer = CKContainer.defaultContainer()
    let privateDB = CKContainer.defaultContainer().privateCloudDatabase
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupUI() {
        guard let record = record else { return }
        self.title = record.objectForKey("Name") as? String
        
        nameTextField.text = record.objectForKey("Name") as? String ?? ""
        addressTextField.text = record.objectForKey("Address") as? String ?? ""
        
        if let asset = record.objectForKey("Photo") as? CKAsset {
            if let data = NSData(contentsOfURL: asset.fileURL) {
                imageView.image =  UIImage(data: data)
            }
        }
    }
    
    
    // MARK: - Select image handler

    @IBAction func selectImage(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imagePicker.allowsEditing = false
        
        imagePicker.modalPresentationStyle = .Popover
        if let popoverController = imagePicker.popoverPresentationController {
            popoverController.sourceView = selectImageButton
            popoverController.sourceRect = selectImageButton.bounds
        }
        presentViewController(imagePicker, animated: true, completion: nil)
        
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = pickedImage
            photoURL = saveImageToFile(pickedImage)
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func saveImageToFile(image: UIImage) -> NSURL
    {
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        
        let docsDir: AnyObject = dirPaths[0]
        
        let filePath = docsDir.stringByAppendingPathComponent("currentImage.png")
        
        UIImageJPEGRepresentation(image, 0.5)!.writeToFile(filePath, atomically: true)
        
        return NSURL.fileURLWithPath(filePath)
    }
    
    
    // MARK: - Update/Save record
    
    @IBAction func save(sender: AnyObject) {
        
        let activitiyViewController = ActivityViewController(message: "Saving...")
        self.presentViewController(activitiyViewController, animated: true, completion: nil)
        
        let auxRecord: CKRecord!
        
        if let record = record {
            auxRecord = record
        }
        else {
            auxRecord = CKRecord(recordType: "Shop")
        }
        
        auxRecord.setObject(self.nameTextField.text, forKey: "Name")
        auxRecord.setObject(self.addressTextField.text, forKey: "Address")
        
        if let photoURL = photoURL {
            let asset = CKAsset(fileURL: photoURL)
            auxRecord.setObject(asset, forKey: "Photo")
        }
        
        privateDB.saveRecord(auxRecord) { savedRecord, error in
            if error != nil {
                dispatch_async(dispatch_get_main_queue()) {
                    self.cloudKitError(error!)
                    print("error loading: \(error)")
                }
            }
            else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.navigationController?.popViewControllerAnimated(true)
                }
            }
            activitiyViewController.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    
    // MARK: - Delete record
    
    @IBAction func deleteShop(sender: AnyObject) {
        guard let record = record else { return }
        
        privateDB.deleteRecordWithID(record.recordID, completionHandler: ({returnRecord, error in
            if let err = error {
                dispatch_async(dispatch_get_main_queue()) {
                    self.cloudKitError(err)
                    
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.navigationController?.popViewControllerAnimated(true)
                }
            }
        }))
    }
    
    
    // MARK: - Error handler
    
    private func cloudKitError(error: NSError) {
        let alertController = UIAlertController(title: "Error saving shop", message: error.localizedDescription, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
}
