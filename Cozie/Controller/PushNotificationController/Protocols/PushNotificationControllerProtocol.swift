//
//  PushNotificationControllerProtocol.swift
//  Cozie
//
//  Created by Alexandr Chmal on 22.10.24.
//

protocol PushNotificationControllerProtocol {
    func registerActionNotifCategory()
    func enablePushLogging(_ value: Bool)
}

protocol ApiDataProtocol {
    var url: String { get }
    var key: String { get }
}

protocol PushNotificationRepositoryProtocol {
    func saveNotifInfo(info: [String: Any]) async throws
    func saveAction(action: String) async throws
}

protocol CategoryDataProtocol: Codable {
    var id: String { get }
    var buttons: [String] { get }
}

protocol GroupStorageProtocol {
    func payloads() -> [[String: Any]]
    func clearPayloads()
    func delete(_ payloads: [String: Any])
    
    func actions() -> [String]
    func clearActions()
    func delete(_ action: String)
}

