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
        
        let firstButton = UIBarButtonItem(image: UIImage(named: "Pin"), style: UIBarButtonItemStyle.plain,target: self, action: #selector(TableViewController.pinButtonTouchUp))
        let secondButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(TableViewController.refreshButtonTouchUp))
        self.navigationItem.rightBarButtonItems = [secondButton,firstButton]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        studentInformation = appDelegate.studentInformation
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentInformation.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentsCell" , for: indexPath)
        let student = studentInformation[indexPath.row]
        
        cell.textLabel?.text = (student.firstName! as! String) + " " + (student.lastName! as! String)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let app = UIApplication.shared
        app.openURL(URL(string: studentInformation[indexPath.row].mediaURL as! String)!)
        
    }
    
    @IBAction func logoutButton(_ sender: AnyObject) {
        OTMClient.sharedInstance().logoutUser() { (result, errorString) in
            if result {
                self.dismiss(animated: true, completion: nil)
            } else {
                let alertController = UIAlertController(title: nil, message: "Network Error.", preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in}
                alertController.addAction(OKAction)
                
                self.present(alertController, animated: true) {}
            }
        }
        
    }
    
    func refreshButtonTouchUp (){
        
        let urlstring = OTMClient.Constants.ParseURLSecure
        OTMClient.sharedInstance().getStudentLocations(urlstring) { (success, locations , errorString) in
            if success {
                let object = UIApplication.shared.delegate
                let appDelegate = object as! AppDelegate
                appDelegate.studentInformation.removeAll(keepingCapacity: false)
                self.studentInformation.removeAll(keepingCapacity: false)
                if let locations = locations {
                    for location in locations {
                        let student = StudentInformation (dictionary: location)
                        appDelegate.studentInformation.append(student)
                    }
                    self.studentInformation = appDelegate.studentInformation
                    self.tableView.reloadData()
                }
            } else {
                let alertController = UIAlertController(title: nil, message: "Faild to get data.", preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in}
                alertController.addAction(OKAction)
                
                self.present(alertController, animated: true) {}
            }
        }
    
    }
    func pinButtonTouchUp (){
        let controller = self.storyboard!.instantiateViewController(withIdentifier: "InformationPostingView")
        self.present(controller, animated: true, completion: nil)
    }
    
}
