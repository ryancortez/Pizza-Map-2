//
//  PizzaShop.swift
//  PIzza Map'
//
//  Created by Ryan Cortez on 7/27/16.
//  Copyright © 2016 Ryan Cortez. All rights reserved.
//

import UIKit

class PizzaShop: NSObject {

    let name:String
    let latitude:Double
    let longitude:Double
    let imageURLString:String
    var image:UIImage?
    
    override init() {
        self.name = ""
        self.latitude = 0.0
        self.longitude = 0.0
        self.imageURLString = ""
        self.image = nil
        super.init()
    }
    
    init(withName name:String, atLatitude latitude: Double, andLongitude longitude:Double, withImageURLString urlString: String) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.imageURLString = urlString
        super.init()
        self.getImage(atURLString: urlString)
    }
    
    func getImage(atURLString urlString:String) {
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        dispatch_async(queue) {
            guard let url = NSURL(string: urlString) else {
                print("Did not find string with a valid URL")
                return
            }
            guard let data = NSData(contentsOfURL: url) else {
                print("Did not find data at URL(\(urlString))")
                return
            }
            guard let image = UIImage(data: data) else {
                print("Taco: Did not find an image in the NSData")
                return
            }
            dispatch_async(dispatch_get_main_queue()) {
                self.image = image
                
            }
        }
    }
    
}
