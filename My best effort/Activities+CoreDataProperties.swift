//
//  Activities+CoreDataProperties.swift
//  My best effort
//
//  Created by iMac on 30.09.16.
//  Copyright © 2016 vasayCo. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Activities {

    @NSManaged var date: String?
    @NSManaged var id: NSNumber?
    @NSManaged var idUser: NSNumber?
    @NSManaged var name: String?
    @NSManaged var efforts: NSSet?

}
