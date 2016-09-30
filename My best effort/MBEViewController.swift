//
//  ViewController.swift
//  My best effort
//
//  Created by iMac on 02.09.16.
//  Copyright © 2016 vasayCo. All rights reserved.
//

import UIKit

import Alamofire
import SwiftyJSON
import KCFloatingActionButton

public extension UIView {
    
    /**
     Fade in a view with a duration
     
     - parameter duration: custom animation duration
     */
    func fadeIn(duration duration: NSTimeInterval = 0.5) {
        UIView.animateWithDuration(duration, animations: {
            self.alpha = 1.0
        })
    }
    
    /**
     Fade out a view with a duration
     
     - parameter duration: custom animation duration
     */
    func fadeOut(duration duration: NSTimeInterval = 0.5) {
        UIView.animateWithDuration(duration, animations: {
            self.alpha = 0.0
        })
    }
    
}




class MBEViewController: UIViewController, reLoadDataDataSource, UITableViewDelegate,  UITableViewDataSource  {
    @IBOutlet var tableView: UITableView!
    //let fab = KCFloatingActionButton()
    let fabRight = KCFloatingActionButton()
    //label
    @IBOutlet var labelDist: UILabel!
    
    var token:String?
    var result = [NoteEffort]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //hide baritem
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        fabRight.buttonImage = UIImage(named: "animal3")
        
        
        /*
         case Pop
         case Fade
         case SlideLeft
         case SlideUp
         case None
         */
        
        result = MBEDBInspector.sharedInstance.getEfforts(typeDist.m400)
        labelDist.text =  MBEDBInspector.sharedInstance.getMetrStr(0)
        
        self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
        
        
        
        
        
        /*
         if let json = MBEDBInspector.sharedInstance.requestWeb("https://www.strava.com/api/v3/activities/694601290/streams/time", header: headers, params: nil){
         for (index,subJson):(String, JSON) in json {
         print(index,"-----")
         print(subJson["data"])
         // print(subJson["id"]," ", subJson["distance"]," ",subJson["elapsed_time"]," ",subJson["start_date"].string ," ", subJson["name"].string )
         
         }
         
         }
         
         
         */
        
        
        
        fabRight.addItem(MBEDBInspector.sharedInstance.getMetrStr(1), icon: UIImage(named: "animal1")!, handler: { item in
            self.result = MBEDBInspector.sharedInstance.getEfforts(MBEDBInspector.sharedInstance.getMetr(1))
            self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
            self.labelDist.text =  MBEDBInspector.sharedInstance.getMetrStr(1)
            self.fabRight.close()
        })
        fabRight.addItem(MBEDBInspector.sharedInstance.getMetrStr(2), icon: UIImage(named: "animal1")!, handler: { item in
            self.result = MBEDBInspector.sharedInstance.getEfforts(MBEDBInspector.sharedInstance.getMetr(2))
            self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
            self.labelDist.text =  MBEDBInspector.sharedInstance.getMetrStr(2)
            self.fabRight.close()
        })
        fabRight.addItem(MBEDBInspector.sharedInstance.getMetrStr(3), icon: UIImage(named: "animal1")!, handler: { item in
            self.result = MBEDBInspector.sharedInstance.getEfforts(MBEDBInspector.sharedInstance.getMetr(3))
            self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
            self.labelDist.text =  MBEDBInspector.sharedInstance.getMetrStr(3)
            self.fabRight.close()
        })
        fabRight.addItem(MBEDBInspector.sharedInstance.getMetrStr(4), icon: UIImage(named: "animal1")!, handler: { item in
            self.result = MBEDBInspector.sharedInstance.getEfforts(MBEDBInspector.sharedInstance.getMetr(4))
            self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
            self.labelDist.text =  MBEDBInspector.sharedInstance.getMetrStr(4)
            self.fabRight.close()
        })
        fabRight.addItem(MBEDBInspector.sharedInstance.getMetrStr(5), icon: UIImage(named: "animal1")!, handler: { item in
            self.result = MBEDBInspector.sharedInstance.getEfforts(MBEDBInspector.sharedInstance.getMetr(5))
            self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
            self.labelDist.text =  MBEDBInspector.sharedInstance.getMetrStr(5)
            self.fabRight.close()
        })
        fabRight.addItem(MBEDBInspector.sharedInstance.getMetrStr(6), icon: UIImage(named: "animal1")!, handler: { item in
            self.result = MBEDBInspector.sharedInstance.getEfforts(MBEDBInspector.sharedInstance.getMetr(6))
            self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
             self.labelDist.text =  MBEDBInspector.sharedInstance.getMetrStr(6)
            self.fabRight.close()
        })
        
