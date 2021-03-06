//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by Patrick Bellot on 3/28/16.
//  Copyright © 2016 Bell OS, LLC. All rights reserved.
//

import Foundation
import MapKit

class FlickrClient: NSObject {
    
    func taskForPhotosSearch(pin: Pin, completionHandler: (result: AnyObject?, errorString: String?) -> Void) {
        
        // Specify the header fields and query parameters
        let headerFields = [String:String]()
        let queryParameters: [String:AnyObject] = [
            QueryKeys.APIKey: Constants.FlickrAPIKey,
            QueryKeys.Method: Methods.PhotosSearch,
            QueryKeys.SafeSearch: Constants.SafeSearch,
            QueryKeys.Extras: Constants.Extras,
            QueryKeys.Format: Constants.DataFormat,
            QueryKeys.NoJSONCallback: Constants.NoJSONCallback,
            QueryKeys.PerPage: Constants.PerPage,
            QueryKeys.Page: pin.page!,
            QueryKeys.Lat: pin.getLatitude(),
            QueryKeys.Lon: pin.getLongitude()
        ]
        
        let urlString = Constants.FlickrURL
        
        let restClient = VTClient.sharedInstance()
        restClient.taskForGetMethod(urlString, headerFields: headerFields, queryParameters: queryParameters) { (data, error) in
            
            if let _ = error {
                completionHandler(result: nil, errorString: "Failed to retrieve photos")
            } else {
                guard let JSONResult = VTClient.parseJSONWithCompletionHandler(data!) else {
                    completionHandler(result: nil, errorString: "Cannot parse data on JSON!")
                    return
                }
                
                guard let stat = JSONResult[JSONResponseKeys.Stat] as? String where stat == "ok" else {
                    let message = JSONResult[JSONResponseKeys.Message] as? String
                    completionHandler(result: nil, errorString: message)
                    return
                }
                
                guard let photos = JSONResult[JSONResponseKeys.Photos] as? [String:AnyObject] else {
                    completionHandler(result: nil, errorString: "Cannot find key 'photos' in JSON")
                    return
                }
                
                completionHandler(result: photos, errorString: nil)
            }
        }
    }
    
    func taskForImageDownload(photo: Photo, completionHandler: (imageData: NSData?, errorString: String?) -> Void) {
        
        let restClient = VTClient.sharedInstance()
        restClient.taskForGetMethod(photo.url!, headerFields: [String:String](), queryParameters: nil) { (data, error) in
            
            if let _ = error {
                completionHandler(imageData: nil, errorString: "Failed to download photo with url \(photo.url)")
            } else {
                completionHandler(imageData: data, errorString: nil)
            }
        }
    }
    
    class func sharedInstance() -> FlickrClient {
        
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        
        return Singleton.sharedInstance
    }
}