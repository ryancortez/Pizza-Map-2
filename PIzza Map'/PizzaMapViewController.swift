//
//  PizzaMapViewController
//  PIzza Map'
//
//  Created by Ryan Cortez on 7/27/16.
//  Copyright © 2016 Ryan Cortez. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class PizzaMapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate{

    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager: CLLocationManager!
    var pizzaShops: Array<PizzaShop> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getPizzaData()
        setupLocationManager()
        requestMapAuthorization()
        setupMapView()
        let coordinate = self.mapView.userLocation.coordinate
        let region = MKCoordinateRegionMakeWithDistance(coordinate, 500, 500)
        mapView.setRegion(region, animated: true)
        createAnnotation(atCoordinate: self.mapView.userLocation.coordinate)
    }
    
    // MARK: - Inital Setup
    
    func setupLocationManager() {
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = kCLDistanceFilterNone
        self.locationManager.startUpdatingLocation()
    }
    
    func setupMapView() {
        self.mapView.delegate = self
        self.mapView.showsUserLocation = true
    }
    
    // MARK: - Request Map Authorization
    
    func requestMapAuthorization() {
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    func createAnnotation (atCoordinate coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.title = "This is my annotation"
        annotation.coordinate = coordinate
        self.mapView.addAnnotation(annotation)
    }
    
    // MARK: - MapView Delegate
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        guard let coordinate = userLocation.location?.coordinate else {
            print("Did not find location in userLocation"); return
        }
        self.mapView.centerCoordinate = coordinate
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        var pizzaAnnotationView = self.mapView.dequeueReusableAnnotationViewWithIdentifier("PizzaAnnotationView")
        
        if pizzaAnnotationView == nil {
            pizzaAnnotationView = PizzaAnnotationView(annotation: annotation, reuseIdentifier: "PizzaAnnotationView")
        }
        
        for pizzaShop in pizzaShops {
            if (pizzaShop.latitude == annotation.coordinate.latitude && pizzaShop.longitude == annotation.coordinate.longitude) {
                pizzaAnnotationView!.canShowCallout = true
                guard let image = pizzaShop.image else {
                    print("Did not find image in current pizzaShop"); return pizzaAnnotationView
                }
                pizzaAnnotationView?.detailCalloutAccessoryView = getDetailCalloutView(withImage: image)
            }
        }
        
        return pizzaAnnotationView
    }
    
    private func getDetailCalloutView(withImage image: UIImage) -> UIImageView {
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        imageView.backgroundColor = UIColor.greenColor()
        imageView.image = image
        
        let widthConstraint = NSLayoutConstraint(item: imageView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 300)
        imageView.addConstraint(widthConstraint)
        
        let heightConstraint = NSLayoutConstraint(item: imageView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 300)
        imageView.addConstraint(heightConstraint)
        
        return imageView
        
    }
    
    // MARK: - MapView Annotation
    
    func addAnnotation(atCoordinate coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.title = "This is my annotation"
        annotation.coordinate = coordinate
        self.mapView.addAnnotation(annotation)
    }
    
    // MARK: - GET Pizza Data
    
    func getPizzaData() {
        let urlString = "https://dl.dropboxusercontent.com/u/20116434/locations.json"
        guard let url = NSURL(string: urlString) else {
            print("String(\(urlString)) does not contain valid URL"); return
        }
        let request = NSURLRequest(URL: url)
        let session = NSURLSession.sharedSession()
        
        session.dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) in
            guard let pizzaShopData = data else {
                print("JSON could not be created from the raw NSData"); return
            }
            do {
                guard let jsonArray = try NSJSONSerialization.JSONObjectWithData(pizzaShopData, options: .AllowFragments) as? Array<AnyObject> else {
                    print("JSON data was not formatted as a Dictionary"); return
                }
                for pizzaShopDictionary in jsonArray {
                    let nameKey = "name"
                    let latitudeKey = "latitude"
                    let longitudeKey = "longitude"
                    let imageURLKey = "photoUrl"
                    guard let name = pizzaShopDictionary.valueForKey(nameKey) as? String else {
                        print("Did not find string in key(\(nameKey))"); return
                    }
                    guard let latitude = pizzaShopDictionary.valueForKey(latitudeKey) as? Double else {
                        print("Did not find string in key(\(latitudeKey))"); return
                    }
                    guard let longitude = pizzaShopDictionary.valueForKey(longitudeKey) as? Double else {
                        print("Did not find string in key(\(longitudeKey))"); return
                    }
                    guard let imageURLString = pizzaShopDictionary.valueForKey(imageURLKey) as? String else {
                        print("Did not find string in key(\(imageURLKey))"); return
                    }
                    
                    let pizzaShop = PizzaShop(withName: name, atLatitude: latitude, andLongitude: longitude, withImageURLString: imageURLString)
                    self.pizzaShops.append(pizzaShop)
                    dispatch_async(dispatch_get_main_queue(), { 
                        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                        self.addAnnotation(atCoordinate: coordinate)
                    })
                }
            } catch {
                print("Could not serialize the data into JSON")
            }

        }.resume()
        
    }
}

