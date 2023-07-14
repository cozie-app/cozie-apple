//
//  CommunicationKeys.swift
//  Cozie
//
//  Created by Alexandr Chmal on 19.04.23.
//

import Foundation

public enum CommunicationKeys: String {
    case jsonKey = "CosieCOMJsonKey"
    case userIDKey = "CosieCOMUserIDKey"
    case expIDKey = "CosieCOMExpKey"
    case passwordIDKey = "CosieCOMPasswordIDKey"
    case writeApiKey = "CosieCOMwriteApiKey"
    case writeApiURL = "CosieCOMwriteApiURL"
    case timeInterval = "CosieCOMtimeInterval"
    case userOneSignalIDKey = "CosieCOMOneSignalIDKey"
    
    case resived = "recived"
    case wsLogs = "ws_logs"
    case oneSignalAppID = "be00093b-ed75-4c2e-81af-d6b382587283"
    case appTrigger = "application_appear"
    case syncSettingsTrigger = "sync_button_settings_tab"
    case syncBackendTrigger = "sync_button_backend_tab"
    case syncDataTrigger = "sync_button_data_tab"
    case syncBackgroundTaskTrigger = "background_task"
    case syncWatchSurveyTrigger = "watch_survey"
    case pushNotificationForegroundTrigger = "push_notification_foreground"
}

public enum WatchSurveyKeys: String {
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
    case actionButtonKey = "action_button"
    case transmitTriggerPushValue = "push_notification_action_button"
}

public enum LocationChangedKey: String {
    case locationChange  = "location_change"
    case tsLongitude = "ts_longitude"
    case tsLatitude = "ts_latitude"
    case tsAltitude = "ts_altitude"
    case tsLocationAccuracyVertical = "ts_location_accuracy_vertical"
    case tsLocationAccuracyHorizontal = "ts_location_accuracy_horizontal"
    case tsLocationSourceDevice = "ts_location_source_device"
    case tsLocationAcquisitionMethod = "ts_location_acquisition_method"
    case tsLocationFloor = "ts_location_floor"
    case tsTimestampLocation = "ts_timestamp_location"
}

// deep link example
/*coziedev://param?data=ewoJInBhcnRpY2lwYW50X2lkIjogImRldjA1IiwKCSJleHBlcmltZW50X2lkIjogImRldiIsCgkid3NzX3RpdGxlIjogIldlYXRoZXIgKHNob3J0KSIsCgkid3NzX2dvYWwiOiAxMCwKCSJ3c3NfdGltZV9vdXQiOiAzNTAwLAoJInJlYWRfdXJsIjogImh0dHBzOi8vYXQ2eDZiN3Y1NGhtb2tpNmRseWV3NzJjc3EwaWh4cm4ubGFtYmRhLXVybC5hcC1zb3V0aGVhc3QtMS5vbi5hd3MiLAoJInJlYWRfa2V5IjogIjEiLAoJIndyaXRlX3VybCI6ICJodHRwczovLzQzY2I1bm53ZTNtZWpvanlmdGJ1YW93NDY0MG5zcm5kLmxhbWJkYS11cmwuYXAtc291dGhlYXN0LTEub24uYXdzIiwKCSJ3cml0ZV9rZXkiOiAiMiIsCgkib25lX3NpZ21uYWxfaWQiOiAiYmUwMDA5M2ItZWQ3NS00YzJlLTgxYWYtZDZiMzgyNTg3MjgzIiwKCSJwYXJ0aWNpcGFudF9wYXNzd29yZCI6ICIxRzh5T2hQdk1aNm0iLAoJIndhdGNoX3N1cnZleV9saW5rIjogImh0dHBzOi8vcmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbS9tYXJpb2ZyZWkvY296aWUtdGVzdC9tYWluL3dhdGNoX3N1cnZleXMvd2F0Y2hfc3VydmV5X3dlYXRoZXJfc2hvcnQudHh0IiwKCSJwaG9uZV9zdXJ2ZXlfbGluayI6ICJodHRwczovL2RvY3MuZ29vZ2xlLmNvbS9mb3Jtcy9kL2UvMUZBSXBRTFNjaFg2Y0lxZ3g3dHVwVl80N281c1lWczVJdkVCcWh3VE1HdVJMQ2pHeHFiaF9nVEEvdmlld2Zvcm0/dXNwPXBwX3VybCZlbnRyeS4yNDcwMDY2NDA9ZGV2JmVudHJ5LjkzMjQ5OTA1Mj1kZXYwMSIKfQ==*/
