//
//  Activities.swift
//  My best effort
//
//  Created by iMac on 22.09.16.
//  Copyright © 2016 vasayCo. All rights reserved.
//

import Foundation
import CoreData


class Activities: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

    // called once in the object lifetime after the initial insertion
    override func awakeFromInsert() {
        super.awakeFromInsert()
        addObservers()
    }
    
    // called on each object fetch
    override func awakeFromFetch() {
        super.awakeFromFetch()
        addObservers()
    }
    
    // create common function for adding of all observers/observed properties
    private func addObservers() {
        self.addObserver(self, forKeyPath: "id", options: [.New, .Old], context: nil)
    }
    
    override func willTurnIntoFault() {
        super.willTurnIntoFault()
        removeObservers()
    }
    
    private func removeObservers() {
        self.removeObserver(self, forKeyPath: "id")
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if keyPath == "id" {
            // you can makes additional check if the value has changed ...
            if (change?[NSKeyValueChangeNewKey] as? Int) != nil {
                // TODO implementation
               // let notTheMainQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                 //   dispatch_queue_create("com.vasili.orlov.besteffort", DISPATCH_QUEUE_SERIAL)
                                MBEDBInspector.sharedInstance.getSreamFromActivities(self)
                
            }
            
        }
    }
}
