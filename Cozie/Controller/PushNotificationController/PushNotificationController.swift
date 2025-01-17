//
//  PushNotificationController.swift
//  Cozie
//
//  Created by Alexandr Chmal on 22.10.24.
//

import UIKit

struct CategoryInfo: CategoryDataProtocol {
    let id: String
    let buttons: [String]
}

enum CategoryError: LocalizedError {
    case error(text: String)
    
    var errorDescription: String? {
        switch self  {
        case .error(let text):
            return text
        }
    }
}

class PushNotificationController: NSObject {
    
    let pushNotificationLogger: PushNotificationLoggerController
    let groupLoggerStorage: PushNotificationLoggerGroupStorage
    let categoryFileName = "CategoryList"
    
    init(pushNotificationLogger: PushNotificationLoggerController,
         userData: UserDataProtocol,
         storage: CozieStorageProtocol) {
        
        self.pushNotificationLogger = pushNotificationLogger
        self.groupLoggerStorage = PushNotificationLoggerGroupStorage(groupStorage: UserDefaults(suiteName: GroupCommon.storageName.rawValue) ?? UserDefaults.standard, localStorage: storage, userData: userData)
    }
    
    func categoryList(plistName: String, bundel: Bundle) throws -> [CategoryInfo] {
        if let url = bundel.url(forResource: plistName, withExtension: "plist") {
            let data = try Data(contentsOf: url)
            let decoder = PropertyListDecoder()
            let list = try decoder.decode([CategoryInfo].self, from: data)
            return list
        } else {
            throw CategoryError.error(text: "File not found")
        }
    }

    private func actionFromList(_ list: [String]) -> [UNNotificationAction] {
        var actions: [UNNotificationAction] = []
        for actionTitle in list {
            actions.append(UNNotificationAction(identifier: actionTitle,
                                                title: actionTitle,
                                                options: []))
        }
        return actions
    }
    
    private func registerCategory(_ id: String, actionList: [String]) -> UNNotificationCategory {
        return UNNotificationCategory(identifier: id,
                                              actions: actionFromList(actionList),
                                              intentIdentifiers: [],
                                              options: .customDismissAction)
    }
    
    fileprivate func categoryList() -> [CategoryInfo]? {
        let bundel = Bundle(for: PushNotificationController.self)
        return try? self.categoryList(plistName: categoryFileName, bundel: bundel)
    }

}

extension PushNotificationController: PushNotificationControllerProtocol {
    // MARK: Enable logging push notifications
    func enablePushLogging(_ value: Bool) {
        if value {
            Task{
                await withTaskGroup(of: Void.self, body: { [weak self] group in
                    if let self {
                        group.addTask {
                            for payloads in self.groupLoggerStorage.formattedPayloads(categoryList: self.categoryList() ?? []) {
                                try? await self.pushNotificationLogger.pushNotificationDidReciv(payload: payloads)
                            }
                        }
                    }
                })
                groupLoggerStorage.groupStorage.clearPayloads()
            }
        }
    }
    
    // MARK: Notification - Register Notification Category
    func registerActionNotifCategory() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().setNotificationCategories([])

        UNUserNotificationCenter.current().getNotificationCategories { list in
            var categorys: Set<UNNotificationCategory> = []
            do {
                let bundel = Bundle(for: PushNotificationController.self)
                let categoryList = try self.categoryList(plistName: self.categoryFileName, bundel: bundel)
                for value in categoryList {
                    if list.first(where: { $0.identifier == value.id }) == nil {
                        categorys.insert(self.registerCategory(value.id, actionList: value.buttons))
                    }
                }
            } catch _ {}
            
            UNUserNotificationCenter.current().setNotificationCategories(categorys)
        }
    }
}

// MARK: NotificationDelegate: - Silent notification actions
extension PushNotificationController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        Task {
            do {
                try await logPuchNotificationAction(actionIdentifier: response.actionIdentifier, userInfo: response.notification.request.content.userInfo as? [String: Any] ?? [:])
            } catch let error {
                debugPrint(error.localizedDescription)
            }
        }
    }
    
    func logPuchNotificationAction(actionIdentifier: String, userInfo: [String: Any]) async throws {
        if actionIdentifier != UNNotificationDefaultActionIdentifier && actionIdentifier != UNNotificationDismissActionIdentifier {
            let data = self.groupLoggerStorage.formattedActions(trigger: actionIdentifier, categoryList: categoryList() ?? [], info: userInfo)
            try await self.pushNotificationLogger.pushNotificationDidReciv(payload: data)
        } else if actionIdentifier == UNNotificationDismissActionIdentifier {
            let data = self.groupLoggerStorage.formattedActions(trigger: "Dismiss", categoryList: categoryList() ?? [], info: userInfo)
            try await self.pushNotificationLogger.pushNotificationDidReciv(payload: data)
        }
    }
}

extension UserDefaults: GroupStorageProtocol {
    func payloads() -> [[String : Any]] {
        self.value(forKey: GroupCommon.payloads.rawValue) as? [[String : Any]] ?? []
    }
    
    func clearPayloads() {
        self.set(nil, forKey: GroupCommon.payloads.rawValue)
    }
    
    func delete(_ payload: [String : Any]) {
        var payloads = self.value(forKey: GroupCommon.payloads.rawValue) as? [[String : Any]] ?? []
        let timestamp = payload[GroupCommon.timestamp.rawValue] as? Double
        guard let timestampe = timestamp else { return }
        
        if !payloads.isEmpty, let indexToDelete = payloads.firstIndex(where: { $0[GroupCommon.timestamp.rawValue] as? Double == timestampe}) {
            payloads.remove(at: indexToDelete)
        }
        
        self.set(payloads, forKey: GroupCommon.payloads.rawValue)
    }
    
    func actions() -> [String] {
        self.value(forKey: GroupCommon.actions.rawValue) as? [String] ?? []
    }

    
    func delete(_ action: String) {
        var actions =  self.value(forKey: GroupCommon.actions.rawValue) as? [String] ?? []
        if !actions.isEmpty, let indexToDelete = actions.firstIndex(of: action) {
            actions.remove(at: indexToDelete)
        }
        self.set(actions, forKey: GroupCommon.actions.rawValue)
    }
    
    
    func clearActions() {
        self.set(nil, forKey: GroupCommon.actions.rawValue)
    }
    
}
