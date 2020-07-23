//
// Created by Federico Tartarini on 22/7/20.
// Copyright (c) 2020 Federico Tartarini. All rights reserved.
//

protocol SectionType: CustomStringConvertible {
    var constrainsSwitch: Bool { get }
}

enum SettingsSections: Int, CaseIterable, CustomStringConvertible {

    case Settings
    case Communications
    var description: String {
        switch self{
        case .Settings: return "Settings"
        case .Communications: return "Communications"
        }
    }
}

enum SocialOptions: Int, CaseIterable, SectionType {

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
