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
import Alamofire
import AlamofireImage

class MapVC: UIViewController, UIGestureRecognizerDelegate {
    
    var locationManager = CLLocationManager()
    //Hiermit wird geschaut ob wir Zugriff auf den Standort haben
    let authorizationStatus = CLLocationManager.authorizationStatus()
    let regionRadius: Double = 1000
    var spinner: UIActivityIndicatorView?
    var progressLbL: UILabel!
    var screenSize = UIScreen.main.bounds
    var collectionView: UICollectionView!
    
    var flowLayout = UICollectionViewFlowLayout()
    
    var imageUrlArray = [String]()
    var titleArray = [String]()
    var photoIdArray = [String]()
    var datesArray = [String]()
    var imageArray = [UIImage]()
    var latitudeArray = [String]()
    var longitudeArray = [String]()
    
    
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
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView.register(PhotosCell.self, forCellWithReuseIdentifier: "photocell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        
        pullUpView.addSubview(collectionView)
        
        registerForPreviewing(with: self, sourceView: collectionView)
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
        cancelAllSessions()
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
        collectionView.addSubview(spinner!)
    }
    
    func removeSpinner() {
        if spinner != nil {
            spinner?.removeFromSuperview()
        }
    }
    
    func addProgressLbl() {
        progressLbL = UILabel()
        progressLbL.frame = CGRect(x: (screenSize.width / 2) - 120, y: 175, width: 240, height: 40)
        progressLbL.font = UIFont(name: "Avenir Next", size: 14)
        progressLbL.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        progressLbL.textAlignment = .center
        collectionView.addSubview(progressLbL!)
    }
    
    func removeProgressLbl() {
        if progressLbL != nil {
            progressLbL.removeFromSuperview()
        }
    }

    @IBAction func centerMapBtnWasPressed(_ sender: Any) {
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            centerMapOnUserLocation()
        }
    }
    
}

extension MapVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        //Wenn die Bemerkung der Standort ist soll dort kein Pin gesetzt werden
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
        removeSpinner()
        removeProgressLbl()
        cancelAllSessions()
        
        imageUrlArray = []
        imageArray = []
        photoIdArray = []
        datesArray = []
        latitudeArray = []
        longitudeArray = []
        
        collectionView.reloadData()
        
        animateViewUp()
        addSwipe()
        addSpinner()
        addProgressLbl()
        
        
        //Bei doppel Tap ruft erst die removePin Funktion auf!!!
        let touchPoint = sender.location(in: mapView)
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        let annatation = DroppablePin(coordinate: touchCoordinate, identifier: "droppablePin")
        mapView.addAnnotation(annatation)
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(touchCoordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
        
        
        //Wenn der Handler true wird diese Funktion aufgerufen
        retrieveUrls(forAnnotation: annatation) { (finished) in
            if finished {
                self.retrieveImages(handler: { (finished) in
                    if finished {
                        self.removeSpinner()
                        self.removeProgressLbl()
                        self.collectionView.reloadData()
                        //Spinner geht weg
                        //Label geht weg
                        //daten in der collectionView werden neu geladen
                    }
                })
            }
        }
    }
    
    func removePin() {
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
    }
    
    //retrieve abrufen der Url
    func retrieveUrls(forAnnotation annotation: DroppablePin, handler: @escaping (_ status: Bool) -> ()){
        Alamofire.request(flickrUrl(forKApi: apiKey, withAnnotation: annotation, andNumberOfPhotos: 30)).responseJSON { (response) in
            guard let json = response.result.value as? Dictionary<String, AnyObject> else {return}
            let photosDict = json["photos"] as! Dictionary<String, AnyObject>
            let photosDictArray = photosDict["photo"] as! [Dictionary<String, AnyObject>]
            for photo in photosDictArray {
                let postUrl = "https://farm\(photo["farm"]!).staticflickr.com/\(photo["server"]!)/\(photo["id"]!)_\(photo["secret"]!)_h_d.jpg"
                self.imageUrlArray.append(postUrl)
            }
            for title in photosDictArray {
                let title = title["title"] as! String
                self.titleArray.append(title)
            }
            
            for photoId in photosDictArray {
                let photoId = photoId["id"] as! String
                Alamofire.request(photoIdUrl(forApiKey: apiKey, withPhotoId: photoId)).responseJSON(completionHandler: { (response) in
                    guard let json = response.result.value as? Dictionary<String, AnyObject> else {return}
                    let photosDict = json["photo"] as! Dictionary<String, AnyObject>
                    let locationDict = photosDict["location"] as! Dictionary<String, AnyObject>
                    let latitudeInfo = locationDict["latitude"] as! String
                    let longitudeInfo = locationDict["longitude"] as! String
                    self.latitudeArray.append(latitudeInfo)
                    self.longitudeArray.append(longitudeInfo)
                    print(self.latitudeArray)
                    print(self.longitudeArray)
                    
                    let datesDict = photosDict["dates"] as! Dictionary<String, AnyObject>
                    let posted = datesDict["taken"] as! String
                    self.datesArray.append(posted)
                    
                    let descriptionDict = photosDict["description"] as! Dictionary<String, AnyObject>
                    let contentDict = descriptionDict["_content"] as! String
                    self.photoIdArray.append(contentDict)
                })
            }
            
            handler(true)
        }
    }
    
    
    func retrieveImages(handler: @escaping (_ status: Bool) -> ()) {
        for url in imageUrlArray {
            Alamofire.request(url).responseImage(completionHandler: { (response) in
                guard let image = response.result.value else {return}
                self.imageArray.append(image)
                self.progressLbL.text = "\(self.imageArray.count)/30 IMAGES DOWNLOADED"
                
                if self.imageArray.count == self.imageUrlArray.count {
                    handler(true)
                }
            })
        }
        
    }
    
    func cancelAllSessions() {
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, upkoadData, downloadData) in
            sessionDataTask.forEach({ $0.cancel()})
            downloadData.forEach({ $0.cancel()})
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

extension MapVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //number of items in arry
        return imageArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photocell", for: indexPath) as? PhotosCell else {return UICollectionViewCell()}
        let imageFromIndex = imageArray[indexPath.row]
        let imageView = UIImageView(image: imageFromIndex)
        cell.addSubview(imageView)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "PopVC") as? PopVC else {return}
        popVC.initData(withImage: imageArray[indexPath.row], forText: titleArray[indexPath.row], andTaken: datesArray[indexPath.row], andContent: photoIdArray[indexPath.row], andlatitude: Double(latitudeArray[indexPath.row])!, andlongitude: Double(longitudeArray[indexPath.row])!)
        present(popVC, animated: true, completion: nil)
    }
}

extension MapVC: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = collectionView.indexPathForItem(at: location), let cell = collectionView.cellForItem(at: indexPath) else { return nil }
        
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "PopVC") as? PopVC else { return nil }
        
        popVC.initData(withImage: imageArray[indexPath.row], forText: titleArray[indexPath.row], andTaken: datesArray[indexPath.row], andContent: photoIdArray[indexPath.row], andlatitude: Double(latitudeArray[indexPath.row])!, andlongitude: Double(longitudeArray[indexPath.row])!)
        
        previewingContext.sourceRect = cell.contentView.frame
        return popVC
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
}




