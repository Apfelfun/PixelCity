//
//  PopVC.swift
//  pixel-city
//
//  Created by Yousef Ouarghi on 31.07.17.
//  Copyright © 2017 Yousef Ouarghi. All rights reserved.
//

import UIKit
import MapKit

class PopVC: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var popImageView: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var takenLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    var passedImage: UIImage!
    var passedtitle: String!
    var passedTaken: String!
    var passedContent: String!
    var passedlatitude: Double!
    var passedlongitude: Double!
    var locationManager = CLLocationManager()
    
    func initData(withImage image: UIImage, forText title: String, andTaken take: String, andContent content: String, andlatitude latitude: Double, andlongitude longitude: Double) {
        self.passedImage = image
        self.passedtitle = title
        self.passedTaken = take
        self.passedContent = content
        self.passedlatitude = latitude
        self.passedlongitude = longitude
        addDoubleTap()
    }
    
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(screenWasDoubleTapped))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        view.addGestureRecognizer(doubleTap)
    }
    
    @objc func screenWasDoubleTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popImageView.image = passedImage
        titleLbl.text = passedtitle
        takenLbl.text = passedTaken
        descriptionLbl.text = passedContent
        mapView.delegate = self
        locationManager.delegate = self
        mapView.showsUserLocation = true
        mapLocationImage(latitude: passedlatitude, longitude: passedlongitude)
        
    }

}

extension PopVC: MKMapViewDelegate, CLLocationManagerDelegate  {
    func mapLocationImage(latitude: Double, longitude: Double) {
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let center = MKCoordinateRegionMakeWithDistance(location, 100, 100)
        mapView.setRegion(center, animated: true)
        let annation = DroppablePin(coordinate: location, identifier: "genauer")
        mapView.addAnnotation(annation)
    }
}
