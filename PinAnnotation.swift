//
//  PinAnnotation.swift
//  Virtual Tourist
//
//  Created by Patrick Bellot on 3/27/16.
//  Copyright © 2016 Bell OS, LLC. All rights reserved.
//

import MapKit

class PinAnnotation: MKPointAnnotation {
    
    var pin: Pin?
    var createdAt: NSDate?
    
    override init() {
        super.init()
    }

}
