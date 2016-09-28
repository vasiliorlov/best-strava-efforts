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


class MBEViewController: UIViewController, reLoadDataDataSource, UITableViewDelegate,  UITableViewDataSource {
    @IBOutlet var tableView: UITableView!
    
    var token:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
           MBEDBInspector.sharedInstance.getEfforts(typeDist.km10)
        //start reload efforets
       // reloadData(0, json: nil)
        
        
    
        /*
         if let json = MBEDBInspector.sharedInstance.requestWeb("https://www.strava.com/api/v3/activities/694601290/streams/time", header: headers, params: nil){
         for (index,subJson):(String, JSON) in json {
         print(index,"-----")
         print(subJson["data"])
         // print(subJson["id"]," ", subJson["distance"]," ",subJson["elapsed_time"]," ",subJson["start_date"].string ," ", subJson["name"].string )
         
         }
         
         }
         
         
         */
        
        
        // Do any additional setup after loading the view, typically from a nib.
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
        default:
            print("dafault")
        }
        
    }
    //MARK: - table UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("EffortsCell",forIndexPath: indexPath)
      
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

