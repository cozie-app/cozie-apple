//
//  WatchSurveyInteractor.swift
//  Cozie Watch App
//
//  Created by Alexandr Chmal on 20.04.23.
//

import Foundation
import CoreLocation

typealias SelectedSurveyInfo = (sID: String, optin: ResponseOption)
typealias SelectedSurveyTime = (startTime: Date, locationTime: Date?)

class WatchSurveyInteractor {
    enum WatchSurveyKeys: String {
        case idOnesignal = "id_onesignal"
        case idParticipant = "id_participant"
        case idPassword = "id_password"
        case wsSurveyCount = "ws_survey_count"
        case wsTimestampStart = "ws_timestamp_start"
        case wsTimestampLocation = "ws_timestamp_location"
        case wsLongitude = "ws_longitude"
        case wsLatitude = "ws_latitude"
        case wsAltitude = "ws_altitude"
        case wsLocationFloor = "ws_location_floor"
        case wsLocationAccuracyHorizontal = "ws_location_accuracy_horizontal"
        case wsLocationAccuracyVertical = "ws_location_accuracy_vertical"
        case wsLocationAcquisitionMethod = "ws_location_acquisition_method"
        case wsLocationSourceDevice = "ws_location_source_device"
        case transmitTrigger = "transmit_trigger"
        case postTime = "time"
        case measurement = "measurement"
        case tags = "tags"
        case fields = "fields"
        case wssTitle = "wss_title"
    }
    
    func sendSurveyData(watchSurvey: WatchSurvey?,
                        selectedOptions:[SelectedSurveyInfo],
                        location: CLLocation?,
                        time: SelectedSurveyTime,
                        storage: StorageManager = StorageManager.shared,
                        logsComplition:(()->())? = nil) {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let dateString = dateFormatter.string(from: date)
        
        let tags = [WatchSurveyKeys.idOnesignal.rawValue: "35E2A783-35DA-4C5F-B54E-5DAC30B6E860",
                    WatchSurveyKeys.idParticipant.rawValue: storage.userID(),
                    WatchSurveyKeys.idPassword.rawValue: storage.paswordID()]
        
        var fields: [String : Any] = [WatchSurveyKeys.wsSurveyCount.rawValue: storage.surveyCount(),
                                      WatchSurveyKeys.wsTimestampStart.rawValue: dateFormatter.string(from: time.startTime),
                                      WatchSurveyKeys.wsTimestampLocation.rawValue: time.locationTime == nil ? "" : dateFormatter.string(from: time.locationTime!),
                                      WatchSurveyKeys.wsLongitude.rawValue: location?.coordinate.longitude ?? 0.0,
                                      WatchSurveyKeys.wsLatitude.rawValue: location?.coordinate.latitude ?? 0.0,
                                      WatchSurveyKeys.wsAltitude.rawValue: location?.altitude ?? 0.0,
                                      WatchSurveyKeys.wsLocationFloor.rawValue: 0.0,
                                      WatchSurveyKeys.wsLocationAccuracyHorizontal.rawValue: location?.horizontalAccuracy ?? 0.0,
                                      WatchSurveyKeys.wsLocationAccuracyVertical.rawValue: location?.verticalAccuracy ?? 0.0,
                                      WatchSurveyKeys.wsLocationAcquisitionMethod.rawValue: "GPS",
                                      WatchSurveyKeys.wsLocationSourceDevice.rawValue: "Apple Watch",
                                      WatchSurveyKeys.transmitTrigger.rawValue: "watch_survey",
                                      WatchSurveyKeys.wssTitle.rawValue: watchSurvey?.surveyName ?? ""]
        
        for selected in selectedOptions {
            if selected.sID.isEmpty {
                continue
            }
            fields[selected.sID] = selected.optin.text
        }
        
        let survey: [String : Any] = [WatchSurveyKeys.postTime.rawValue: dateString,
                                      WatchSurveyKeys.measurement.rawValue: storage.expirimentID(),
                                      WatchSurveyKeys.tags.rawValue: tags,
                                      WatchSurveyKeys.fields.rawValue: fields]
        
        do {
            let json = try JSONSerialization.data(withJSONObject: survey, options: .prettyPrinted)
            let jsonToLog = try JSONSerialization.data(withJSONObject: survey, options: .withoutEscapingSlashes)
            debugPrint(jsonToLog)
            let api = storage.watchSurveyAPI()
            
            // save logs
            storage.seveLogs(logs: String(data: jsonToLog, encoding: .utf8) ?? "")
            //
            logsComplition?()
            
            BaseRepository().post(url: api.url, body: json, key: api.key) { result in
                switch result {
                case .success(let data):
                    debugPrint(String(data: data, encoding: .utf8) ?? "somthing whent wrong!!!")
                case .failure(let error):
                    debugPrint(error.localizedDescription)
                }
            }
            
        } catch let error {
            debugPrint(error.localizedDescription)
        }
    }
}
