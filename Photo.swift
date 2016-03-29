//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Patrick Bellot on 3/27/16.
//  Copyright © 2016 Bell OS, LLC. All rights reserved.
//

import UIKit
import CoreData


class Photo: NSManagedObject {

    struct Keys {
        static let ID = "id"
        static let Title = "title"
        static let URL = "url_m"
        static let Height = "height_m"
        static let Width = "width_m"
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    override func prepareForDeletion() {
        ImageCache.sharedInstance().deleteImage(id!)
    }
    
    init(dictionary: [String:AnyObject], context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        id = dictionary[Keys.ID] as? String
        title = dictionary[Keys.Title] as? String
        url = dictionary[Keys.URL] as? String
        height = dictionary[Keys.Height] as? String
        width = dictionary[Keys.Width] as? String
        downloaded = false
    }
    
    var image: UIImage? {
        get {
            return ImageCache.sharedInstance().imageWithIdentifier(id)
        }
        set {
            ImageCache.sharedInstance().storeImage(newValue, withIdentifier: id!)
            downloaded = true
        }
    }

}// End of Class
