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
    func reloadData(step:(Int,Int), json:JSON?)
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
    
    
    func requestWeb(url:String,page:Int) {
        let token = NSUserDefaults.standardUserDefaults().objectForKey("token")
        let headers = ["Authorization ": "Bearer \(token as! String)"]
        let params = ["page":page,"per_page":200]
        let URLaloma = NSURL(string:url)
        let notTheMainQueue = dispatch_queue_create("com.vasili.orlov.besteffort", DISPATCH_QUEUE_SERIAL)
        dispatch_async(notTheMainQueue) {
        Alamofire.request(.GET, URLaloma! ,parameters: params, headers: headers).responseJSON {
            response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let jSon = JSON(value)
                    
                    print(value.count)
                    if value.count != 0 {
                        self.deleteActivities()
                        self.saveActivitiesToDB(jSon)
                        self.requestWeb(url, page: page + 1)
                    }
                }
            case .Failure(let error):
                print("#1#",error.code," ",error.localizedDescription)
            }
        }
        }
    }
    
    func saveActivitiesToDB(jSon:JSON){
        var count = 0;
        let maxId = self.getMaxIdActivities()
        print("max ID",maxId)
        let idUser =  NSUserDefaults.standardUserDefaults().integerForKey("idUser")
        for (_,subJson):(String, JSON) in jSon {
            
            
            if subJson["id"].int > maxId {
            print("Insert id",subJson["id"].int)
            let newActivities = NSEntityDescription.insertNewObjectForEntityForName("Activities", inManagedObjectContext: self.managedObjectContext) as! Activities
            newActivities.id = subJson["id"].int
            newActivities.idUser = idUser
            newActivities.date = subJson["start_date"].string!
            newActivities.name = subJson["name"].string
            count += 1
            }
          
        }
        do{
            try self.managedObjectContext.save()
            reloadDataDelegate?.reloadData((0,count), json: nil)
        } catch {
            
        }
        
        
  
        
    }
    
    func getMaxIdActivities()->Int{
      
        let predicate = NSPredicate(format: "idUser = %i", NSUserDefaults.standardUserDefaults().integerForKey("idUser"))
        let sortDescr = NSSortDescriptor(key: "id", ascending: false)
        let fetchRequest = NSFetchRequest(entityName: "Activities")
         fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [sortDescr]
        
        var maxId:Int = 0
        
        do{
            let fetchEntity = try self.managedObjectContext.executeFetchRequest(fetchRequest) as! [Activities]
            if let first = fetchEntity.first {
                maxId = first.id!.integerValue
            }
     
        }
        catch{
            print ("#5#")
        }
        return maxId
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
        
        let fetchRequest = NSFetchRequest(entityName: "Activities")
        fetchRequest.predicate = predicate
        do{
            let fetchEntity = try self.managedObjectContext.executeFetchRequest(fetchRequest) as! [Activities]
            for entity in fetchEntity {
                self.managedObjectContext.deleteObject(entity)
            }
        } catch{
            print ("#2#")
        }
        
        
        
        
        
        do{
            try self.managedObjectContext.save()
        }
        catch{
            
        }
    }
    
    
    func getSreamFromActivities(Act:Activities){
        
        let token = NSUserDefaults.standardUserDefaults().objectForKey("token")
        let headers = ["Authorization ": "Bearer \(token as! String)"]

                print("https://www.strava.com/api/v3/activities/\(Act.id!)/streams/time")
                
                var streamTime = [Int]()
                var streamDist = [Double]()
                var count:Int = 0
                var dist:Double = 0.0
                
        let notTheMainQueue = dispatch_queue_create("com.vasili.orlov.besteffort", DISPATCH_QUEUE_SERIAL)
        dispatch_async(notTheMainQueue) {
                //get time
                let  URLaloma = NSURL(string:"https://www.strava.com/api/v3/activities/\(Act.id!)/streams/time")
                Alamofire.request(.GET, URLaloma! , headers: headers).responseJSON{
                 
                    response in
                   
                    
                    print("enter stream \(Act.id!)")
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
  
                            for typDist in 2 ... 12 {
                                if typDist == 7 || typDist == 9 || typDist == 11 {
                                continue
                                }
                                var minTime:Int = 0
                                let  distLenth:Double = Double(self.getMetr(typDist))
                                guard distLenth <= dist else {break}
                                for index in 0 ... count-2 {
                                    
                                    for index2 in index ... count-2 {
                                        
                                        
                                        let  distArray =   streamDist[index2 + 1] - streamDist[index]
                                        let  distArrayPre = streamDist[index2] - streamDist[index]
                                        let  timeArray = streamTime[index2+1] - streamTime[index]
                                       
                                        
                                        if distArrayPre < distLenth && distArray >= distLenth {
                                            if minTime == 0 || timeArray < minTime{
                                                 let speed = distArray / Double(timeArray)
                                                    minTime = Int( distLenth / speed)
                                               
                                            }
                                            
                                            break
                                        }
                                        
                                    }
                                    
                                }
                                
                                let newEfforts = NSEntityDescription.insertNewObjectForEntityForName("Efforts", inManagedObjectContext: self.managedObjectContext) as! Efforts
                                newEfforts.typeEfforts = self.getMetr(typDist)
                                newEfforts.time = minTime
                                newEfforts.activities = Act
                                
                                print(newEfforts)
                                
                                
                                do{
                                    self.reloadDataDelegate?.reloadData((1,0), json: nil)
                                    try self.managedObjectContext.save()
                                } catch{
                                    
                                }
                                
                            }
                           print("exit stream \(Act.id!)")
                           
                            
                        }
                    case .Failure(let error):
                        print("#3#",error.code," ",error.localizedDescription)
                    }
                    }
                }
                
                
        
            print(" stream \(Act.id!)")
            
            
            
            
      
        
        
        
        
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
    func getMetrStr(index:Int)->String{
        switch index {
        case 0: return "400 m"
        case 1: return "0.5 mi"
        case 2: return "1 km"
        case 3: return "1 mi"
        case 4: return "2 mi"
        case 5: return "5 km"
        case 6: return "10 km"
        case 7: return "15 km"
        case 8: return "10 mi"
        case 9: return "20 km"
        case 10: return "Half Marathon"
        case 11: return "30 km"
        case 12: return "Marathon"
        case 13: return "50 km"
        default: return ""
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
    
    func getEfforts(typeDist:Int) ->[NoteEffort]{
        let predicate = NSPredicate(format: "typeEfforts = %i",typeDist)// NSUserDefaults.standardUserDefaults().integerForKey("idUser"))
        let sortDescr = NSSortDescriptor(key: "time", ascending: true)
        let fetchRequest = NSFetchRequest(entityName: "Efforts")
        
        
        var result = [NoteEffort]()
        
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [sortDescr]
        
        do{
            let fetchEntity = try self.managedObjectContext.executeFetchRequest(fetchRequest) as! [Efforts]
            for entity in fetchEntity {
                let resultNote = NoteEffort()
                let activity = entity.activities as! Activities
                
                resultNote.date = activity.date!
                resultNote.name = activity.name!
                resultNote.time = getTimeString((entity.time?.integerValue)!)
                resultNote.url = ""
                
                if  activity.idUser!.integerValue == NSUserDefaults.standardUserDefaults().integerForKey("idUser") {
                result.append(resultNote)
                }
            }
        }
        catch{
            print ("#4#")
        }
        return result
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
