//
//  PushNotificationHistoryRepository.swift
//  Cozie
//
//  Created by Lingting Pei on 13/9/2026.
//

import Foundation

protocol PushNotificationHistoryRepositoryProtocol {
    func load() -> [PushNotificationHistory]
    func delete(_ item: PushNotificationHistory)
    func clear()
}

final class PushNotificationHistoryRepository: PushNotificationHistoryRepositoryProtocol {

    private let storage: UserDefaults

    init(storage: UserDefaults = UserDefaults(suiteName: GroupCommon.storageName.rawValue) ?? UserDefaults.standard) {
        self.storage = storage
    }

    func load() -> [PushNotificationHistory] {
        var storedHistory = storage.object(
            forKey: GroupCommon.history.rawValue
        ) as? [[String: Any]] ?? []

        let retentionDays = CozieStorage.shared.notificationHistoryRetentionDays()

        let cutoffDate = Calendar.current.date(
            byAdding: .day,
            value: -retentionDays,
            to: Date()
        ) ?? Date()

        storedHistory.removeAll { info in
            guard let timestamp = info[GroupCommon.timestamp.rawValue] as? Double else {
                return false
            }

            let receivedAt = Date(timeIntervalSince1970: timestamp)
            return receivedAt < cutoffDate
        }

        storage.set(storedHistory, forKey: GroupCommon.history.rawValue)

        return storedHistory.compactMap { info in
            guard let timestamp = info[GroupCommon.timestamp.rawValue] as? Double,
                  let aps = info["aps"] as? [String: Any],
                  let alert = aps["alert"] as? [String: Any] else {
                return nil
            }

            return PushNotificationHistory(
                id: UUID(),
                title: alert["title"] as? String ?? "",
                subtitle: alert["subtitle"] as? String ?? "",
                body: alert["body"] as? String ?? "",
                receivedAt: Date(timeIntervalSince1970: timestamp)
            )
        }
        .sorted { $0.receivedAt > $1.receivedAt }
    }
    
    func delete(_ item: PushNotificationHistory) {
        var storedHistory = storage.object(forKey: GroupCommon.history.rawValue) as? [[String: Any]] ?? []
        
        storedHistory.removeAll { info in
            guard let timestamp = info[GroupCommon.timestamp.rawValue] as? Double else {
                return false
            }
            
            return Date(timeIntervalSince1970: timestamp) == item.receivedAt
        }
        
        storage.set(storedHistory, forKey: GroupCommon.history.rawValue)
    }

    func clear() {
        storage.removeObject(forKey: GroupCommon.history.rawValue)
    }
}
