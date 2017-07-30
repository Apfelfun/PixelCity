//
//  DroppablePin.swift
//  pixel-city
//
//  Created by Yousef Ouarghi on 30.07.17.
//  Copyright © 2017 Yousef Ouarghi. All rights reserved.
//

import Foundation
import MapKit

class DroppablePin: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    var identifier: String
    
    init(coordinate: CLLocationCoordinate2D, identifier: String) {
        self.coordinate = coordinate
        self.identifier = identifier
        super.init()
    }
}
