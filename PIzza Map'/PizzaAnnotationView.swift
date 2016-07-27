//
//  PizzaAnnotationView.swift
//  PIzza Map'
//
//  Created by Ryan Cortez on 7/27/16.
//  Copyright © 2016 Ryan Cortez. All rights reserved.
//

import UIKit
import MapKit

class PizzaAnnotationView: MKAnnotationView {
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupAnnotationView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupAnnotationView() {
        
        self.frame.size = CGSize(width: 60, height: 60)
        self.centerOffset = CGPoint(x: -5, y: -5)
        
        let imageView = UIImageView(image: UIImage(named: "pizza"))
        imageView.frame = self.frame
        self.addSubview(imageView)
        
    }
}
