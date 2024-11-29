//
//  PuschNotificationLoggerGroupStorage.swift
//  Cozie
//
//  Created by Alexandr Chmal on 28.10.24.
//

import Foundation

struct PushNotificationLoggerGroupStorage {
    let groupStorage: GroupStorageProtocol
    let localStorage: CozieStorageProtocol
    let userData: UserDataProtocol
    
    private enum NotificationKeys: String {
        case dismissButton = "push_notification_dismiss_button"
        case reception =  "push_notification_reception"
        case aps = "aps"
        case alert = "alert"
        case alertTitle = "title"
        case alertSubtitle = "subtitle"
        case alertBody = "body"
        case category = "category"
        case notificationTitle = "notification_title"
        case notificationSubtitle = "notification_subtitle"
        case notificationText = "notification_text"
        case actionButtonShown = "action_buttons_shown"
        case transmitTrigger = "transmit_trigger"
    }
    
    let dateForm: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormat.defaultFormat
        return dateFormatter
    }()
    
    func formattedPayloads(categoryList: [CategoryInfo]) -> [[String: Any]] {
        return groupStorage.payloads().compactMap{formattedData(trigger: NotificationKeys.reception.rawValue, categoryList: categoryList, info: $0, dateFormatter: dateForm)}
    }
    
    func formattedActions(categoryList: [CategoryInfo], info: [String: Any]) -> [String: Any] {
        let dateString = dateForm.string(from: Date())
        
        return formattedData(trigger: NotificationKeys.dismissButton.rawValue,
                             categoryList: categoryList,
                             info: info,
                             dateString: dateString) ?? [:]
    }
        
    private func formattedData(trigger: String,
                               categoryList: [CategoryInfo],
                               info: [String: Any],
                               dateFormatter: DateFormatter) -> [String: Any]? {
        if let timestamp = info[GroupCommon.timestamp.rawValue] as? Double {
            let date = Date(timeIntervalSince1970: timestamp)
            let dateString = dateFormatter.string(from: date)
            
            
            return formattedData(trigger: trigger,
                                 categoryList: categoryList,
                                 info: info,
                                 dateString: dateString)
        } else { return nil }
    }
    
    private func formattedData(trigger: String,
                               categoryList: [CategoryInfo],
                               info: [String: Any],
                               dateString: String) -> [String: Any]? {
        let tags = [WatchSurveyKeys.idOnesignal.rawValue: localStorage.playerID(),
                    WatchSurveyKeys.idParticipant.rawValue: userData.userInfo?.participantID ?? "",
                    WatchSurveyKeys.idPassword.rawValue: userData.userInfo?.passwordID ?? ""]
        
        let fields: [String: Any]
        if let aps = info[NotificationKeys.aps.rawValue] as? [String: Any],
           let alert = aps[NotificationKeys.alert.rawValue] as? [String: Any] {
            let categoryInfo = categoryList.first(where: {$0.id == (aps[NotificationKeys.category.rawValue] as? String ?? "")})
            
            fields = [NotificationKeys.notificationTitle.rawValue: alert[NotificationKeys.alertTitle.rawValue] ?? "",
                     NotificationKeys.notificationSubtitle.rawValue: alert[NotificationKeys.alertSubtitle.rawValue] ?? "",
                     NotificationKeys.notificationText.rawValue: alert[NotificationKeys.alertBody.rawValue] ?? "",
                     NotificationKeys.actionButtonShown.rawValue: (categoryInfo?.buttons as? [String])?.reduce("", { partialResult, action in
                return partialResult.count > 0 ? partialResult + ", " + action : action
            }) ?? "",
                     NotificationKeys.transmitTrigger.rawValue: trigger]
        } else {
            fields = [:]
        }
        
        let response: [String : Any] = [WatchSurveyKeys.postTime.rawValue: dateString,
                                        WatchSurveyKeys.measurement.rawValue: userData.userInfo?.experimentID ?? "",
                                        WatchSurveyKeys.tags.rawValue: tags,
                                        WatchSurveyKeys.fields.rawValue: fields]
        return response
    }
}
