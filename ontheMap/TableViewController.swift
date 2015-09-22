//
//  TableViewController.swift
//  ontheMap
//
//  Created by Mohammad Awwad on 8/30/15.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import Foundation
import UIKit

class TableViewController :  UITableViewController {
    
    var studentInformation :[StudentInformation]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let firstButton = UIBarButtonItem(image: UIImage(named: "Pin"), style: UIBarButtonItemStyle.Plain,target: self, action: "pinButtonTouchUp")
        let secondButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "refreshButtonTouchUp")
        self.navigationItem.rightBarButtonItems = [secondButton,firstButton]
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        studentInformation = appDelegate.studentInformation
        tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentInformation.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("StudentsCell" , forIndexPath: indexPath)
        let student = studentInformation[indexPath.row]
        
        cell.textLabel?.text = (student.firstName! as! String) + " " + (student.lastName! as! String)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let app = UIApplication.sharedApplication()
        app.openURL(NSURL(string: studentInformation[indexPath.row].mediaURL as! String)!)
        
    }
    
    @IBAction func logoutButton(sender: AnyObject) {
        OTMClient.sharedInstance().logoutUser() { (result, errorString) in
            if result {
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                let alertController = UIAlertController(title: nil, message: "Network Error.", preferredStyle: .Alert)
                let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in}
                alertController.addAction(OKAction)
                
                self.presentViewController(alertController, animated: true) {}
            }
        }
        
    }
    
    func refreshButtonTouchUp (){
        
        let urlstring = OTMClient.Constants.ParseURLSecure
        OTMClient.sharedInstance().getStudentLocations(urlstring) { (success, locations , errorString) in
            if success {
                let object = UIApplication.sharedApplication().delegate
                let appDelegate = object as! AppDelegate
                appDelegate.studentInformation.removeAll(keepCapacity: false)
                self.studentInformation.removeAll(keepCapacity: false)
                if let locations = locations {
                    for location in locations {
                        let student = StudentInformation (dictionary: location)
                        appDelegate.studentInformation.append(student)
                    }
                    self.studentInformation = appDelegate.studentInformation
                    self.tableView.reloadData()
                }
            } else {
                let alertController = UIAlertController(title: nil, message: "Faild to get data.", preferredStyle: .Alert)
                let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in}
                alertController.addAction(OKAction)
                
                self.presentViewController(alertController, animated: true) {}
            }
        }
    
    }
    func pinButtonTouchUp (){
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("InformationPostingView")
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
}