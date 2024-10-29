//
//  PushCatgoryController.swift
//  Cozie
//
//  Created by Alexandr Chmal on 22.10.24.
//
import UIKit
protocol CatgoryDataProtocol: Codable {
    var id: String { get }
    var buttons: [String] { get }
}

struct CatgoryInfo: CatgoryDataProtocol {
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

class PushCatgoryController: NSObject {
    let pushNotificationLogger: PushNotificationLoggerController
    let groupStorage = PuschNotificationLoggerGroupStorage(storage: UserDefaults(suiteName: GroupCommonKeys.storageName.rawValue) ?? GroupStorageGuard())
    
    init(pushNotificationLogger: PushNotificationLoggerController) {
        self.pushNotificationLogger = pushNotificationLogger
    }
    
    // MARK: Notification Helper - Regiter Notification Category
    
    func enablePushLogging(_ value: Bool) {
        if value {
            Task{
                await withTaskGroup(of: Void.self, body: { [weak self] group in
                    if let self {
                        group.addTask {
                            for action in self.groupStorage.formattedActions() {
                                try? await self.pushNotificationLogger.pushNotificationDidSelectAction(action)
                            }
                        }
                    }
                })
                
                groupStorage.storage.clearActions()
            }
        }
    }
    
    func categoryList(plistName: String, bundel: Bundle) throws -> [CatgoryInfo] {
        if let url = bundel.url(forResource: plistName, withExtension: "plist") {
            let data = try Data(contentsOf: url)
            let decoder = PropertyListDecoder()
            let list = try decoder.decode([CatgoryInfo].self, from: data)
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

}

extension PushCatgoryController: PushCategoryProtocol {
    func regiterActionNotifCategory() {
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().setNotificationCategories([])

        
        UNUserNotificationCenter.current().getNotificationCategories { list in
            var categorys: Set<UNNotificationCategory> = []
            do {
                let bundel = Bundle(for: PushCatgoryController.self)
                let categoryList = try self.categoryList(plistName: "CategoryList", bundel: bundel)
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
extension PushCatgoryController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // need refactoring
        let surveyInteractor = WatchSurveyInteractor()
        if response.actionIdentifier != UNNotificationDefaultActionIdentifier {
            surveyInteractor.sendResponse(action: response.actionIdentifier) { success in
                if success {
                    debugPrint("iOS notification action sent")
                }
            }
        } else if response.actionIdentifier == UNNotificationDismissActionIdentifier {
            Task {
                try? await self.pushNotificationLogger.pushNotificationDidSelectAction("dismiss")
            }
        }
    }
}

extension UserDefaults: GroupStorageProtocol {
    func payloads() -> [[String : Any]] {
        self.value(forKey: GroupCommonKeys.payloads.rawValue) as? [[String : Any]] ?? []
    }
    
    func clearPayloads() {
        self.set(nil, forKey: GroupCommonKeys.payloads.rawValue)
    }
    
    func actions() -> [String] {
        self.value(forKey: GroupCommonKeys.actions.rawValue) as? [String] ?? []
    }
    
    func clearActions() {
        self.set(nil, forKey: GroupCommonKeys.actions.rawValue)
    }
    
}

fileprivate struct GroupStorageGuard: GroupStorageProtocol {
    let message = "Create storage error!"
    func payloads() -> [[String : Any]] {
        fatalError(message)
    }
    func clearPayloads() {
        //
    }
    
    func actions() -> [String] {
        fatalError(message)
    }
    
    func clearActions() {
        //
    }
}
