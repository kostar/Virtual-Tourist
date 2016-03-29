//
//  VTMapViewController.swift
//  Virtual Tourist
//
//  Created by Patrick Bellot on 3/27/16.
//  Copyright © 2016 Bell OS, LLC. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class VTMapViewController: UIViewController, MKMapViewDelegate {
    
    let Region = "region"
    let RegionLatitude = "latitude"
    let RegionLongitude = "longitude"
    let RegionLatitudeDelta = "latitudeDelta"
    let RegionLongitudeDelta = "longitudeDelta"
    let ShowVTPhotoAlbumViewController = "showVTPhotoAlbumViewController"
    
    var longPressGestureRecognizer: UILongPressGestureRecognizer? = nil
    var currentPin: Pin? = nil
    var currentAnnotation: PinAnnotation? = nil
    var isDragging = false

    @IBOutlet weak var mapView: MKMapView!
    
    var context: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(VTMapViewController.addPin(_:)))
        mapView.addGestureRecognizer(longPressGestureRecognizer!)
        mapView.delegate = self
        
        fetchPins()
        fetchRegion()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == ShowVTPhotoAlbumViewController {
            // Back button
            let backBarButtonItem = UIBarButtonItem()
            backBarButtonItem.title = "OK"
            navigationItem.backBarButtonItem = backBarButtonItem
            
            // Configure the VTPhotoAlbumViewController
            let photoAlbumViewController = segue.destinationViewController as! VTPhotoAlbumViewController
            let pinAnnotation = sender as! PinAnnotation
            photoAlbumViewController.pinAnnotation = pinAnnotation
        }
    }
    
    // MARK: - Convenience method for saving the managed object context
    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    // MARK: - Fetch Data
    func fetchPins() {
        let request = NSFetchRequest(entityName: "Pin")
        request.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true)]
        
        var pins: [Pin]? = nil
        do {
            try pins = context.executeFetchRequest(request) as? [Pin]
        } catch {}
        
        if let _ = pins {
            mapView.addAnnotations(createAnnotations(pins!))
        }
    }
    
    func fetchRegion() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        guard let storedRegion = userDefaults.objectForKey(Region) as? [String:AnyObject] else {
            print("No region stored in user defaults")
            return
        }
        
        let latitude = storedRegion[RegionLatitude] as! CLLocationDegrees
        let longitude = storedRegion[RegionLongitude] as! CLLocationDegrees
        let latitudeDelta = storedRegion[RegionLatitudeDelta] as! CLLocationDegrees
        let longitudeDelta = storedRegion[RegionLongitudeDelta] as! CLLocationDegrees
        
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.region = region
        mapView.setCenterCoordinate(center, animated: true)
    }
    
    // MARK: - Add pins to map. Used by UILongPressGestureRecognizer
    func addPin(recognizer: UILongPressGestureRecognizer) {
        // Get touch point from gesture and convert it to coordinates
        let point: CGPoint = recognizer.locationInView(mapView)
        let coordinate: CLLocationCoordinate2D = mapView.convertPoint(point, toCoordinateFromView: mapView)
        
        switch recognizer.state {
        case .Began:
            // Create a new PinAnnotation for the point that was touched on the map.
            currentAnnotation = PinAnnotation()
            currentAnnotation!.coordinate = coordinate
            mapView.addAnnotation(currentAnnotation!)
        case .Changed:
            currentAnnotation!.coordinate = coordinate
        case .Ended:
            let createdAt = NSDate()
            currentAnnotation!.createdAt = createdAt
            let latitude = currentAnnotation!.coordinate.latitude
            let longitude = currentAnnotation!.coordinate.longitude
            let pin = Pin(latitude: latitude, longitude: longitude, createdAt: createdAt, context: context)
            pin.isDownloading = true
            saveContext()
            
            DataModel.searchPhotos(pin)
        default:
            return
        }
    }
    
    // MARK: - Create annotations
    func createAnnotations(pins: [Pin]) -> [PinAnnotation] {
        var annotations = [PinAnnotation]()
        
        for pin in pins {
            
            // Retrieve the latitude and longitude
            let lat = CLLocationDegrees(pin.latitude!)
            let long = CLLocationDegrees(pin.longitude!)
            
            // The lat and long are used to create a CLLocationCoordinates2D instance
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            // Create the annotation and set its properties
            let annotation = PinAnnotation()
            annotation.coordinate = coordinate
            annotation.createdAt = pin.createdAt
            
            // Place the annotation in an array of annotations
            annotations.append(annotation)
        }
        
        return annotations
    }
    
    // MARK: - MKMapViewDelegate methods
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            // create pinView and initialize
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = MKPinAnnotationView.redPinColor()
            pinView!.draggable = true
            pinView!.animatesDrop = true
        } else {
            // Reuse an existing pin view and set the annotation
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation!, animated: true)
        let pinAnnotation = view.annotation as! PinAnnotation
        performSegueWithIdentifier(ShowVTPhotoAlbumViewController, sender: pinAnnotation)
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let region = [
            RegionLatitude: mapView.region.center.latitude,
            RegionLongitude: mapView.region.center.longitude,
            RegionLatitudeDelta: mapView.region.span.latitudeDelta,
            RegionLongitudeDelta: mapView.region.span.longitudeDelta
        ]
        NSUserDefaults.standardUserDefaults().setObject(region, forKey: Region)
    }
}// End of Class