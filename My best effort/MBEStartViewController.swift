//
//  MBEStartViewController.swift
//  My best effort
//
//  Created by iMac on 19.09.16.
//  Copyright © 2016 vasayCo. All rights reserved.
//

import UIKit

class MBEStartViewController: UIViewController {

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
         print("start",NSUserDefaults.standardUserDefaults().objectForKey("token"))
       NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MBEStartViewController.goNextController(_:)), name:"MBEStravaNotificationIdentifier", object: nil)
        
        if let token = NSUserDefaults.standardUserDefaults().objectForKey("token") {
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("MBEViewController") as! MBEViewController
            vc.token = token as? String
            print("Enter")
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        // Do any additional setup after loading the view.
    }
    
    
    func goNextController(notification: NSNotification){
        if let token = NSUserDefaults.standardUserDefaults().objectForKey("token") {
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("MBEViewController") as! MBEViewController
            vc.token = token as? String
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func openStravaLogin(sender: AnyObject) {

        
        NSUserDefaults.standardUserDefaults().setObject("13322", forKey: "ClientID")
        NSUserDefaults.standardUserDefaults().setObject("afd449553af6c56abb5b9c2e0131bcbebccaeb22", forKey: "ClientSecret")
        NSUserDefaults.standardUserDefaults().setObject("localhost", forKey: "CallbackDomain")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        let strUrl = "MBEStravaClient://" +  (NSUserDefaults.standardUserDefaults().objectForKey("CallbackDomain") as! String)
        
        let urlStr = "https://www.strava.com/oauth/authorize?client_id="
            + (NSUserDefaults.standardUserDefaults().objectForKey("ClientID") as! String)
            + "&response_type=code&redirect_uri="
            + strUrl
            + "&scope=write&state=&approval_prompt=force"
        
        let url = NSURL(string: urlStr)
        
        UIApplication.sharedApplication().openURL(url!)
    }
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
