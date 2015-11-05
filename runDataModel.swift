//
//  runDataModl.swift
//  RUNNR
//
//  Created by Ian O'Boyle on 11/4/15.
//  Copyright © 2015 Ian O'Boyle. All rights reserved.
//

import Foundation
import CoreData

class RunEntity: NSManagedObject {
    @NSManaged var distance: Double
    @NSManaged var user: String
    @NSManaged var time: Double
    @NSManaged var createdAt: String
    @NSManaged var owns: NSSet
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
}

extension RunEntity{
    func addCoordinateObject(value:CoordinateEntity) {
        let items = self.mutableSetValueForKey("owns");
        items.addObject(value)
    }
    
    func removeCoordinateObject(value:CoordinateEntity) {
        let items = self.mutableSetValueForKey("owns");
        items.removeObject(value)
    }
    override func mutableSetValueForKey(key: String) -> NSMutableSet {
        if key == "owns"{
            return NSMutableSet(set: self.owns)
        }
        else{
            return NSMutableSet()
        }
    }
}
class CoordinateEntity: NSManagedObject {
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var isOwnedBy : NSManagedObject
    @NSManaged var order : Int
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
}

