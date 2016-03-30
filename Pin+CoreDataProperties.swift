//
//  Pin+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Patrick Bellot on 3/27/16.
//  Copyright © 2016 Bell OS, LLC. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Pin {

    @NSManaged var page: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var latitude: NSNumber?
    @NSManaged var isDownloading: Bool
    @NSManaged var createdAt: NSDate?
    @NSManaged var photos: Set<Photo>
    @NSManaged var photosMetaData: PhotosMetaData?

}
