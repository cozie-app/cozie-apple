//
//  SettingsData+CoreDataProperties.swift
//  Cozie
//
//  Created by Alexandr Chmal on 27.04.23.
//
//

import Foundation
import CoreData


extension SettingsData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SettingsData> {
        let request = NSFetchRequest<SettingsData>(entityName: "SettingsData")
        request.fetchLimit = 1
        return request
    }

    @NSManaged public var ps_url: String?
    @NSManaged public var pss_reminder_days: String?
    @NSManaged public var pss_reminder_enabled: Bool
    @NSManaged public var pss_reminder_time: String?
    @NSManaged public var wss_goal: Int16
    @NSManaged public var wss_participation_days: String?
    @NSManaged public var wss_participation_time_end: String?
    @NSManaged public var wss_participation_time_start: String?
    @NSManaged public var wss_reminder_enabled: Bool
    @NSManaged public var wss_reminder_interval: Int16
    @NSManaged public var wss_time_out: Int16
    @NSManaged public var wss_title: String?

}

extension SettingsData : Identifiable {

}
