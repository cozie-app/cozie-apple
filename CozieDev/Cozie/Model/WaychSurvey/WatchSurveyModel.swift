//
//  WatchSurveyModel.swift
//  Cozie
//
//  Created by Denis on 23.03.2023.
//

import Foundation

struct WatchSurveyModel {
    var validCount: String = ""
    var invalidCount: String = ""
    var lastSync: String = ""
    
    init(validCount: String, invalidCount: String, lastSync: String) {
        self.validCount = validCount
        self.invalidCount = invalidCount
        self.lastSync = lastSync
    }
    //DD.MM.yyyy - HH:mm
    func formattedDate() -> String {
        let dateFormattor = DateFormatter()
        dateFormattor.timeZone = TimeZone(identifier: "UTC")
        dateFormattor.dateFormat = "MM.dd.yyyy - HH:mm"
        if let date = dateFormattor.date(from: lastSync) {
            dateFormattor.timeZone = .current
            return dateFormattor.string(from: date)
        }
        
        return lastSync
    }
}

extension WatchSurveyModel: Encodable, Decodable {
    private enum CodingKeys : String, CodingKey {
        case validCount = "ws_survey_count_valid"
        case invalidCount = "ws_survey_count_invalid"
        case lastSync = "ws_timestamp_survey_last"
    }
    
    public func encode(to encoder: Encoder) throws {
         var container = encoder.container(keyedBy: CodingKeys.self)
         try container.encode(validCount, forKey: .validCount)
         try container.encode(invalidCount, forKey: .invalidCount)
         try container.encode(lastSync, forKey: .lastSync)
     }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let validCount = try values.decode(String.self, forKey: .validCount)
        let invalidCount = try values.decode(String.self, forKey: .invalidCount)
        let lastSync = try values.decode(String.self, forKey: .lastSync)

        self.init(validCount: validCount,
                  invalidCount: invalidCount,
                  lastSync: lastSync)
    }
}
