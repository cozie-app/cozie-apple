//
//  BackendInfo+CoreDataProperties.swift
//  Cozie
//
//  Created by Alexandr Chmal on 11.04.23.
//
//

import Foundation
import CoreData


extension BackendInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BackendInfo> {
        let request = NSFetchRequest<BackendInfo>(entityName: "BackendInfo")
        request.fetchLimit = 1
        return request
    }

    @NSManaged public var api_read_url: String?
    @NSManaged public var api_read_key: String?
    @NSManaged public var api_write_url: String?
    @NSManaged public var api_write_key: String?
    @NSManaged public var one_sigmnal_id: String?
    @NSManaged public var participant_password: String?
    @NSManaged public var watch_survey_link: String?
    @NSManaged public var phone_survey_link: String?

}

extension BackendInfo : Identifiable {

}
