//
//  CozieLocationManager.swift
//  Cozie
//
//  Created by Alexandr Chmal.
//

import Foundation
import CoreLocation

/// For iOS:
/// All locations will be accumulated in the background, sent to the server and saved in a log file if the distance from the first to the last location is greater than the location distance setting in the 'Advanced' tab.
///
/// Add setting to the 'Advanced' tab:
/// We will add a distance input field to track location with input validation, which will be saved and used as a distance filter.
///
/// Add a parameter to the deep link:
/// The "distance to location" will be added to the deep link parameters with an updated value in the 'Advanced' tab and in the Location Manager.
///
/// WatchOS:
/// We tracking location only on start or reset survey
///
final class LocationManager: NSObject {
    let minimumDistance: Double = Defaults.locationChangeDistanceThreshold
    var locationManager: CLLocationManager? = nil
    var currentLocation: CLLocation? = nil

    let locationManagerInteractor = LocationManagerInteractor()
    let storage: WSStorageProtocol
    
    private let healthKitInteractor = HealthKitInteractor(storage: CozieStorage.shared, userData: UserInteractor(), backendData: BackendInteractor(), logger: LoggerInteractor.shared)

    var completion: (()->())?
    
    init(storage: WSStorageProtocol = CozieStorage()) {
        self.storage = storage
    }
    
    func requestAuth() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.distanceFilter = CLLocationDistance(storage.distanceFilter()) // mimimumDistance
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestAlwaysAuthorization()
        locationManager?.allowsBackgroundLocationUpdates = true
    }
    
    func updateLocationManager() {
        if let locationManager {
            if locationManager.distanceFilter == CLLocationDistance(storage.distanceFilter()) {
                return
            }
            locationManager.stopUpdatingLocation()
            
            if locationManager.delegate == nil {
                locationManager.delegate = self
            }
            locationManager.distanceFilter = CLLocationDistance(self.storage.distanceFilter())
            
            if locationManager.desiredAccuracy != kCLLocationAccuracyBestForNavigation {
                locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            }
            
            Task.detached {
                do {
                    try await Task.sleep(for: .seconds(5))
                    locationManager.startUpdatingLocation()
                }
            }
        }
    }
    
    // TODO: - Unit Tests
    func updateLocation(locations: [CLLocation]) {
        let lastPrecise = locations.last
        guard var lastPrecise else { return }
        locations.dropLast().forEach({ location in
            if location.horizontalAccuracy < lastPrecise.horizontalAccuracy {
                lastPrecise = location
            }
        })
        
        if let lastSavedLocation = CozieStorage.shared.lastLocation(), currentLocation == nil {
            currentLocation = CLLocation(latitude: lastSavedLocation.lat, longitude: lastSavedLocation.lng)
        }
        
        if let cLocation = currentLocation {
            debugPrint("distance: -> \(cLocation.distance(from: lastPrecise))")
            if cLocation.distance(from: lastPrecise) > minimumDistance {
                currentLocation = lastPrecise
                CozieStorage.shared.updateLastLocation(lat: lastPrecise.coordinate.latitude, lng: lastPrecise.coordinate.longitude)
                if let location = currentLocation {
                    locationManagerInteractor.sendLocation(location: location) { [weak self] success in
                        guard let self = self else { return }
                        //self.testLog(details: "Location did send to service: \(success ? "Success" : "Failure")", state: "info")
                        self.healthKitInteractor.sendData(trigger: LocationChangedKey.locationChange.rawValue, timeout: HealthKitInteractor.minInterval, completion: nil)
                    }
                }
            }
        } else {
            currentLocation = lastPrecise
            
            if let cLocation = currentLocation {
                CozieStorage.shared.updateLastLocation(lat: cLocation.coordinate.latitude, lng: cLocation.coordinate.longitude)
            }
            
            if let location = currentLocation {
                locationManagerInteractor.sendLocation(location: location) { [weak self] success in
                    guard let self = self else { return }
                    //self.testLog(details: "Location did send to service: \(success ? "Success" : "Failure")", state: "info")
                    self.healthKitInteractor.sendData(trigger: LocationChangedKey.locationChange.rawValue, timeout: HealthKitInteractor.minInterval, completion: nil)
                }
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
            // testLog(details: "LocationManager didChangeAuthorization -> authorizedWhenInUse", state: "info")
            debugPrint("LocationManager didChangeAuthorization -> authorizedWhenInUse")
        case .authorizedAlways:
            // testLog(details: "Location authorized always", state: "info")
            locationManager?.startUpdatingLocation()
        case .restricted:
            debugPrint("LocationManager didChangeAuthorization -> restricted")
        default:
            debugPrint("LocationManager didChangeAuthorization -> fatal")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        updateLocation(locations: locations)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        debugPrint(error.localizedDescription)
//        testLog(details: "LocationManager didFailWithError: \(error.localizedDescription)")
    }
    
    // log test
//    private func testLog(details: String, state: String = "error") {
//
//        let str =
//        """
//        {
//        "trigger": "SessionReachability",
//        "si_location_change_state": "\(state)",
//        "si_location_change_details": "\(details)",
//        }
//        """
//        LoggerInteractor.shared.logInfo(action: "", info: str)
//    }
}
