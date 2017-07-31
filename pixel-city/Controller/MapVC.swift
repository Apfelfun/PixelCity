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
    var spinner: UIActivityIndicatorView?
    var progressLbL: UILabel!
    var screenSize = UIScreen.main.bounds
    
    //Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pullUpView: UIView!
    @IBOutlet weak var pullUpViewHeightContraints: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.showsUserLocation = true
        mapView.delegate = self
        locationManager.delegate = self
        configureLocationServices()
        addDoubleTap()
    }
    
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        mapView.addGestureRecognizer(doubleTap)
    }
    
    func addSwipe() {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(animateViewDown))
        swipe.direction = .down
        pullUpView.addGestureRecognizer(swipe)
    }
    
    func animateViewUp() {
        pullUpViewHeightContraints.constant = 300
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func animateViewDown() {
        pullUpViewHeightContraints.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func addSpinner() {
        spinner = UIActivityIndicatorView()
        spinner?.center = CGPoint(x: (screenSize.width / 2) - ((spinner?.frame.width)! / 2), y: 150)
        spinner?.activityIndicatorViewStyle = .whiteLarge
        spinner?.color = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        spinner?.startAnimating()
        pullUpView.addSubview(spinner!)
    }

    @IBAction func centerMapBtnWasPressed(_ sender: Any) {
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            centerMapOnUserLocation()
        }
    }
    
}

extension MapVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        //Wenn die Bewerbung der Standort ist soll dort kein Pin angezeigt werden
        if annotation is MKUserLocation {
            return nil
        }
        
        let pinnAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
        pinnAnnotation.pinTintColor = #colorLiteral(red: 0.9771530032, green: 0.7062081099, blue: 0.1748393774, alpha: 1)
        pinnAnnotation.animatesDrop = true
        return pinnAnnotation
    }
    func centerMapOnUserLocation() {
        guard let coordinate = locationManager.location?.coordinate else { return }
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, regionRadius * 2, regionRadius * 2)
        //Wenn das nicht mal 2 nimmt sind die 1000 der Durchmesser
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    @objc func dropPin(sender: UITapGestureRecognizer) {
        //Hier wollen wir den Pin hinfallen lassen
        removePin()
        animateViewUp()
        addSwipe()
        addSpinner()
        //Bei doppel Tap ruft erst die removePin Funktion auf!!!
        let touchPoint = sender.location(in: mapView)
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        let annatation = DroppablePin(coordinate: touchCoordinate, identifier: "droppablePin")
        mapView.addAnnotation(annatation)
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(touchCoordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func removePin() {
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
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
