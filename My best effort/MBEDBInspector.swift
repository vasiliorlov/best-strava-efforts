//
//  MBEDBInspector.swift
//  My best effort
//
//  Created by iMac on 19.09.16.
//  Copyright © 2016 vasayCo. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import SwiftyJSON

protocol reLoadDataDataSource {
    func reloadData(step:Int, json:JSON?)
}
struct typeDist{
    static let m400 = 400
    static let Hmi = 805
    static let km1  = 1000
    static let mi1 = 1609
    static let mi2 = 3219
    static let km5 = 5000
    static let km10 = 10000
    static let km15 = 15000
    static let mi10 = 16093
    static let km20 = 20000
    static let Hmar = 21095
    static let km30 = 30000
    static let Mar = 42195
    static let km50 = 50000
}

class MBEDBInspector: UIViewController {
    
    static let sharedInstance = MBEDBInspector()
    var reloadDataDelegate:reLoadDataDataSource?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Alamofire
    
    
    func requestWeb(url:String, header:[String:String]?, params:[String:AnyObject]?) {
        
        let URLaloma = NSURL(string:url)
        Alamofire.request(.GET, URLaloma! ,parameters: params, headers: header).responseJSON {
            response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let jSon = JSON(value)
                    self.reloadDataDelegate?.reloadData(1, json: jSon)
                    
                }
            case .Failure(let error):
                print(error)
            }
        }
    }
    
    func saveActivitiesToDB(jSon:JSON){
        
        let idUser =  NSUserDefaults.standardUserDefaults().integerForKey("idUser")
        for (_,subJson):(String, JSON) in jSon {
            print(idUser," ",subJson["id"]," ", subJson["distance"].double," ",subJson["elapsed_time"]," ",subJson["start_date"].string ," ",convertTimeStringDate(subJson["start_date"].string!)," ", subJson["name"].string )
            
            let newActivities = NSEntityDescription.insertNewObjectForEntityForName("Activities", inManagedObjectContext: self.managedObjectContext) as! Activities
            newActivities.id = subJson["id"].int
            newActivities.idUser = idUser
            newActivities.date = convertTimeStringDate(subJson["start_date"].string!)
            newActivities.name = subJson["name"].string
            
        }
        
        do{
            try self.managedObjectContext.save()
            self.reloadDataDelegate?.reloadData(2, json: jSon)
        } catch{
            
        }
    }
    
    func convertTimeStringDate(string:String)->NSDate?{
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeZone = NSTimeZone(name: "UTC")
        let date = dateFormatter.dateFromString(string)
        return date
    }
    
    func deleteActivities(){
        let predicate = NSPredicate(format: "idUser = %i", NSUserDefaults.standardUserDefaults().integerForKey("idUser"))
        
        var fetchRequest = NSFetchRequest(entityName: "Activities")
        fetchRequest.predicate = predicate
        do{
            let fetchEntity = try self.managedObjectContext.executeFetchRequest(fetchRequest) as! [Activities]
            for entity in fetchEntity {
                self.managedObjectContext.deleteObject(entity)
            }
        } catch{
            print ("error")
        }
        
      

        
        
        do{
            try self.managedObjectContext.save()
        }
        catch{
            
        }
    }
    
    
    func getSreamFromActivities(){
        
        
        
        let predicate = NSPredicate(format: "idUser = %i", NSUserDefaults.standardUserDefaults().integerForKey("idUser"))
        let fetchRequest = NSFetchRequest(entityName: "Activities")
        let token = NSUserDefaults.standardUserDefaults().objectForKey("token")
        let headers = ["Authorization ": "Bearer \(token as! String)"]
        
        fetchRequest.predicate = predicate
        do{
            let fetchEntity = try self.managedObjectContext.executeFetchRequest(fetchRequest) as! [Activities]
            for entity in fetchEntity {
                print("https://www.strava.com/api/v3/activities/\(entity.id!)/streams/time")
                
                var streamTime = [Int]()
                var streamDist = [Double]()
                var count:Int = 0
                var dist:Double = 0.0
                
                
                //get time
                let  URLaloma = NSURL(string:"https://www.strava.com/api/v3/activities/\(entity.id!)/streams/time")
                Alamofire.request(.GET, URLaloma! , headers: headers).responseJSON {
                    response in
                    switch response.result {
                    case .Success:
                        if let value = response.result.value {
                            let jSon = JSON(value)
                            for (_,subJson):(String, JSON) in jSon {
                                
                                count = subJson["original_size"].int!
                                
                                if subJson["type"] == "time" {
                                    streamTime  =  subJson["data"].arrayObject as! [Int]
                                } else if   subJson["type"] == "distance" {
                                    streamDist  =  subJson["data"].arrayObject as! [Double]
                                    dist = streamDist.last!
                                }
                                
                                
                                //  print(streamTime)
                            }
                            
                           
                            for typDist in 0 ... 13 {
                            var minTime:Int = 0
                            let  distLenth:Double = Double(self.getMetr(typDist))
                            guard distLenth <= dist else {break}
                            for index in 0 ... count-2 {
                                
                                for index2 in index ... count-2 {
                                    

                                    let  distArray =   streamDist[index2 + 1] - streamDist[index]
                                    let  distArrayPre = streamDist[index2] - streamDist[index]
                                    let  timeArray = streamTime[index2+1] - streamTime[index]
                                    let  timeArrayPre = streamTime[index2] - streamTime[index]

                                    if distArrayPre < distLenth && distArray >= distLenth {
                                        if minTime == 0 || timeArray < minTime{
                                            if distArray - distLenth > distLenth - distArrayPre{
                                                minTime = timeArray
                                            } else {
                                                minTime = timeArrayPre
                                            }
                                        }
                                        
                                        break
                                    }
                                    
                                }
                                
                            }
                            
                            
                                
                                let newEfforts = NSEntityDescription.insertNewObjectForEntityForName("Efforts", inManagedObjectContext: self.managedObjectContext) as! Efforts
                                newEfforts.typeEfforts = self.getMetr(typDist)
                                newEfforts.time = minTime
                                newEfforts.activities = entity
                                do{
                                    try self.managedObjectContext.save()
                                } catch{
                                    
                                }
                                
                            print(entity.id!," ",distLenth," ",minTime," ",self.getTimeString(minTime))
                        }
                        
                      }
                    case .Failure(let error):
                        print(error)
                    }
                }
                
                
                
            }
            
    
            
            
            
        } catch{
            print ("error")
        }
        
        
     
        
    }
    
    func getMetr(index:Int)->Int{
        switch index {
        case 0: return typeDist.m400
        case 1: return typeDist.Hmi
        case 2: return typeDist.km1
        case 3: return typeDist.mi1
        case 4: return typeDist.mi2
        case 5: return typeDist.km5
        case 6: return typeDist.km10
        case 7: return typeDist.km15
        case 8: return typeDist.mi10
        case 9: return typeDist.km20
        case 10: return typeDist.Hmar
        case 11: return typeDist.km30
        case 12: return typeDist.Mar
        case 13: return typeDist.km50
        default: return 0
        }
        
    }
    
    func getTimeString(sec:Int)->String{
        var secCount = sec
        let h = Int((secCount - (secCount % 3600)) / 3600)
        secCount = secCount - h * 3600
        let m = Int((secCount - (secCount % 60)) / 60)
        secCount = secCount - m * 60
        
        return String(h) + " h " + String(m) + " m " + String(secCount) + "s"
    }
    
    func getEfforts(typeDist:Int){
        let predicate = NSPredicate(format: "typeEfforts = %i",typeDist)// NSUserDefaults.standardUserDefaults().integerForKey("idUser"))
        let sortDescr = NSSortDescriptor(key: "time", ascending: true)
        let fetchRequest = NSFetchRequest(entityName: "Efforts")
        
        

        
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [sortDescr]
  
        do{
            let fetchEntity = try self.managedObjectContext.executeFetchRequest(fetchRequest) as! [Efforts]
            for entity in fetchEntity {
                print(entity.time," ",getTimeString((entity.time?.integerValue)!)," ", entity.activities," ",entity.typeEfforts," ",typeDist)
                
            }
        }
        catch{
            print ("error")
        }
        
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.orlov.vasili.My_best_effort" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("My_best_effort", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
}
