//
//  LocationManagerInteractor.swift
//  Cozie
//
//  Created by Alexandr Chmal on 14.01.25.
//

import Foundation
import CoreLocation

final class LocationManagerInteractor {
    // TO DO:  Dependency Inversion + Test coverage
    let baseRepo = BaseRepository()
    let storage = CozieStorage.shared
    //
    
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
        dateFormatter.dateFormat = DateFormat.defaultFormat
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
