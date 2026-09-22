//
//  PushNotificationHistory.swift
//  Cozie
//
//  Created by Lingting on 13/9/2026.
//

import Foundation

struct PushNotificationHistory: Codable, Identifiable {
    let id: UUID
    let title: String
    let subtitle: String
    let body: String
    let receivedAt: Date
}
