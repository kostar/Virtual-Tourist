//
//  PhotosMetaData+CoreDataProperties.swift
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

extension PhotosMetaData {

    @NSManaged var total: String?
    @NSManaged var perPage: NSNumber?
    @NSManaged var pages: NSNumber?
    @NSManaged var page: NSNumber?

}
