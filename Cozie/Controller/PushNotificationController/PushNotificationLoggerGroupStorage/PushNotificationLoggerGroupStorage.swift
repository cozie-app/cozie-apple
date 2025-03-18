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
        
        case custom = "custom"
        case additional = "a"
        case nID = "notification_id"
    }
    
    let dateForm: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormat.defaultFormat
        return dateFormatter
    }()
    
    func formattedPayloads(categoryList: [CategoryInfo]) -> [[String: Any]] {
        return groupStorage.payloads().compactMap{ formattedData(trigger: NotificationKeys.reception.rawValue, categoryList: categoryList, info: $0, dateFormatter: dateForm, receive: true)}
    }
    
    func formattedActions(trigger: String, categoryList: [CategoryInfo], info: [String: Any]) -> [String: Any] {
        let dateString = dateForm.string(from: Date())
        
        return formattedData(trigger: trigger,
                             categoryList: categoryList,
                             info: info,
                             dateString: dateString) ?? [:]
    }
    
    private func formattedData(trigger: String,
                               categoryList: [CategoryInfo],
                               info: [String: Any],
                               dateFormatter: DateFormatter, receive: Bool = false) -> [String: Any]? {
        if let timestamp = info[GroupCommon.timestamp.rawValue] as? Double {
            let date = Date(timeIntervalSince1970: timestamp)
            let dateString = dateFormatter.string(from: date)
            
            if receive {
                return formattedDataReceive(trigger: trigger,
                                     categoryList: categoryList,
                                     info: info,
                                     dateString: dateString)
            } else {
                return formattedData(trigger: trigger,
                                     categoryList: categoryList,
                                     info: info,
                                     dateString: dateString)
            }
        } else { return nil }
    }
    
    private func formattedDataReceive(trigger: String,
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
            
            let buttons = categoryInfo?.buttons.reduce("", { partialResult, action in
                return partialResult.count > 0 ? partialResult + ", " + action : action
            }) ?? ""
            
            if let custom = info[NotificationKeys.custom.rawValue] as? [String: Any],
               let additional = custom[NotificationKeys.additional.rawValue] as? [String: Any],
               let nID = additional[NotificationKeys.nID.rawValue] as? String {
                fields = [NotificationActionKeys.notificationTitleKey: alert[NotificationKeys.alertTitle.rawValue] ?? "",
                          NotificationActionKeys.notificationSubtitleKey: alert[NotificationKeys.alertSubtitle.rawValue] ?? "",
                          NotificationActionKeys.notificationTextKey: alert[NotificationKeys.alertBody.rawValue] ?? "",
                          NotificationActionKeys.notificationActionsShowKey: buttons,
                          NotificationActionKeys.notificationNotificationIdKey: nID,
                          NotificationActionKeys.notificationTriggerKey: trigger,
                          NotificationActionKeys.notificationTransmitKey: trigger]
            } else {
                
                fields = [NotificationActionKeys.notificationTitleKey: alert[NotificationKeys.alertTitle.rawValue] ?? "",
                          NotificationActionKeys.notificationSubtitleKey: alert[NotificationKeys.alertSubtitle.rawValue] ?? "",
                          NotificationActionKeys.notificationTextKey: alert[NotificationKeys.alertBody.rawValue] ?? "",
                          NotificationActionKeys.notificationActionsShowKey: buttons,
                          NotificationActionKeys.notificationTriggerKey: trigger,
                          NotificationActionKeys.notificationTransmitKey: trigger]
            }
            
        } else {
            fields = [:]
        }
        
        let response: [String : Any] = [WatchSurveyKeys.postTime.rawValue: dateString,
                                        WatchSurveyKeys.measurement.rawValue: userData.userInfo?.experimentID ?? "",
                                        WatchSurveyKeys.tags.rawValue: tags,
                                        WatchSurveyKeys.fields.rawValue: fields]
        return response
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
            
            let buttons = categoryInfo?.buttons.reduce("", { partialResult, action in
                return partialResult.count > 0 ? partialResult + ", " + action : action
            }) ?? ""
            
            if let custom = info[NotificationKeys.custom.rawValue] as? [String: Any],
               let additional = custom[NotificationKeys.additional.rawValue] as? [String: Any],
               let nID = additional[NotificationKeys.nID.rawValue] as? String {
                fields = [NotificationActionKeys.notificationTitleKey: alert[NotificationKeys.alertTitle.rawValue] ?? "",
                          NotificationActionKeys.notificationSubtitleKey: alert[NotificationKeys.alertSubtitle.rawValue] ?? "",
                          NotificationActionKeys.notificationTextKey: alert[NotificationKeys.alertBody.rawValue] ?? "",
                          NotificationActionKeys.notificationActionsShowKey: buttons,
                          NotificationActionKeys.notificationNotificationIdKey: nID,
                          NotificationActionKeys.notificationActionButtonKey: trigger,
                          NotificationActionKeys.notificationTriggerKey: NotificationActionKeys.notificationTTValue,
                          NotificationActionKeys.notificationTransmitKey: NotificationActionKeys.notificationTTValue]
            } else {
                
                fields = [NotificationActionKeys.notificationTitleKey: alert[NotificationKeys.alertTitle.rawValue] ?? "",
                          NotificationActionKeys.notificationSubtitleKey: alert[NotificationKeys.alertSubtitle.rawValue] ?? "",
                          NotificationActionKeys.notificationTextKey: alert[NotificationKeys.alertBody.rawValue] ?? "",
                          NotificationActionKeys.notificationActionsShowKey: buttons,
                          NotificationActionKeys.notificationActionButtonKey: trigger,
                          NotificationActionKeys.notificationTriggerKey: NotificationActionKeys.notificationTTValue,
                          NotificationActionKeys.notificationTransmitKey: NotificationActionKeys.notificationTTValue]
            }
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
