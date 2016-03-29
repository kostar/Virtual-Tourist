//
//  Pin.swift
//  Virtual Tourist
//
//  Created by Patrick Bellot on 3/27/16.
//  Copyright © 2016 Bell OS, LLC. All rights reserved.
//

import Foundation
import CoreData


class Pin: NSManagedObject {
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(latitude: Double, longitude: Double, createdAt: NSDate, context: NSManagedObjectContext){
        
        let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.latitude = latitude as NSNumber
        self.longitude = longitude as NSNumber
        self.page = 1
        self.createdAt = createdAt
        isDownloading = false
    }
    
    func getLatitude() -> Double {
        return Double(latitude!)
    }
    
    func getLongitude() -> Double {
        return Double(longitude!)
    }
    
    func hasAllPhotos() -> Bool {
        if photos.count == 0 {
            return false
        }
        
        for photo in photos {
            if !photo.downloaded {
                return false
            }
        }
        
        return true
    }
}// End of Class
