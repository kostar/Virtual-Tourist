//
//  PhotosMetaData.swift
//  Virtual Tourist
//
//  Created by Patrick Bellot on 3/27/16.
//  Copyright © 2016 Bell OS, LLC. All rights reserved.
//

import Foundation
import CoreData


class PhotosMetaData: NSManagedObject {

    struct Keys {
        static let Page = "page"
        static let PerPage = "perpage"
        static let Pages = "pages"
        static let Total = "total"
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String:AnyObject], context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("PhotosMetaData", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        page = dictionary[Keys.Page] as? NSNumber
        perPage = dictionary[Keys.PerPage] as? NSNumber
        pages = dictionary[Keys.Pages] as? NSNumber
        total = dictionary[Keys.Total] as? String
    }
    
    func getTotal() -> NSNumber {
        return NSNumber(integer: Int(total!)!)
    }

}// End of Class
