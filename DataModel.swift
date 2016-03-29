//
//  DataModel.swift
//  Virtual Tourist
//
//  Created by Patrick Bellot on 3/27/16.
//  Copyright © 2016 Bell OS, LLC. All rights reserved.
//

import UIKit
import CoreData

class DataModel: NSObject {
    
    struct NotificationNames {
        static let SearchPhotosStarted = "com.patrickbellot.SearchPhotosStarted"
        static let SearchPhotosPending = "com.patrickbellot.SearchPhotosPending"
        static let SearchPhotosCompleted = "com.patrickbellot.SearchPhotosCompleted"
        static let PhotoDownloadCompleted = "com.patrickbellot.PhotoDownloadCompleted"
        static let AllPhotoDownloadsCompleted = "com.patrickbellot.AllPhotoDownloadsCompleted"
    }
    
    private class var defaultCenter: NSNotificationCenter {
        return NSNotificationCenter.defaultCenter()
    }
    
    private class var context: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    private class func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    class func fetchPin(createdAt: NSDate) -> Pin? {
        let request = NSFetchRequest(entityName: "Pin")
        request.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true)]
        request.predicate = NSPredicate(format: "createdAt == %@", createdAt)
        
        var pins: [Pin]? = nil
        do {
            pins = try context.executeFetchRequest(request) as? [Pin]
        } catch let error as NSError {
            print("Error in fetchPin \(error)")
        }
        
        return pins?[0] ?? Pin()
    }
    
    class func searchPhotos(createdAt: NSDate, inNewCollection: Bool) {
        guard let pin = fetchPin(createdAt) else {
            print("No pin for date \(createdAt)")
            return
        }
        
        if inNewCollection {
            var page = pin.photosMetaData!.page?.integerValue
            let pages = pin.photosMetaData!.pages?.integerValue
            page = page < pages ? page : 1
            
            // Remove the old data from the pin
            context.deleteObject(pin.photosMetaData!)
            for photo in pin.photos {
                context.deleteObject(photo)
            }
            
            // Configure pin properties
            pin.page = page
            pin.isDownloading = true
            
            saveContext()
            searchPhotos(pin)
        } else {
            if pin.isDownloading {
                defaultCenter.postNotificationName(NotificationNames.SearchPhotosPending, object: nil)
            } else {
                defaultCenter.postNotificationName(NotificationNames.SearchPhotosCompleted, object: nil)
                
                if pin.hasAllPhotos() {
                    defaultCenter.postNotificationName(NotificationNames.AllPhotoDownloadsCompleted, object: nil)
                } else {
                    downloadPhotos(pin)
                }
            }
        }
    }
    
    class func searchPhotos(pin: Pin) {
        defaultCenter.postNotificationName(NotificationNames.SearchPhotosStarted, object: nil)
        
        let client = FlickrClient.sharedInstance()
        client.taskForPhotosSearch(pin) { (result, errorString) in
            
            guard let photos = result as? [String:AnyObject] else {
                print(errorString)
                return
            }
            
            guard let photosArray = photos[FlickrClient.JSONResponseKeys.Photo] as? [[String:AnyObject]] else {
                print(errorString)
                return
            }
            
            // Store the photos meta deta in the pin
            let photosMetaData = PhotosMetaData(dictionary: photos, context: self.context)
            pin.photosMetaData = photosMetaData
            
            // Store the photos in the pin
            let _ = photosArray.map() {(dictionary: [String:AnyObject]) -> Photo in
                let photo = Photo(dictionary: dictionary, context: context)
                photo.pin = pin
                return photo
            }
            
            pin.isDownloading = false
            
            saveContext()
            
            //Post a notification that the photos search has completed.
            defaultCenter.postNotificationName(NotificationNames.SearchPhotosCompleted, object: nil)
            
            // Download the photos for this pin
            downloadPhotos(pin)
        }
    }
    
    private class func downloadPhotos(pin: Pin) {
        let client = FlickrClient.sharedInstance()
        let photos = pin.photos
        var total = pin.photos.count
        var count = 0
        
        for photo in photos {
            // Don't download photos that have already been downloaded
            if photo.downloaded {
                // Decrement the total since there is one less photo to download
                total -= 1
                continue
            }
            
            client.taskForImageDownload(photo) {(imageData, errorString) in
                
                guard let imageData = imageData else {
                    print(errorString)
                    return
                }
                
                let image = UIImage(data: imageData)
                photo.image = image
                saveContext()
                
                //Post a notification that a photo download has completed
                defaultCenter.postNotificationName(NotificationNames.PhotoDownloadCompleted, object: nil)
                
                count += 1
                if count == total {
                    //post a notification that all photo downloads have completed
                    defaultCenter.postNotificationName(NotificationNames.AllPhotoDownloadsCompleted, object: nil)
                }
            }
        }
    }
}// End of Class
