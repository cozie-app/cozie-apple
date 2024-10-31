//
//  GroupCommon.swift
//  Cozie
//
//  Created by Alexandr Chmal on 28.10.24.
//

enum GroupCommon: String {
    static let payloadsLimit = 100
    static let actionsLimit = 100
    
    case storageName = "group.app.cozie.ios"
    case payloads = "cozie_push_notification_payload_info"
    case actions = "cozie_push_notification_payload_action"
    case timestamp = "cozie_push_notification_timestamp_action"
}
