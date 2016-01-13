//
//  ViewController.swift
//  Lists
//
//  Created by Adrià Carro on 12/01/16.
//  Copyright © 2016 DigitalYou. All rights reserved.
//

import UIKit
import CloudKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet var tableView: UITableView!
    
    var shops = [CKRecord]()
    
    let defaultContainer = CKContainer.defaultContainer()
    let privateDB = CKContainer.defaultContainer().privateCloudDatabase

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // save some shop
        //saveShops()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Fetch shops
        fetchShops()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    private func fetchShops() {
        let activitiyViewController = ActivityViewController(message: "Loading...")
        self.presentViewController(activitiyViewController, animated: true, completion: nil)
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Shop", predicate: predicate)
        privateDB.performQuery(query, inZoneWithID: nil) { results, error in
            if error != nil {
                dispatch_async(dispatch_get_main_queue()) {
                    self.cloudKitError(error!)
                    print("error loading: \(error)")
                }
            } else {
                self.shops = results!
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                }
            }
            
            activitiyViewController.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shops.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("shop", forIndexPath: indexPath)
        
        let record = shops[indexPath.row]
        
        cell.textLabel?.text = record.objectForKey("Name") as? String ?? "no name"
        cell.detailTextLabel?.text = record.objectForKey("Address") as? String ?? "no address"
        
        if let asset = record.objectForKey("Photo") as? CKAsset {
            if let data = NSData(contentsOfURL: asset.fileURL) {
                cell.imageView?.image =  UIImage(data: data)
            }
        }
        
        return cell
    }
    
    
    // MARK: Error handler
    
    private func cloudKitError(error: NSError) {
        let alertController = UIAlertController(title: "Error loading shops", message: error.localizedDescription, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    private func saveShops() {
        let greatID = CKRecordID(recordName: "Massimo Dutti")
        let shop = CKRecord(recordType: "Shop", recordID: greatID)
        shop.setObject("Massimo Dutti", forKey: "Name")
        shop.setObject("Plaça Catalunya 1, Barcelona", forKey: "Address")
        
        privateDB.saveRecord(shop) { savedRecord, error in
            if error != nil {
                dispatch_async(dispatch_get_main_queue()) {
                    self.cloudKitError(error!)
                    print("error loading: \(error)")
                }
            }
        }
        
        let greatID2 = CKRecordID(recordName: "Zara")
        let shop2 = CKRecord(recordType: "Shop", recordID: greatID2)
        shop2.setObject("Zara", forKey: "Name")
        shop2.setObject("Passeig de Gràcia 22, Barcelona", forKey: "Address")
        
        privateDB.saveRecord(shop2) { savedRecord, error in
            if error != nil {
                dispatch_async(dispatch_get_main_queue()) {
                    self.cloudKitError(error!)
                    print("error loading: \(error)")
                }
            }
        }
        
        let greatID3 = CKRecordID(recordName: "Uterque")
        let shop3 = CKRecord(recordType: "Shop", recordID: greatID3)
        shop3.setObject("Uterque", forKey: "Name")
        shop3.setObject("Av. Diagonal 330, Barcelona", forKey: "Address")
        
        privateDB.saveRecord(shop3) { savedRecord, error in
            if error != nil {
                dispatch_async(dispatch_get_main_queue()) {
                    self.cloudKitError(error!)
                    print("error loading: \(error)")
                }
            }
        }

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "show" {
            let vc = segue.destinationViewController as! EditViewController
            if let indexPath = self.tableView.indexPathForSelectedRow {
                vc.record = shops[indexPath.row]
            }
            
        }
    }
    
}

