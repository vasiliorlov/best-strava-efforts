//
//  AppDelegate.swift
//  My best effort
//
//  Created by iMac on 02.09.16.
//  Copyright © 2016 vasayCo. All rights reserved.
//
//https://www.strava.com/oauth/authorize?client_id=13322&response_type=code&redirect_uri=http://localhost/token_exchange.php&approval_prompt=force
import UIKit
import Alamofire
import SwiftyJSON

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        
    }
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {

        let code:String = url.URLString
        
        if let range = code.rangeOfString("code=") {
        let start = range.endIndex
        
           let params = ["client_id": "13322","client_secret": "afd449553af6c56abb5b9c2e0131bcbebccaeb22","code": code.substringFromIndex(start)]
            
            /*
             POST https://www.strava.com/oauth/token \
             -F client_id=5 \
             -F client_secret=7b2946535949ae70f015d696d8ac602830ece412 \
             -F code=75e251e3ff8fff
             */
            
            let URLaloma = NSURL(string:"https://www.strava.com/oauth/token")
            Alamofire.request(.POST, URLaloma! , parameters:params).responseJSON {
                response in
                print(response)
                switch response.result {
                case .Success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        
                        NSUserDefaults.standardUserDefaults().setObject(json["access_token"].string!, forKey: "token")
                        let athlete = json["athlete"]
                        NSUserDefaults.standardUserDefaults().setInteger(athlete["id"].int!, forKey: "idUser")
                        
                    }
                case .Failure(let error):
                    print(error)
                    
                }
            }
            
        
            
        }
        
        print("app",NSUserDefaults.standardUserDefaults().objectForKey("token"))
        
                NSUserDefaults.standardUserDefaults().synchronize()

            
        
        return true
    }

  
}

