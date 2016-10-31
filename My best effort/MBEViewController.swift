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
import GTAlertBar

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
    
    var countAllActivities = (0,0)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //view gradient
        gradView()
        //hide baritem
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        fabRight.buttonImage = UIImage(named: "map2")

        result = MBEDBInspector.sharedInstance.getEfforts(typeDist.km1)
        labelDist.text =  MBEDBInspector.sharedInstance.getMetrStr(2)
        
        self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)

        
   
        addFab(typeDist: 2, nameImage: "point3")
        addFab(typeDist: 3, nameImage: "point3")
        addFab(typeDist: 4, nameImage: "point3")
        addFab(typeDist: 5, nameImage: "point3")
        addFab(typeDist: 6, nameImage: "point3")
        addFab(typeDist: 8, nameImage: "point3")
        addFab(typeDist: 10, nameImage: "point3")
        addFab(typeDist: 12, nameImage: "point3")
        
        
        self.view.addSubview(fabRight)
        
        
        
        
        
    }
    
    func gradView(){
        let color1 = UIColor(red: 240/255, green: 120/255, blue: 35/255, alpha: 1).CGColor
        let color2 = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1).CGColor
        let gradLayer = CAGradientLayer()
        gradLayer.frame = self.view.bounds
        gradLayer.startPoint = CGPoint(x: 0, y: 0)
        gradLayer.endPoint = CGPoint(x: 1, y: 1)
        gradLayer.colors = [color1,color2]
        
        self.view.layer.insertSublayer(gradLayer, atIndex: 0)
        
     
        
    }
    
    func addFab(typeDist typeDist:Int,nameImage:String){
        
        fabRight.addItem(MBEDBInspector.sharedInstance.getMetrStr(typeDist), icon: UIImage(named: nameImage)!, handler: { item in
            self.result = MBEDBInspector.sharedInstance.getEfforts(MBEDBInspector.sharedInstance.getMetr(typeDist))
            self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
            self.labelDist.text =  MBEDBInspector.sharedInstance.getMetrStr(typeDist)
            self.fabRight.close()
        })
    }
    
    
    func reloadData(step:(Int,Int), json:JSON?){
        if step.0 == 0 &&  step.1 == 0{
         //step 0 get activities

             countAllActivities = (0,0)
            MBEDBInspector.sharedInstance.reloadDataDelegate = self
            MBEDBInspector.sharedInstance.requestWeb("https://www.strava.com/api/v3/athlete/activities",page: 1)
           
        } else{
            if  step.0 == 0 &&  step.1 != 0 {
                print("Loaded \(step.1) activities")
                countAllActivities.1 = step.1
            } else{
                countAllActivities.0 += 1
              print("Match \(countAllActivities.0) / \(countAllActivities)")
              viewAlert("Match Activities", body: "Match \(countAllActivities.0) / \(countAllActivities)")
            }
        }
       
        
        
    }
    //MARK: - table UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return result.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("MBETableViewCell",forIndexPath: indexPath) as! MBETableViewCell
        cell.labelPlace.text = String(indexPath.row + 1)
        cell.labelDate.text =  getGmtTime(result[indexPath.row].date)
        cell.labelTime.text = result[indexPath.row].time
        cell.labelName.text = result[indexPath.row].name
        switch indexPath.row {
        case 0:
            cell.imagePlace.image = UIImage(named: "1place_")
        case 1:
            cell.imagePlace.image = UIImage(named: "2place_")
        case 2:
            cell.imagePlace.image = UIImage(named: "3place_")
        default:
             cell.imagePlace.image = nil
        }
        
       
        
        return cell
    }
    

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
           UIApplication.sharedApplication().openURL(NSURL(string: result[indexPath.row].url)!)
        
        
    }
    //view alert
    func viewAlert(title:String,body:String){
        let options = GTAlertBarOptions()
        options.image = UIImage(named: "plan")
        options.animation.fade = true
        GTAlertBar.barAttachedToView(self,
                                     title: title,
                                     body:body,
                                     options: options)
        
    }
    
    
    //set normal format
    func getGmtTime(time:String) -> String{
        let formater = NSDateFormatter()
        formater.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
         let dateAction = formater.dateFromString(time)
        
        let formaterCell = NSDateFormatter()
         formaterCell.dateFormat = "yyyy'-'MM'-'dd' 'HH':'mm':'ss"
        
        return formaterCell.stringFromDate(dateAction!)
       
    }
    
    @IBAction func actionRefresh(sender: AnyObject) {
        print("Load Activities")
       // viewAlert("Load Activities", body: "DownLoad all list activities")
        reloadData((0,0), json: nil)
    }
    
    @IBAction func actionLogOut(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().removeObjectForKey("token")
        NSUserDefaults.standardUserDefaults().synchronize()
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("MBEStartViewController") as! MBEStartViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

