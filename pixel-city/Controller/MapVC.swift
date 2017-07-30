//
//  MapVC.swift
//  pixel-city
//
//  Created by Yousef Ouarghi on 30.07.17.
//  Copyright © 2017 Yousef Ouarghi. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapVC: UIViewController, UIGestureRecognizerDelegate {
    
    var locationManager = CLLocationManager()
    //Hiermit wird geschaut ob wir Zugriff auf den Standort haben
    let authorizationStatus = CLLocationManager.authorizationStatus()
    let regionRadius: Double = 1000
    
    //Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        configureLocationServices()
        addDoubleTap()
    }
    
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        mapView.addGestureRecognizer(doubleTap)
    }

    @IBAction func centerMapBtnWasPressed(_ sender: Any) {
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            centerMapOnUserLocation()
        }
    }
    
}

extension MapVC: MKMapViewDelegate {
    func centerMapOnUserLocation() {
        guard let coordinate = locationManager.location?.coordinate else { return }
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, regionRadius * 2, regionRadius * 2)
        //Wenn das nicht mal 2 nimmt sind die 1000 der Durchmesser
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    @objc func dropPin() {
        //Hier wollen wir den Pin hinfallen lassen
        print("Pin wurde gedropped")
    }
}

extension MapVC: CLLocationManagerDelegate {
    
    func configureLocationServices() {
        //.notDetermined ist wenn der User sich noch nicht entschieden hat
        if authorizationStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        } else {
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        centerMapOnUserLocation()
    }
}
