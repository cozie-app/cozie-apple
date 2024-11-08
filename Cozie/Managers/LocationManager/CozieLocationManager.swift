//
//  CozieLocationManager.swift
//  Cozie
//
//  Created by Alexandr Chmal on 19.05.23.
//

import Foundation
import CoreLocation

class LocationManagerInteractor {
    let baseRepo = BaseRepository()
    let storage = CozieStorage.shared
    
    // MARK: Notification response
    func sendLocation(location: CLLocation,
                      userInteractor: UserInteractor = UserInteractor(),
                      backendInteractor: BackendInteractor = BackendInteractor(),
                      loggerInteractor: LoggerInteractor = LoggerInteractor.shared,
                      completion:((_ success: Bool)->())?) {
        guard let user = userInteractor.currentUser, let backend = backendInteractor.currentBackendSettings else {
            completion?(false)
            return
        }
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let dateString = dateFormatter.string(from: date)
        
        let tags = [WatchSurveyKeys.idOnesignal.rawValue: storage.playerID(),
                    WatchSurveyKeys.idParticipant.rawValue: user.participantID ?? "",
                    WatchSurveyKeys.idPassword.rawValue: user.passwordID ?? ""]
        
        let fields: [String : Any] = [LocationChangedKey.locationChange.rawValue: true,
                                     LocationChangedKey.tsTimestampLocation.rawValue: dateFormatter.string(from: location.timestamp),
                                     LocationChangedKey.tsLatitude.rawValue: location.coordinate.latitude,
                                     LocationChangedKey.tsLongitude.rawValue: location.coordinate.longitude,
                                     LocationChangedKey.tsAltitude.rawValue: location.altitude,
                                     LocationChangedKey.tsLocationFloor.rawValue: 0.0,
                                     LocationChangedKey.tsLocationAccuracyHorizontal.rawValue: location.horizontalAccuracy,
                                     LocationChangedKey.tsLocationAccuracyVertical.rawValue: location.verticalAccuracy,
                                     LocationChangedKey.tsLocationAcquisitionMethod.rawValue: "GPS",
                                     LocationChangedKey.tsLocationSourceDevice.rawValue: "iPhone",
                                     WatchSurveyKeys.transmitTrigger.rawValue: LocationChangedKey.locationChange.rawValue]
        
        let response: [String : Any] = [WatchSurveyKeys.postTime.rawValue: dateString,
                                        WatchSurveyKeys.measurement.rawValue: user.experimentID ?? "",
                                        WatchSurveyKeys.tags.rawValue: tags,
                                        WatchSurveyKeys.fields.rawValue: fields]
        
        do {
            let json = try JSONSerialization.data(withJSONObject: response, options: .prettyPrinted)
            
            baseRepo.post(url: backend.api_write_url ?? "", body: json, key: backend.api_write_key ?? "") { result in
                switch result {
                case .success(let data):
                    debugPrint(String(data: data, encoding: .utf8) ?? "somthing whent wrong!!!")
                    completion?(true)
                case .failure(let error):
                    debugPrint(error.localizedDescription)
                    completion?(false)
                }
            }
            
            // log data
            let jsonToLog = try JSONSerialization.data(withJSONObject: response, options: .withoutEscapingSlashes)
            debugPrint(jsonToLog)
            loggerInteractor.logInfo(action: "", info: String(data: jsonToLog, encoding: .utf8) ?? "")
            
        } catch let error {
            completion?(false)
            debugPrint(error.localizedDescription)
        }
    }
}

class LocationManager: NSObject {
    let mimimumDistance: Double = Defaults.locationChangeDistanceThreshold
    var locationManager: CLLocationManager? = nil
    var currentLocation: CLLocation? = nil
    
    let locationManagerInteractor = LocationManagerInteractor()
    private let healthKitInteractor = HealthKitInteractor(storage: CozieStorage.shared, userData: UserInteractor(), backendData: BackendInteractor(), loger: LoggerInteractor.shared)
    
    var completion: (()->())?
    
    func requestAuth() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.distanceFilter = mimimumDistance
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestAlwaysAuthorization()
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
            //testLog(details: "LocationManager didChangeAuthorization -> authorizedWhenInUse", state: "info")
            debugPrint("LocationManager didChangeAuthorization -> authorizedWhenInUse")
        case .authorizedAlways:
            //testLog(details: "Location authorized always", state: "info")
            locationManager?.startUpdatingLocation()
        case .restricted:
            debugPrint("LocationManager didChangeAuthorization -> restricted")
        default:
            debugPrint("LocationManager didChangeAuthorization -> fatal")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastSavedLocation = CozieStorage.shared.lastLocation(), currentLocation == nil {
            currentLocation = CLLocation(latitude: lastSavedLocation.lat, longitude: lastSavedLocation.lng)
        }
        
        if let cLocation = currentLocation {
            if let last = locations.last, cLocation.distance(from: last) > mimimumDistance {
                currentLocation = last
                CozieStorage.shared.updateLastLocation(lat: last.coordinate.latitude, lng: last.coordinate.longitude)
                if let location = currentLocation {
                    locationManagerInteractor.sendLocation(location: location) { [weak self] success in
                        guard let self = self else { return }
                        //self.testLog(details: "Location did send to service: \(success ? "Success" : "Failure")", state: "info")
                        self.healthKitInteractor.sendData(trigger: LocationChangedKey.locationChange.rawValue, timeout: HealthKitInteractor.minInterval, completion: nil)
                    }
                }
            }
        } else {
            currentLocation = locations.last
            
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
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //testLog(details: "LocationManager didFailWithError: \(error.localizedDescription)")
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
