//
// Created by Federico Tartarini on 22/7/20.
// Copyright (c) 2020 Federico Tartarini. All rights reserved.
//

// this file contains the enum used to generate the Settings page programmatically

protocol SectionType: CustomStringConvertible {
    var constrainsSwitch: Bool { get }
}

// define the sections to appear in the setting menu
enum SettingsSections: Int, CaseIterable, CustomStringConvertible {

    case Utilities
    case Communications

    var description: String {
        switch self{
        case .Utilities: return "Utilities"
        case .Communications: return "Communications"
        }
    }
}

// define the options in the utilities menu
enum UtilitiesOptions: Int, CaseIterable, SectionType {

    case sendParticipantIDWatch
    case logout

    var constrainsSwitch: Bool {
        return false
    }
    var description: String {
        switch self{
        case .sendParticipantIDWatch: return "Send participant ID to watch"
        case .logout: return "Log Out"
        }
    }
}

// define the options in the communication menu
enum CommunicationOptions: Int, CaseIterable, SectionType {

    case notification
    case emailConsent

    var constrainsSwitch: Bool {
        switch self {
        case .notification: return true
        case .emailConsent: return false
        }
    }
    var description: String {
        switch self{
        case .notification: return "Notification"
        case .emailConsent: return "Email consent form"
        }
    }
}