        fabRight.addItem(MBEDBInspector.sharedInstance.getMetrStr(8), icon: UIImage(named: "animal1")!, handler: { item in
            self.result = MBEDBInspector.sharedInstance.getEfforts(MBEDBInspector.sharedInstance.getMetr(8))
            self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
            self.labelDist.text =  MBEDBInspector.sharedInstance.getMetrStr(8)
            self.fabRight.close()
        })
        fabRight.addItem(MBEDBInspector.sharedInstance.getMetrStr(10), icon: UIImage(named: "animal1")!, handler: { item in
            self.result = MBEDBInspector.sharedInstance.getEfforts(MBEDBInspector.sharedInstance.getMetr(10))
            self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
            self.labelDist.text =  MBEDBInspector.sharedInstance.getMetrStr(10)
            self.fabRight.close()
        })
        fabRight.addItem(MBEDBInspector.sharedInstance.getMetrStr(12), icon: UIImage(named: "animal1")!, handler: { item in
            self.result = MBEDBInspector.sharedInstance.getEfforts(MBEDBInspector.sharedInstance.getMetr(12))
            self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
            self.labelDist.text =  MBEDBInspector.sharedInstance.getMetrStr(12)
            self.fabRight.close()
        })
        
        self.view.addSubview(fabRight)
        
        
        
        
        
    }
    
    
    func reloadData(step:Int, json:JSON?){
        switch step {
        case 0: //step 0 get activities
            print("step 0")
            MBEDBInspector.sharedInstance.reloadDataDelegate = self
            let token = NSUserDefaults.standardUserDefaults().objectForKey("token")
            let headers = ["Authorization ": "Bearer \(token as! String)"]
            let params = ["page":1,"per_page": 200]
            MBEDBInspector.sharedInstance.requestWeb("https://www.strava.com/api/v3/athlete/activities", header: headers, params: params)
        case 1: //step 1 save activities to core data
            print("step 1")
            MBEDBInspector.sharedInstance.deleteActivities()
            MBEDBInspector.sharedInstance.saveActivitiesToDB(json!)
        case 2: //step 2 get and math stream
            print("step 2")
            MBEDBInspector.sharedInstance.getSreamFromActivities()
        case 3: //step 2 get and math stream
            print("step 3")

        case 4: //step 2 get and math stream
            print("step 4")
            self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
        default:
            print("dafault")
        }
        
    }
    //MARK: - table UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return result.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("MBETableViewCell",forIndexPath: indexPath) as! MBETableViewCell
        cell.labelPlace.text = String(indexPath.row + 1)
        cell.labelDate.text = result[indexPath.row].date
        cell.labelTime.text = result[indexPath.row].time
        cell.labelName.text = result[indexPath.row].name
        
        return cell
    }
    
    func  tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        
    }
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath){
        
    }
    //Rrefresh data
    /*
     func refresh(step:Int){
     switch step {
     case 0:
     code
     default:
     <#code#>
     }
     
     
     }
     
     */
    
    
    @IBAction func actionRefresh(sender: AnyObject) {
        reloadData(0, json: nil)
    }
    
    @IBAction func actionLogOut(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().removeObjectForKey("token")
        NSUserDefaults.standardUserDefaults().synchronize()
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
}

