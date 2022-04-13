//
// Created by Federico Tartarini on 22/7/20.
// Copyright (c) 2020 Federico Tartarini. All rights reserved.
//

import Foundation
// this file contains the enum used to generate the Settings page programmatically

protocol SectionType: CustomStringConvertible {
    var constrainsSwitch: Bool { get }
    var isSwitchEnable: Bool { get }
    var imageView: Bool { get }
    var imageName: String { get }
}

// define the sections to appear in the setting menu
enum SettingsSections: Int, CaseIterable, CustomStringConvertible {

    case UserSettings
    case GeneralSettings
    case Communications
    case ExperimentSettings
    case About

    var description: String {
        switch self{
        case .UserSettings: return "User Settings"
        case .GeneralSettings: return "General Settings"
        case .Communications: return "Communications"
        case .ExperimentSettings: return "Experiment Settings"
        case .About: return "About"
        }
    }
}

// define the options in the UserSettings menu
enum UserSettingOptions: Int, CaseIterable, SectionType {
    
    case participantID
    case experimentID

    var imageView: Bool {
        return false
    }
    var imageName: String {
        return ""
    }
    var constrainsSwitch: Bool {
        return false
    }
    var isSwitchEnable: Bool {
        return false
    }
    var description: String {
        switch self {
        case .participantID: return "Participant ID"
        case .experimentID: return "Experiment ID"
        }
    }
}

// define the options in the GeneralSettings menu
enum GeneralSettingOptions: Int, CaseIterable, SectionType {

    case sendParticipantIDWatch

    var imageView: Bool {
        return false
    }
    var imageName: String {
        return ""
    }
    var constrainsSwitch: Bool {
        return false
    }
    var isSwitchEnable: Bool {
        return false
    }
    var description: String {
        switch self{
        case .sendParticipantIDWatch: return "Sync settings with watch"
        }
    }
}

// define the options in the communication menu
enum CommunicationOptions: Int, CaseIterable, SectionType {

    case reminders

    var imageView: Bool {
        return false
    }
    var imageName: String {
        return ""
    }
    var constrainsSwitch: Bool {
        switch self {
        case .reminders: return true
        }
    }
    var isSwitchEnable: Bool {
        switch self {
        case .reminders: return UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.NotificationEnable.rawValue) as? Bool ?? true
        }
    }
    var description: String {
        switch self{
        case .reminders: return "Reminders"
        }
    }
}

// define the options in the ExperimentSettings menu
enum ExperimentSettingOptions: Int, CaseIterable, SectionType {

    case questionFlow
    case ReminderFrequency
    case participationDays
    case dailyParticipationHours
    case downloadData

    var imageView: Bool {
        switch self {
        case .questionFlow, .ReminderFrequency, .participationDays, .dailyParticipationHours:
            return false
        case .downloadData:
            return true
        }
    }
    var imageName: String {
        switch self {
        case .questionFlow, .ReminderFrequency, .participationDays, .dailyParticipationHours:
            return ""
        case .downloadData:
            return imgDownload
        }
    }
    var constrainsSwitch: Bool {
        return false
    }
    var isSwitchEnable: Bool {
        return false
    }
    var description: String {
        switch self{
        case .questionFlow: return "Question Flows"
        case .ReminderFrequency: return "Reminder Frequency"
        case .participationDays: return "Participation Days"
        case .dailyParticipationHours: return "Daily Participation Hours"
        case .downloadData: return "Download Data"
        }
    }
}

// define the options in the About menu
enum AboutOptions: Int, CaseIterable, SectionType {

    case cozie
    case budsLab

    var imageView: Bool {
        return true
    }
    var imageName: String {
        switch self {
        case .cozie:
            return imgGithub
        case .budsLab:
            return imgBudsLab
        }
    }
    var constrainsSwitch: Bool {
        return false
    }
    var isSwitchEnable: Bool {
        return false
    }
    var description: String {
        switch self{
        case .cozie: return "COZIE"
        case .budsLab: return "BUDS Lab"
        }
    }
}
