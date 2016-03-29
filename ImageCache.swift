//
//  ImageCache.swift
//  Virtual Tourist
//
//  Created by Patrick Bellot on 3/27/16.
//  Copyright © 2016 Bell OS, LLC. All rights reserved.
//

import UIKit

class ImageCache {
    
    private var inMemoryCache = NSCache()
    
    // MARK: - Retreiving images
    
    func imageWithIdentifier(identifier: String?) -> UIImage? {
        
        // If the identifier is nil, empty, or returns nil
        if identifier == nil || identifier! == "" {
            return nil
        }
        
        let path = pathForIdentifier(identifier!)
        
        // Try memory cache first
        if let image = inMemoryCache.objectForKey(path) as? UIImage {
            return image
        }
        
        // Try hard drive next
        if let data = NSData(contentsOfFile: path) {
            return UIImage(data: data)
        }
        
        return nil
    }
    
    // MARK: - Saving images
    func storeImage(image: UIImage?, withIdentifier identifier: String) {
        let path = pathForIdentifier(identifier)
        
        //if the image is nil, remove images from cache
        if image == nil {
            inMemoryCache.removeObjectForKey(path)
            
            do {
                try NSFileManager.defaultManager().removeItemAtPath(path)
            } catch {}
            
            return
        }
        
        // Otherwise, keep the image in memory
        inMemoryCache.setObject(image!, forKey: path)
        
        // And in documents directory
        let data = UIImagePNGRepresentation(image!)!
        data.writeToFile(path, atomically: true)
    }
    
    // MARK: - Deleting images
    func deleteImage(identifier: String) {
        let path = pathForIdentifier(identifier)
        
        inMemoryCache.removeObjectForKey(path)
        do {
            try NSFileManager.defaultManager().removeItemAtPath(path)
        } catch {}
    }
    
    // MARK: - Helper
    func pathForIdentifier(identifier: String) -> String {
        let documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let fullURL = documentsDirectoryURL.URLByAppendingPathComponent(identifier)
        
        return fullURL.path!
    }
    
    class func sharedInstance() -> ImageCache {
        
        struct Singleton {
            static var shareInstance = ImageCache()
        }
        
        return Singleton.shareInstance
    }
    
}// End of Class // Random comment
