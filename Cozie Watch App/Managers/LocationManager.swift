//
//  LocationManager.swift
//  Cozie Watch App
//
//  Created by Alexandr Chmal on 20.04.23.
//

import Foundation
import CoreLocation

protocol UpdateLocationProtocol {
    func updateLocation(completion: (()->())?)
    var currentLocation: CLLocation? { get }
}

final class LocationManager: NSObject {
    var locationManager: CLLocationManager? = nil
    var currentLocation: CLLocation? = nil
    var lastUpdateDate: Date?
    
    var completion: (()->())?
    
    func requestAuth() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
    }
}

extension LocationManager: UpdateLocationProtocol {
    func updateLocation(completion: (()->())?) {
        self.completion = completion
        
        if locationManager == nil {
            self.requestAuth()
        } else {
            if locationManager!.authorizationStatus == .authorizedWhenInUse || locationManager!.authorizationStatus == .authorizedAlways {
                locationManager?.requestLocation()
            }
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .denied:
            debugPrint("LocationManager didChangeAuthorization -> denied")
        case .notDetermined:
            debugPrint("LocationManager didChangeAuthorization -> notDetermined")
        case .authorizedWhenInUse:
            locationManager?.requestLocation()
        case .authorizedAlways:
            locationManager?.requestLocation()
        case .restricted:
            debugPrint("LocationManager didChangeAuthorization -> restricted")
        default:
            debugPrint("LocationManager didChangeAuthorization -> fatal")
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
        lastUpdateDate = Date()
        completion?()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        debugPrint("LocationManager didFailWithError: \(error.localizedDescription)")
        completion?()
    }
}
