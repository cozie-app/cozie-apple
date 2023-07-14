//
//  HealthDataModel.swift
//  Cozie
//
//  Created by Alexandr Chmal on 28.04.23.
//

import Foundation

// MARK: - HealthModel
class HealthFilds: Encodable {
    var transmitTtrigger: String = ""
    var healthKey: String = ""
    var healthValue: Double = 0.0
    
    init(transmitTtrigger: String, healthKey: String, healthValue: Double) {
        self.transmitTtrigger = transmitTtrigger
        self.healthKey = healthKey
        self.healthValue = healthValue
    }
    
    enum HealthFildsCodingKeys: CodingKey {
        var stringValue: String {
            return self.value
        }
        
        init?(stringValue: String) {
            self = HealthFildsCodingKeys.info(key: stringValue)
        }
        
        var intValue: Int? {
            nil
        }
        
        init?(intValue: Int) {
            self = HealthFildsCodingKeys.info(key: "")
        }
        
        
        case transmitTtrigger
        case info(key: String)
        
        var value: String {
            switch self {
            case .info(let key):
                return key
            case .transmitTtrigger:
                return "transmit_trigger"
            }
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: HealthFildsCodingKeys.self)
        try container.encode(transmitTtrigger, forKey: .transmitTtrigger)
        try container.encode(healthValue, forKey: .info(key: healthKey))
    }
}

class HealthModel: Encodable {
    var time, measurement: String
    var tags: Tags
    var fields: HealthFilds
    
    enum CodingKeys: String, CodingKey {
        case time
        case measurement
        case tags
        case fields
    }
    
    init(time: String,
         measurement: String,
         tags: Tags,
         fields: HealthFilds) {
        
        self.time = time
        self.measurement = measurement
        self.tags = tags
        self.fields = fields
    }
}
