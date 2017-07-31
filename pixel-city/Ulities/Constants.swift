//
//  Constants.swift
//  pixel-city
//
//  Created by Yousef Ouarghi on 31.07.17.
//  Copyright © 2017 Yousef Ouarghi. All rights reserved.
//

import Foundation

let apiKey = "075990f4b2005fae0b1157b7cbbb7640"

func flickrUrl(forKApi key: String, withAnnotation annotation: DroppablePin, andNumberOfPhotos number: Int) -> String {
    let url = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&radius_units=mi&per_page=\(number)&format=json&nojsoncallback=1"
    print(url)
    return url    
}
